import { afterEach, expect, it } from 'vitest';
import { getLanguage, labelVariants, priceEvidence, setLanguage, t } from './i18n';
import { FIELDS, DEFAULT_OPTIONS } from './model';
import { DEMO_VMS, DEMO_PRICES } from './data';
import { analyze } from './engine';
import { automaticMapping } from './import';
import { reportCsv, reportHtml } from './report';

afterEach(()=>setLanguage('zh-CN'));
it('switches complete authored labels without altering enum identifiers',()=>{
  setLanguage('en');
  for (const field of FIELDS) for (const text of [field.label,field.group,field.hint??'']) expect(t(text)).not.toMatch(/[\u3400-\u9fff]/);
  expect(t('Standard_D8s_v3')).toBe('Standard_D8s_v3');
  expect(t('Actual / Amortized')).toBe('Actual / Amortized');
  setLanguage('zh-TW');
  expect(t('客户数据留在本地浏览器；不上传、不自动保存。教学案例均为模拟。')).toContain('資料');
  expect(getLanguage()).toBe('zh-TW');
});
it('maps translated field labels in every UI language',()=>{
  const originals=['资源唯一标识','部署区域','实例数'];
  for (const language of ['zh-CN','zh-TW','en'] as const) {
    setLanguage(language);
    const map=automaticMapping(originals.map(t));
    expect(map.id).toBe(t(originals[0]));expect(map.region).toBe(t(originals[1]));expect(map.count).toBe(t(originals[2]));
  }
  setLanguage('zh-TW');
  expect(labelVariants('实例数')).toContain(t('实例数'));
  expect(t('实例数')).toContain('數');
});
it('localizes dynamic messages and reports with nonzero placeholder indices',()=>{
  const analysis=DEMO_VMS.map(v=>analyze(v,DEMO_PRICES,DEFAULT_OPTIONS));
  setLanguage('en');
  expect(t('本地分析 12 / 300 条…')).not.toMatch(/[\u3400-\u9fff]/);
  const html=reportHtml(analysis,DEFAULT_OPTIONS,{total:6,valid:6,issues:[],warnings:[],file:'Synthetic data'});
  expect(html).toContain('lang="en"');expect(html).toContain('870.91');
  expect(html.match(/[\u3400-\u9fff]+/g)??[]).toEqual([]);
  expect(html).not.toMatch(/[\uE000\uE001]/);
  const csv=reportCsv(analysis,DEFAULT_OPTIONS);
  expect(csv).toContain('VM-001');expect(csv.match(/[\u3400-\u9fff]+/g)??[]).toEqual([]);
  expect(t('12 条候选路径')).toContain('12');
  setLanguage('zh-TW');
  expect(reportHtml(analysis,DEFAULT_OPTIONS,{total:6,valid:6,issues:[],warnings:[],file:'Synthetic data'})).toContain('lang="zh-TW"');
});
it('protects customer names, report titles and evidence strings from translation',()=>{
  const vm={...DEMO_VMS[0],name:'未知',priceSource:'内存 P99 %',priceKind:'customer' as const};
  const a=analyze(vm,DEMO_PRICES,DEFAULT_OPTIONS);
  setLanguage('en');
  const html=reportHtml([a],{...DEFAULT_OPTIONS,redact:false,title:'价格'},{total:1,valid:1,issues:[],warnings:[],file:'源配置'});
  expect(html).toContain('<title>价格</title>');
  expect(html).toContain('<h3>未知</h3>');
  expect(priceEvidence('客户提供价格：内存 P99 %')).toContain('内存 P99 %');
});
