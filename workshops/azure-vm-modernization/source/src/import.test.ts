import { expect, it } from 'vitest';
import ExcelJS from 'exceljs';
import { automaticMapping, mergeSupplement, parseCsv, readFile, toCsv, validatePrices, validateVms } from './import';
import { DEMO_VMS } from './data';
import { FIELDS } from './model';

const template = () => parseCsv(toCsv([Object.fromEntries(FIELDS.map(f=>[f.key,DEMO_VMS[0][f.key]]))],FIELDS.map(f=>f.key)));
it('roundtrips Chinese, commas, multiline and BOM',()=>{
  const s=parseCsv('\uFEFFid,sku,region,count,name\r\na,Standard_D4s_v3,southeastasia,1,"测试,组\n第二行"');
  expect(s.rows[0].name).toBe('测试,组\n第二行');
  expect(validateVms(s,automaticMapping(s.headers)).vms).toHaveLength(1);
});
it('maps supported bilingual columns without treating billing Quantity as instance count',()=>{
  const mapping=automaticMapping(['ResourceId','VmSize','部署区域','InstanceCount','Quantity','CostInBillingCurrency']);
  expect(mapping.id).toBe('ResourceId');expect(mapping.count).toBe('InstanceCount');
  expect(automaticMapping(['Quantity']).count).toBe('');
});
it('validates hand-calculated usage and rejects conflicting hour bases',()=>{
  const s=template(), m=automaticMapping(s.headers);
  expect(validateVms(s,m).issues).toHaveLength(0);
  s.rows[0].hoursTotal='720';
  expect(validateVms(s,m).issues.some(i=>i.field==='用量')).toBe(true);
  s.rows[0].hoursTotal='';s.rows[0].hoursPerVM='721';
  expect(validateVms(s,m).issues.some(i=>i.field==='每实例小时')).toBe(true);
});
it('blocks every duplicate identifier, not just later rows',()=>{
  const s=template();s.rows.push({...s.rows[0],name:'冲突数据'});
  const v=validateVms(s,automaticMapping(s.headers));
  expect(v.vms).toHaveLength(0);
  expect(v.issues.filter(i=>i.field==='资源唯一标识')).toHaveLength(2);
});
it('detects percentages, dates, integer counts and known SKU conflicts',()=>{
  for (const patch of [{cpuP95:'101'},{periodStart:'2026-02-30'},{count:'1.5'},{sku:'Standard_D8s_v5',vcpus:'4'},{usageUnit:'1 Core Hour'},{bootGeneration:'3'}]) {
    const s=template();Object.assign(s.rows[0],patch);
    expect(validateVms(s,automaticMapping(s.headers)).issues.length).toBeGreaterThan(0);
  }
});
it('rejects duplicate mapped source columns and empty or malformed files',()=>{
  const s=template(), m=automaticMapping(s.headers);m.name=m.id;
  expect(validateVms(s,m).vms).toHaveLength(0);
  expect(()=>parseCsv('a,a\n1,2')).toThrow('重复');
  expect(()=>parseCsv('id,sku')).toThrow('只有表头');
  expect(()=>parseCsv('id,sku\n"a')).toThrow('解析失败');
});
it('associates only unique stable ids and never overwrites conflicting values',()=>{
  const s=template(), m=automaticMapping(s.headers);
  const extra=parseCsv('id,nvmeReady\ndemo-web,true');
  expect(mergeSupplement(s,extra,m,automaticMapping(extra.headers)).rows[0].id).toBe('demo-web');
  const conflicting=parseCsv('id,count\ndemo-web,9');
  expect(()=>mergeSupplement(s,conflicting,m,automaticMapping(conflicting.headers))).toThrow('冲突');
  const orphan=parseCsv('id,nvmeReady\nwrong,true');
  expect(()=>mergeSupplement(s,orphan,m,automaticMapping(orphan.headers))).toThrow('无法关联');
});
it('escapes CSV spreadsheet formulas without stripping content',()=>{
  const csv=toCsv([{a:'=HYPERLINK("evil")',b:' @SUM(1)',c:'正常值'}]);
  expect(csv).toContain("'=HYPERLINK");
  expect(csv).toContain("' @SUM");
  expect(csv).toContain('正常值');
});
it('requires complete price schema, proper units and effective dates',()=>{
  const s=parseCsv('sku,region,cloud,os,currency,purchase,unit,rate,from,to,basis,includesUpdate,source,kind\nStandard_D4s_v5,southeastasia,Commercial,Linux,USD,PAYG,1 Hour,0.2,2027-01-01,,effective,yes,客户通知,customer');
  expect(validatePrices(s).prices).toHaveLength(1);
  s.rows[0].unit='1 Month';
  expect(validatePrices(s).issues).toHaveLength(1);
  expect(validatePrices(parseCsv('sku,rate\nStandard_D4s_v5,0.2')).issues).toHaveLength(1);
});
it('reads native XLSX percent/date cells and rejects formula cells',async()=>{
  const book=new ExcelJS.Workbook(), sheet=book.addWorksheet('客户用量');
  sheet.addRow(['id','sku','region','count','cpuP95','periodStart']);
  sheet.addRow(['x','Standard_D4s_v3','southeastasia',1,0.25,new Date('2026-09-01T00:00:00Z')]);
  sheet.getCell('E2').numFmt='0.00%';
  const file=async()=>new File([await book.xlsx.writeBuffer()],'data.xlsx');
  const data=await readFile(await file());
  expect(data[0].rows[0].cpuP95).toBe('25%');
  expect(data[0].rows[0].periodStart).toBe('2026-09-01');
  sheet.getCell('E2').value={formula:'1+1',result:2};
  await expect(readFile(await file())).rejects.toThrow('含公式');
});
it('offers data worksheets without blank or header-only sheets blocking import',async()=>{
  const book=new ExcelJS.Workbook();
  book.addWorksheet('空表');
  book.addWorksheet('尚未填完的模板').addRow(['id','sku','region','count']);
  const data=book.addWorksheet('有效数据');
  data.addRow(['id','sku','region','count']);
  data.addRow(['x','Standard_D4s_v3','West Europe',1]);
  const sheets=await readFile(new File([await book.xlsx.writeBuffer()],'multiple.xlsx'));
  expect(sheets.map(s=>s.name)).toEqual(['有效数据']);
  expect(validateVms(sheets[0],automaticMapping(sheets[0].headers)).vms[0].region).toBe('westeurope');
  book.removeWorksheet(data.id);
  await expect(readFile(new File([await book.xlsx.writeBuffer()],'empty.xlsx'))).rejects.toThrow('没有可用数据');
});
