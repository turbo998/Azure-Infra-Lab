import { chromium } from 'playwright';
import assert from 'node:assert/strict';
import { mkdir, readFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { resolve, join } from 'node:path';

const root = fileURLToPath(new URL('..',import.meta.url)), delivery = resolve(root,'..'), output = join(root,'test-output');
await mkdir(output,{recursive:true});
const browser = await chromium.launch({
  executablePath:process.env.BROWSER_EXE || 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',headless:true,
});
const errors=[],network=[];
const context = await browser.newContext({offline:true,acceptDownloads:true,colorScheme:'light',viewport:{width:1440,height:1000}});
context.on('page',p=>{
  p.on('pageerror',e=>errors.push(e.message));
  p.on('console',m=>{if(m.type()==='error') errors.push(m.text());});
  p.on('request',r=>{if(/^https?:/.test(r.url())) network.push(r.url());});
  p.on('dialog',d=>d.accept());
});
const page=await context.newPage();
const open=async name=>{await page.goto(pathToFileURL(join(delivery,name)).href);await page.waitForSelector('h1');};
const visibleText=async text=>assert(await page.getByText(text,{exact:false}).first().isVisible(),`Missing text: ${text}`);
const run=async()=>{
  await page.getByRole('button',{name:'分析配置与影响 →',exact:true}).click();
  await page.waitForSelector('#results',{timeout:60000});
};
const upload=async(label,file)=>{await page.getByLabel(label,{exact:true}).setInputFiles(file);await page.waitForFunction(()=>!document.querySelector('[role=status]'));};
try {
  await open('workshop.html');
  await visibleText('把生命周期变化');
  assert.equal(await page.locator('.section').count(),7);
  await page.getByRole('button',{name:'标记完成',exact:true}).first().click();
  assert.equal(await page.locator('progress').getAttribute('value'),'1');
  await page.getByRole('button',{name:'讲师模式',exact:true}).click();
  assert((await page.locator('.instructor[open]').count())>=4);
  for (const name of ['按具体公告期限规划并完成过渡','只用旧代际规则，不叠加区域 VM 规则','不可以，缺少内存、峰值窗口、网络/磁盘与业务约束','先验证 Gen2、NVMe、MANA、镜像、区域/配额，规划受控迁移','不必然，剩余购买承诺、许可和关联费用需评估','只能确认该公告排除，其他政策要单独核验'])
    await page.getByRole('radio',{name,exact:true}).check();
  await page.getByRole('button',{name:'提交并查看解析',exact:true}).click();
  await visibleText('得分 6 / 6');
  await page.evaluate(()=>window.scrollTo(0,0));
  await page.screenshot({path:join(output,'workshop-desktop.png')});
  await page.setViewportSize({width:390,height:844});
  await page.evaluate(()=>window.scrollTo(0,0));
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1),'Workshop overflows mobile viewport');
  await page.screenshot({path:join(output,'workshop-mobile.png')});

  await page.setViewportSize({width:1440,height:1000});
  await open('calculator.html');
  await page.getByRole('button',{name:'加载教学案例',exact:true}).click();
  await run();
  assert.equal(await page.locator('.analysis-detail').count(),6);
  assert((await page.locator('#results').innerText()).includes('4,145.83'));
  await page.locator('.analysis-detail > summary').first().click();
  await visibleText('Standard_D4s_v5');
  await visibleText('870.91');
  await page.screenshot({path:join(output,'calculator-results.png')});
  const [reportDownload]=await Promise.all([page.waitForEvent('download'),page.getByRole('button',{name:'下载 HTML 报告',exact:true}).click()]);
  const reportPath=join(output,'downloaded-report.html');
  await reportDownload.saveAs(reportPath);
  const reportText=await readFile(reportPath,'utf8');
  assert(reportText.includes('VM-001')&&!reportText.includes('demo-web')&&!reportText.includes('案例 A · 电商前端'));
  const reportPage=await context.newPage();
  await reportPage.goto(pathToFileURL(reportPath).href);
  await reportPage.waitForSelector('h1');
  assert((await reportPage.locator('body').innerText()).includes('870.91'));
  assert((await reportPage.locator('body').innerText()).includes('未知 / 待补依据'));
  await reportPage.pdf({path:join(output,'report-print.pdf'),format:'A4',printBackground:true});
  await reportPage.close();
  const [csvDownload]=await Promise.all([page.waitForEvent('download'),page.getByRole('button',{name:'导出 CSV',exact:true}).click()]);
  const csvPath=join(output,'recommendations.csv');await csvDownload.saveAs(csvPath);
  assert((await readFile(csvPath,'utf8')).includes('VM-006'));
  await page.getByLabel('测算模式',{exact:true}).selectOption('customer');
  await run();
  assert((await page.locator('#results').innerText()).includes('未知'));
  assert.equal(await page.locator('#results .metric').nth(3).locator('.value').innerText(),'6');

  await upload('主 VM 用量表',join(root,'test-fixtures','customer-format.xlsx'));
  assert((await page.locator('body').innerText()).includes('有效 1 / 总记录 1'));
  await page.getByText('价格快照 · 已载入 0 条',{exact:true}).click();
  await upload('价格快照 CSV / XLSX',join(root,'test-fixtures','customer-prices.xlsx'));
  await page.getByRole('button',{name:'校验并采用价格表',exact:true}).click();
  await run();
  const customerText=await page.locator('#results').innerText();
  assert(customerText.includes('1,440.00')&&customerText.includes('864.00'),customerText);
  await page.setViewportSize({width:390,height:844});
  await page.evaluate(()=>window.scrollTo(0,0));
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1),'Calculator overflows mobile viewport');
  await page.screenshot({path:join(output,'calculator-mobile.png')});
  await page.getByRole('button',{name:'切换深色主题',exact:true}).click();
  assert.equal(await page.locator('html').getAttribute('data-theme'),'dark');
  await page.screenshot({path:join(output,'calculator-dark.png')});
  assert.equal(await page.evaluate(()=>localStorage.length),0,'Unexpected localStorage persistence');
  assert.equal(await page.evaluate(()=>sessionStorage.length),0,'Unexpected sessionStorage persistence');

  await page.setViewportSize({width:1440,height:1000});
  await upload('主 VM 用量表',join(root,'test-fixtures','invalid.csv'));
  assert((await page.locator('body').innerText()).includes('互斥'));
  await page.getByRole('button',{name:'分析配置与影响 →',exact:true}).click();
  await visibleText('没有有效记录');
  await page.getByLabel('测算模式',{exact:true}).selectOption('scenario');
  await upload('主 VM 用量表',join(root,'test-fixtures','scale-1000.csv'));
  const started=Date.now();await run();
  assert((await page.locator('#results').innerText()).includes('筛选 1000 / 全部 1000'));
  assert.equal(await page.locator('.analysis-detail').count(),25,'Results must be paginated');
  await page.getByRole('button',{name:'下一页',exact:true}).click();
  await visibleText('第 2 / 40 页');
  console.log(`1,000-record offline flow: ${Date.now()-started} ms`);
  await page.getByRole('button',{name:'分析配置与影响 →',exact:true}).click();
  await page.getByRole('button',{name:'取消处理',exact:true}).click();
  await page.waitForTimeout(200);
  assert.equal(await page.locator('#results').count(),0,'Cancelled analysis must not publish partial/stale results');
  assert.equal(await page.locator('[role=status]').count(),0,'Cancelled analysis must release busy state');
  await run();
  assert.equal(await page.locator('.analysis-detail').count(),25,'Analysis must work after cancellation');
  assert.deepEqual(errors,[],'Browser runtime/console errors');
  assert.deepEqual(network,[],'Unexpected HTTP requests while offline');
  console.log('PASS: file:// offline workshop, quiz, CSV/XLSX, both price modes, reports/PDF, mobile/dark, pagination and zero network/storage writes.');
} finally {
  await context.close();
  await browser.close();
}
