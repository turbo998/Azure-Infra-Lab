import { createServer } from 'vite';
import ExcelJS from 'exceljs';
import { mkdir, readFile, readdir, writeFile, copyFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve, join } from 'node:path';

const root = fileURLToPath(new URL('..', import.meta.url)), delivery = resolve(root,'..');
const server = await createServer({configFile:false,root,server:{middlewareMode:true}});
try {
  const { DEMO_VMS, DEMO_PRICES, VERSION } = await server.ssrLoadModule('/src/data.ts');
  const { FIELDS, PRICE_HEADERS, DEFAULT_OPTIONS } = await server.ssrLoadModule('/src/model.ts');
  const { toCsv } = await server.ssrLoadModule('/src/import.ts');
  const { analyze } = await server.ssrLoadModule('/src/engine.ts');
  const { reportHtml } = await server.ssrLoadModule('/src/report.ts');
  const { setLanguage, t } = await server.ssrLoadModule('/src/i18n/index.ts');
  for (const folder of ['templates','sample-data','third-party-licenses']) await mkdir(join(delivery,folder),{recursive:true});
  await mkdir(join(root,'test-fixtures'),{recursive:true});
  const vmHeaders = FIELDS.map(f=>f.key);
  async function table(folder,stem,rows,headers,sheetName) {
    await writeFile(join(folder,`${stem}.csv`),toCsv(rows,headers));
    const book = new ExcelJS.Workbook(), sheet = book.addWorksheet(sheetName);
    sheet.addRow(headers);
    for (const r of rows) sheet.addRow(headers.map(h=>r[h] ?? ''));
    sheet.views=[{state:'frozen',ySplit:1}];
    sheet.autoFilter={from:{row:1,column:1},to:{row:Math.max(1,rows.length+1),column:headers.length}};
    sheet.columns.forEach(c=>c.width=24);
    sheet.getRow(1).font={bold:true};
    await book.xlsx.writeFile(join(folder,`${stem}.xlsx`));
  }
  await table(join(delivery,'templates'),'VM-用量模板',[],vmHeaders,'VM');
  await table(join(delivery,'templates'),'价格快照模板',[],PRICE_HEADERS,'Prices');
  await table(join(delivery,'sample-data'),'六个教学案例',DEMO_VMS,vmHeaders,'VM');
  await table(join(delivery,'sample-data'),'教学模拟价格',DEMO_PRICES,PRICE_HEADERS,'Prices');
  await writeFile(join(delivery,'templates','字段说明.csv'),toCsv(FIELDS.map(f=>({
    key:f.key,中文:f.label,分组:f.group,必填:f.required?'yes':'no',说明:f.hint ?? '',
  }))));
  const expected = DEMO_VMS.map(v=>analyze(v,DEMO_PRICES,DEFAULT_OPTIONS));
  await writeFile(join(delivery,'sample-data','案例预期结果.json'),JSON.stringify({
    version:VERSION,notice:'所有单价与客户名称均为教学模拟，非官方报价',options:DEFAULT_OPTIONS,
    results:expected.map(a=>({case:a.vm.name,sku:a.vm.sku,lifecycle:a.lifecycle,baseline:a.baseline,noChange:a.noChange,
      storage:a.storageFuture,candidates:a.candidates.map(c=>({sku:c.sku.name,cost:c.cost,difference:c.difference,blockers:c.blockers}))})),
  },null,2));
  await writeFile(join(delivery,'sample-data','教学示例报告.html'),reportHtml(expected,DEFAULT_OPTIONS,{
    total:DEMO_VMS.length,valid:DEMO_VMS.length,issues:[],warnings:[],file:'教学模拟',
  }));
  for (const language of ['zh-CN','zh-TW','en']) {
    setLanguage(language);
    const folder=join(delivery,'sample-data',language);
    await mkdir(folder,{recursive:true});
    const vms=DEMO_VMS.map(v=>({...v,name:t(v.name),priceSource:t(v.priceSource??'')}));
    const prices=DEMO_PRICES.map(p=>({...p,source:t(p.source)}));
    await table(folder,'sample-vms',vms,vmHeaders,'VM');
    await table(folder,'sample-prices',prices,PRICE_HEADERS,'Prices');
    await table(folder,'field-guide',FIELDS.map(f=>({key:f.key,label:t(f.label),group:t(f.group),required:f.required?'yes':'no',hint:t(f.hint??'')})),['key','label','group','required','hint'],'Fields');
    await writeFile(join(folder,'sample-report.html'),reportHtml(expected,DEFAULT_OPTIONS,{
      total:6,valid:6,issues:[],warnings:[],file:'Synthetic training data',
    }));
    await writeFile(join(folder,'expected-results.json'),JSON.stringify({
      language,disclaimer:t('教学模拟价格，非 Azure 报价'),assessmentDate:DEFAULT_OPTIONS.date,
      commercialNoChangeUSD:4145.83,
      cases:expected.map(a=>({id:a.vm.id,name:t(a.vm.name),sku:a.vm.sku,noChange:a.noChange,
        firstCandidate:a.candidates[0]?.sku.name??null,conditionalDifference:a.candidates[0]?.difference??null})),
    },null,2));
  }
  setLanguage('zh-CN');
  const missing = {...DEMO_VMS[5],hoursTotal:720,hoursPerVM:720};
  await writeFile(join(root,'test-fixtures','invalid.csv'),toCsv([missing],vmHeaders));
  const cv = {...DEMO_VMS[0],currentRate:0.5,rateBasis:'effective',priceIncludesUpdate:true,
    rateFrom:'2027-01-01',rateTo:'2028-01-01',priceKind:'customer',priceSource:'自动化格式测试模拟，非客户真实合同'};
  await table(join(root,'test-fixtures'),'customer-format',[cv],vmHeaders,'VM');
  const cp = {sku:'Standard_D4s_v5',region:'southeastasia',cloud:'Commercial',os:'Linux',currency:'USD',
    purchase:'PAYG',unit:'1 Hour',rate:0.2,from:'2027-01-01',to:'2028-01-01',basis:'effective',
    includesUpdate:true,source:'自动化格式测试模拟，非客户真实合同',kind:'customer'};
  await table(join(root,'test-fixtures'),'customer-prices',[cp],PRICE_HEADERS,'Prices');
  const scale = Array.from({length:1000},(_,i)=>({...DEMO_VMS[0],id:`synthetic-${i}`,name:`规模测试-${i}`}));
  await writeFile(join(root,'test-fixtures','scale-1000.csv'),toCsv(scale,vmHeaders));
  const notices = [];
  const nodeModules = join(root,'node_modules');
  const packages = [];
  for (const entry of await readdir(nodeModules,{withFileTypes:true})) {
    if (!entry.isDirectory() || entry.name.startsWith('.')) continue;
    if (entry.name.startsWith('@')) {
      for (const sub of await readdir(join(nodeModules,entry.name),{withFileTypes:true}))
        if (sub.isDirectory()) packages.push(join(nodeModules,entry.name,sub.name));
    } else packages.push(join(nodeModules,entry.name));
  }
  for (const path of packages) {
    const filenames = await readdir(path);
    if (!filenames.includes('package.json')) continue;
    const pkg = JSON.parse(await readFile(join(path,'package.json'),'utf8'));
    const licenses = filenames.filter(n=>/^(licen[cs]e|copying|notice)(\..*)?$/i.test(n));
    notices.push(`${pkg.name} ${pkg.version} | ${JSON.stringify(pkg.license ?? 'See package license')} | https://www.npmjs.com/package/${pkg.name}`);
    for (const name of licenses) {
      const stat = filenames.find(n=>n===name);
      if (stat) await copyFile(join(path,name),join(delivery,'third-party-licenses',`${pkg.name.replaceAll('/','__')}-${name}`));
    }
  }
  await writeFile(join(delivery,'THIRD_PARTY_NOTICES.txt'),`Offline HTML dependencies and source toolchain licenses\n\n${notices.sort().join('\n')}\n\nLicense texts are included in third-party-licenses. Development dependencies are not all bundled into HTML.\n`);
  console.log('Generated CSV/XLSX templates, six scenarios, expected results, standalone report and license notices.');
} finally {
  await server.close();
}
