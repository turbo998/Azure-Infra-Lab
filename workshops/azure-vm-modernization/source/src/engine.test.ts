import { describe, expect, it } from 'vitest';
import { analyze, hours, isDate, lifecycle, seriesOf, storageEffect, summarize, vmEffect } from './engine';
import { CATALOG, DEMO_PRICES, DEMO_VMS, LEGACY, REGIONS, STORAGE_EXCLUDED, STORAGE_INCLUDED, V7_EXEMPT } from './data';
import { DEFAULT_OPTIONS, type Price, type Vm } from './model';
import { reportCsv, reportHtml } from './report';

const o = DEFAULT_OPTIONS;
const vm = (patch: Partial<Vm> = {}): Vm => ({...DEMO_VMS[0],...patch});
const customer = {...o,mode:'customer' as const};
const effective: Price = { sku:'Standard_D8s_v3',region:'southeastasia',cloud:'Commercial',os:'Linux',
  currency:'USD',purchase:'PAYG',unit:'1 Hour',rate:0.5,from:'2027-01-01',to:'2028-01-01',
  basis:'effective',includesUpdate:true,source:'客户净费率通知',kind:'customer' };

describe('precise lifecycle and policy scopes',()=>{
  it.each(['Dv3','Dsv3','Ev3','Esv3'])('%s has its exact public deadline',s=>{
    expect(lifecycle(s,'Commercial',o.date).date).toBe('2029-11-15');
    expect(lifecycle(s,'Commercial','2029-11-15').stage).toBe('Retired');
    for (const cloud of ['China','Government','Sovereign'] as const) expect(lifecycle(s,cloud,o.date).stage).toBe('公告排除');
  });
  it('does not generalize generations or cloud exclusions',()=>{
    expect(seriesOf('Standard_DC4s_v3')).toBeNull();
    expect(seriesOf('Standard_NC24rs_v3')).toBeNull();
    expect(seriesOf('Standard_D4ds_v3')).toBeNull();
    expect(seriesOf('Standard_DS3_v2')).toBe('Dsv2');
    expect(seriesOf('Standard_DS3')).toBe('Ds');
    expect(seriesOf('Standard_D4s_v2')).toBeNull();
    expect(lifecycle('Dsv2','Commercial',o.date).date).toBe('2028-05-01');
    expect(lifecycle('Dsv2','China',o.date).stage).toBe('待核验');
    expect(lifecycle('Dsv3','Unknown',o.date).stage).toBe('待核验');
  });
  it.each(LEGACY)('%s legacy scenario never stacks regional increases',s=>{
    expect(vmEffect(s,'Commercial','northeurope',o).percent).toBe(25);
    expect(vmEffect(s,'China','chinaeast2',o).percent).toBe(0);
  });
  it.each(Object.entries(REGIONS))('%s has exact regional scenario %s', (r,p)=>{
    expect(vmEffect('Dsv3','Commercial',r,o).percent).toBe(p);
  });
  it.each(V7_EXEMPT)('%s is specifically exempt',s=>expect(vmEffect(s,'Commercial','northeurope',o).percent).toBe(0));
  it('honors effective dates, unknowns and noncommercial regional uncertainty',()=>{
    expect(vmEffect('Dsv3','Commercial','northeurope',{...o,date:'2027-01-31'}).percent).toBe(0);
    expect(vmEffect('Dsv3','Unknown','northeurope',o).percent).toBeNull();
    expect(vmEffect('Dsv3','China','chinaeast2',o).percent).toBeNull();
    expect(vmEffect(null,'Commercial','northeurope',o).percent).toBeNull();
    expect(vmEffect('Dsv3','Commercial','northeurope',customer).percent).toBeNull();
    expect(vmEffect('Dsv3','Commercial','northeurop',o).percent).toBeNull();
    expect(vmEffect('Dsv3','Commercial','eastus',o).percent).toBe(0);
    expect(storageEffect('Blob Storage','Commercial','badregion',o).percent).toBeNull();
  });
  it.each(STORAGE_EXCLUDED)('excludes exact storage product %s',p=>{
    expect(storageEffect(p,'Commercial','southeastasia',o).percent).toBe(0);
  });
  it.each(STORAGE_INCLUDED.filter(p=>!['Files','Files v2','Azure NetApp Files'].includes(p)))('includes exact storage product %s',p=>{
    expect(storageEffect(p,'Commercial','southeastasia',o).percent).toBe(8);
  });
  it('never guesses ambiguous storage sub-SKUs',()=>{
    for (const p of ['Files','Files v2','Azure NetApp Files','Unknown Storage'])
      expect(storageEffect(p,'Commercial','southeastasia',o).percent).toBeNull();
    expect(storageEffect('Standard Page Blob','Commercial','southeastasia',o).percent).toBe(0);
    expect(storageEffect('Standard Page Blob v2','Commercial','southeastasia',o).percent).toBe(8);
  });
});
describe('accounting and supported pricing',()=>{
  it('matches hand-calculated instance-hour and candidate amounts',()=>{
    const a = analyze(vm(),DEMO_PRICES,o);
    expect(hours(vm())).toBe(2880);
    expect(a.baseline).toBe(1209.6);
    expect(a.noChange).toBe(1306.37);
    expect(a.storageFuture).toBe(259.2);
    expect(a.candidates[0].sku.name).toBe('Standard_D4s_v5');
    expect(a.candidates[0].cost).toBe(435.46);
    expect(a.candidates[0].difference).toBe(870.91);
    expect(analyze(vm({hoursPerVM:undefined,hoursTotal:2880}),DEMO_PRICES,o).noChange).toBe(a.noChange);
  });
  it('does not treat unknown costs as zeros',()=>{
    expect(analyze(vm({currentRate:undefined}),[],o).noChange).toBeNull();
    expect(analyze(vm({currency:undefined}),DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze(vm({costBasis:undefined}),DEMO_PRICES,o).baseline).toBeNull();
    expect(analyze(vm({usageUnit:'1 Core Hour'}),DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze(vm(),DEMO_PRICES,customer).noChange).toBeNull();
  });
  it('uses matching effective prices exactly once and rejects ambiguity/expiry',()=>{
    const a = analyze(vm({priceKind:'customer'}),[effective],customer);
    expect(a.noChange).toBe(1440);
    expect(analyze(vm({priceKind:'customer'}),[effective],o).noChange).toBe(1440);
    expect(analyze(vm(),[effective,effective],customer).noChange).toBeNull();
    expect(analyze(vm(),[{...effective,to:'2027-02-01'}],customer).noChange).toBeNull();
    expect(analyze(vm(),[{...effective,os:'Windows'}],customer).noChange).toBeNull();
    expect(analyze(vm(),[{...effective,currency:'CNY'}],customer).noChange).toBeNull();
    expect(analyze(vm(),[{...effective,cloud:'China'}],customer).noChange).toBeNull();
    expect(analyze(vm(),[{...effective,basis:'baseline'}],customer).noChange).toBeNull();
  });
  it('preserves RI coverage and expiry without promising commitment savings',()=>{
    const a = analyze(DEMO_VMS[1],DEMO_PRICES,o);
    expect(a.noChange).toBe(571.46);
    expect(a.candidates[0].difference).toBeNull();
    expect(analyze({...DEMO_VMS[1],riCoverage:undefined},DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze({...DEMO_VMS[1],costBasis:'Actual'},DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze(DEMO_VMS[1],DEMO_PRICES,{...o,date:'2027-09-01'}).noChange).toBe(863.28);
  });
  it('honors EA source cap but never reuses it for target SKU',()=>{
    const a = analyze(DEMO_VMS[2],DEMO_PRICES,o);
    expect(a.noChange).toBe(648);
    expect(a.candidates.find(c=>c.sku.generation===5)?.cost).toBeNull();
    expect(analyze({...DEMO_VMS[2],eaCapRate:undefined},DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze({...DEMO_VMS[2],eaRenewal:undefined},DEMO_PRICES,o).noChange).toBeNull();
    expect(analyze(DEMO_VMS[2],DEMO_PRICES,{...o,date:'2028-01-01'}).noChange).toBe(756);
  });
  it('does not invent Savings Plan discount or commitment release',()=>{
    const a = analyze(vm({purchase:'SavingsPlan'}),DEMO_PRICES,o);
    expect(a.noChange).toBeNull();
    expect(a.candidates[0].difference).toBeNull();
  });
  it('keeps currencies and cost bases isolated',()=>{
    const rows=[analyze(vm(),[],o),analyze(vm({id:'b',currency:'CNY'}),[],o),analyze(vm({id:'c',costBasis:'Actual'}),[],o)];
    expect(summarize(rows)).toHaveLength(3);
  });
});
describe('constraint-aware candidate selection',()=>{
  it('requires all performance evidence before reducing capacity',()=>{
    for (const patch of [{memoryP99:undefined},{networkP95Mbps:undefined},{peakCovered:undefined},{observationDays:7},{tempGiB:undefined},{diskIOPS:undefined},{workload:'unknown' as const}]) {
      const a = analyze(vm(patch),DEMO_PRICES,o);
      expect(a.candidates.every(c=>c.sku.cores>=8&&c.sku.memory>=32)).toBe(true);
    }
  });
  it('respects memory, temporary disk, network and remote disk limits',()=>{
    const a = analyze(vm({memoryP99:90,tempGiB:150,diskIOPS:10000,networkP95Mbps:5000}),DEMO_PRICES,o);
    expect(a.candidates.length).toBeGreaterThan(0);
    expect(a.candidates.every(c=>c.sku.memory>=48&&c.sku.temp>=150&&c.sku.iops>=10000&&c.sku.network*.4>=5000)).toBe(true);
    const blocked = analyze(vm({tempGiB:9999}),DEMO_PRICES,o);
    expect(blocked.candidates).toHaveLength(0);
  });
  it('does not promise blind in-place migration or special-workload replacement',()=>{
    const a = analyze(vm({bootGeneration:1,nvmeReady:false,manaReady:false}),DEMO_PRICES,o);
    for (const c of a.candidates.filter(c=>c.sku.generation>=6)) {
      expect(c.blockers.some(b=>b.includes('Gen2'))).toBe(true);
      expect(c.blockers.some(b=>b.includes('NVMe'))).toBe(true);
      expect(c.blockers.some(b=>b.includes('MANA'))).toBe(true);
    }
    expect(analyze(DEMO_VMS[4],DEMO_PRICES,o).candidates).toHaveLength(0);
    expect(analyze(vm({architecture:'arm64'}),DEMO_PRICES,o).candidates).toHaveLength(0);
    expect(analyze(vm({specialRequirements:'manual'}),DEMO_PRICES,o).candidates).toHaveLength(0);
  });
  it('catalog has exact versioned links and unique names',()=>{
    expect(CATALOG).toHaveLength(56);
    expect(new Set(CATALOG.map(s=>s.name)).size).toBe(CATALOG.length);
    expect(CATALOG.every(s=>s.source.startsWith('https://learn.microsoft.com/')&&s.memory>=8&&s.network>0)).toBe(true);
  });
});
describe('report integrity and escaping',()=>{
  it('escapes untrusted input and redacts identities',()=>{
    const a = analyze(vm({id:'SECRET-ID',name:'<img src=x onerror=alert(1)>',subscription:'SECRET-SUB',priceSource:'SECRET-CUSTOMER'}),DEMO_PRICES,o);
    const quality={total:1,valid:1,issues:[],warnings:[],file:'SECRET-FILE'};
    const report=reportHtml([a],{...o,title:'SECRET-TITLE'},quality);
    for (const s of ['SECRET-ID','SECRET-SUB','SECRET-CUSTOMER','SECRET-FILE','SECRET-TITLE','<img src=x']) expect(report).not.toContain(s);
    expect(report).toContain('VM-001');
    const unredacted=reportHtml([a],{...o,redact:false},quality);
    expect(unredacted).toContain('&lt;img src=x');
    expect(unredacted).not.toContain('<img src=x');
    expect(reportCsv([a],o)).not.toContain('SECRET-ID');
  });
  it('preserves unknown amounts and coverage in standalone report',()=>{
    const a=analyze(vm({currentRate:undefined}),[],o);
    const text=reportHtml([a],o,{total:2,valid:1,issues:[{row:3,field:'id',message:'缺失'}],warnings:[],file:'example'});
    expect(text).toContain('未知 / 待补依据');
    expect(text).toContain('未分析 1');
    expect(text).toContain('0/1 记录');
    expect(text).not.toMatch(/<script[^>]+src=/);
  });
  it('rejects impossible calendar dates',()=>{
    expect(isDate('2027-02-29')).toBe(false);
    expect(isDate('2028-02-29')).toBe(true);
    expect(isDate('2027-13-01')).toBe(false);
  });
});
