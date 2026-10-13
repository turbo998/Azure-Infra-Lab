import { chromium } from 'playwright';
import assert from 'node:assert/strict';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { resolve, join } from 'node:path';
const root=fileURLToPath(new URL('..',import.meta.url)), delivery=resolve(root,'..');
const screenshots=join(delivery,'screenshots');
await mkdir(screenshots,{recursive:true});
const browser=await chromium.launch({executablePath:process.env.BROWSER_EXE||'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',headless:true});
const context=await browser.newContext({offline:true,acceptDownloads:true,colorScheme:'light',viewport:{width:1440,height:1000}});
const errors=[],network=[];
context.on('page',p=>{
  p.on('pageerror',e=>errors.push(e.message));
  p.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  p.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  p.on('dialog',d=>d.accept());
});
const page=await context.newPage();
const langs=['zh-CN','zh-TW','en'];
async function choose(language) {
  const pathname=new URL(page.url()).pathname;
  await page.getByRole('button',{name:`Language: ${language}`,exact:true}).click();
  assert.equal(await page.locator('html').getAttribute('lang'),language);
  assert.equal(new URL(page.url()).pathname,pathname,'Language switching must not navigate to another page');
}
async function noAuthoredChinese() {
  const leftovers=await page.evaluate(()=>{
    const walker=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT);
    const values=[];
    while(walker.nextNode()){
      const node=walker.currentNode, parent=node.parentElement;
      if(!parent||parent.closest('[data-no-i18n],.language-switch,script,style')||parent.tagName==='OPTION')continue;
      if(/[\u3400-\u9fff]/.test(node.textContent||''))values.push(node.textContent?.trim());
    }
    return [...new Set(values)];
  });
  assert.deepEqual(leftovers,[],'English authored content must be fully translated');
}
async function capture(stem) {
  await page.evaluate(()=>window.scrollTo(0,0));
  await page.screenshot({path:join(screenshots,`${stem}-desktop.png`)});
  await page.screenshot({path:join(screenshots,`${stem}-full.png`),fullPage:true});
  await page.setViewportSize({width:390,height:844});
  await page.evaluate(()=>window.scrollTo(0,0));
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1),`${stem}: mobile overflow`);
  await page.screenshot({path:join(screenshots,`${stem}-mobile.png`)});
  await page.setViewportSize({width:1440,height:1000});
}
try{
  await page.goto(pathToFileURL(join(delivery,'workshop.html')).href);
  await page.locator('.section button').first().click();
  await page.locator('.quiz input').first().check();
  for(const language of langs){
    await choose(language);
    const titles={
      'zh-CN':['销售角色','售前角色','服务角色'],
      'zh-TW':['銷售角色','售前角色','服務角色'],
      en:['Sales role','Presales role','Service role'],
    };
    assert.deepEqual(await page.locator('#chapter-0 .role-cards h3').allTextContents(),titles[language]);
    assert.equal(await page.locator('progress').getAttribute('value'),'1');
    assert(await page.locator('.quiz input').first().isChecked(),'Quiz selection must survive language switching');
    if(language==='en')await noAuthoredChinese();
    await capture(`workshop-${language}`);
    await page.locator('#chapter-0 .role-cards').scrollIntoViewIfNeeded();
    await page.screenshot({path:join(screenshots,`workshop-${language}-roles.png`)});
  }
  await page.locator('.top-actions > button.quiet').click();
  assert.equal(await page.locator('html').getAttribute('data-theme'),'dark');
  await page.locator('#chapter-0 .role-cards').scrollIntoViewIfNeeded();
  await page.screenshot({path:join(screenshots,'workshop-en-roles-dark.png')});
  await page.locator('.top-actions > button.quiet').click();
  await page.goto(pathToFileURL(join(delivery,'demo.html')).href);
  for(const language of langs){
    await choose(language);
    if(language==='en')await noAuthoredChinese();
    await capture(`demo-${language}`);
  }
  const demoLink=await page.locator('a.primary').getAttribute('href');
  assert(demoLink.includes('demo=1')&&demoLink.includes('lang=en'));
  await page.locator('a.primary').click();
  await page.waitForSelector('#results',{timeout:60000});
  assert.equal(await page.locator('.analysis-detail').count(),6);
  await page.locator('.analysis-detail > summary').first().click();
  for(const language of langs){
    await choose(language);
    assert.equal(await page.locator('.analysis-detail').count(),6,'Results must survive language switching');
    assert.equal(await page.locator('details.analysis-detail[open]').count(),1,'Expanded cases must remain open');
    assert((await page.locator('#results').innerText()).includes('4,145.83'));
    assert((await page.locator('#results').innerText()).includes('870.91'));
    if(language==='en')await noAuthoredChinese();
    await page.locator('#results').scrollIntoViewIfNeeded();
    await page.screenshot({path:join(screenshots,`calculator-${language}-results.png`)});
    await capture(`calculator-${language}`);
    const [download]=await Promise.all([
      page.waitForEvent('download'),
      page.locator('#results .actions button').first().click(),
    ]);
    const report=join(delivery,'sample-data',language,'live-demo-report.html');
    await download.saveAs(report);
    const text=await readFile(report,'utf8');
    assert(text.includes(`lang="${language}"`));assert(text.includes('870.91'));
    assert(!text.includes('demo-web')&&!text.includes('案例 A'));
    const reportPage=await context.newPage();
    await reportPage.goto(pathToFileURL(report).href);
    await reportPage.waitForSelector('h1');
    await reportPage.screenshot({path:join(screenshots,`report-${language}-desktop.png`)});
    await reportPage.pdf({path:join(delivery,'sample-data',language,'live-demo-report.pdf'),format:'A4',printBackground:true});
    await reportPage.close();
  }
  await choose('en');
  await page.locator('select[aria-label]').selectOption('customer');
  await page.locator('button[data-action="analyze"]').click();
  await page.waitForSelector('#results');
  assert.equal(await page.locator('#results .metric').nth(3).locator('.value').innerText(),'6','Customer mode must reject demo prices');
  for(const language of langs){
    await choose(language);
    await page.locator('.dropzone input[type=file]').setInputFiles(join(delivery,'sample-data',language,'sample-vms.xlsx'));
    await page.waitForFunction(()=>!document.querySelector('[role=status]'));
    assert.equal(await page.locator('.analysis-detail').count(),0,'New file must clear stale results');
    const body=await page.locator('body').innerText();
    assert(/6.*6/.test(body),'Sample workbook must validate all six rows');
  }
  assert.equal(await page.evaluate(()=>localStorage.length),0);
  assert.equal(await page.evaluate(()=>sessionStorage.length),0);
  assert.deepEqual(errors,[]);assert.deepEqual(network,[]);
  await writeFile(join(screenshots,'capture-manifest.json'),JSON.stringify({
    capturedAt:new Date().toISOString(),browser:'Microsoft Edge / Playwright',mode:'file://, offline',
    languages:langs,desktop:{width:1440,height:1000},mobile:{width:390,height:844},
    scenarios:['same-page language switching','preserved progress/quiz/data/results','automatic six-case demo','HTML/PDF exports','all sample XLSX imports','rejected synthetic customer prices'],
    syntheticData:true,httpRequests:0,runtimeErrors:0,
  },null,2));
  console.log('PASS: same-page trilingual workshop/demo/calculator, state preservation, samples, localized HTML/PDF reports, desktop/mobile screenshots and zero network/storage writes.');
}finally{await context.close();await browser.close();}
