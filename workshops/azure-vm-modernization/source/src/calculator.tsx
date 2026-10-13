import { useEffect, useMemo, useRef, useState } from 'react';
import { DEFAULT_OPTIONS, FIELDS, PRICE_HEADERS, type Analysis, type Issue, type Options, type Price, type RawRow, type Vm } from './model';
import { DEMO_PRICES, DEMO_VMS } from './data';
import { analyze, isDate, summarize } from './engine';
import { automaticMapping, fieldDescription, mergeSupplement, readFile, toCsv, validatePrices, validateVms, type Sheet } from './import';
import { reportCsv, reportHtml, type Quality } from './report';
import { download, Footer, Header, money, mount, Notice, Rules, Sources } from './ui';
import { getLanguage, priceEvidence, t, useLanguage } from './i18n';

function Issues({ items, title }: { items: Issue[]; title: string }) {
  return items.length ? <details open><summary>{title} · {items.length} 项</summary><div className="detail-body error-list"><ul>{items.map((i,n) => <li key={n}>第 {i.row} 行 / <strong>{i.field}</strong>：{i.message}</li>)}</ul></div></details> : null;
}
function CandidateCard({ a, index }: { a: Analysis; index: number }) {
  const c = a.candidates[index];
  return <article className="candidate"><span className="badge accent">{index === 0 ? '默认首候选' : '替代路径'} · v{c.sku.generation}</span><h4>{c.sku.name}</h4>
    <span className="badge">{c.downsizing ? '缩容投影候选 / 非安全保证' : '不降低 CPU/内存容量'}</span>
    <ul>{c.reasons.map(r=><li key={r}>{r}</li>)}</ul>
    <p className="price">{money(c.cost,a.vm.currency)}</p><small>相同用量计算费；不含未输入的存储/许可/网络/税费</small>
    <p style={{marginTop:12}}>含剩余承诺：<strong>{money(c.totalWithCommitment,a.vm.currency)}</strong><br/>条件差额：<strong>{money(c.difference,a.vm.currency)}</strong></p>
    <small data-no-i18n>{c.source?priceEvidence(c.source):t('目标价格依据不足')}</small><details><summary>阻断与部署前验证 ({c.blockers.length})</summary><div className="detail-body"><ul>{c.blockers.map(b=><li key={b}>{b}</li>)}</ul></div></details>
    <a href={c.sku.source} target="_blank" rel="noreferrer">官方规格 ↗</a>
  </article>;
}
function Calculator() {
  useLanguage();
  const [sheets,setSheets] = useState<Sheet[]>([]);
  const [sheetIndex,setSheetIndex] = useState(0);
  const [mapping,setMapping] = useState<Record<string,string>>({});
  const [fileName,setFileName] = useState('');
  const [prices,setPrices] = useState<Price[]>([]);
  const [priceSheets,setPriceSheets] = useState<Sheet[]>([]);
  const [priceSheetIndex,setPriceSheetIndex] = useState(0);
  const [priceIssues,setPriceIssues] = useState<Issue[]>([]);
  const [options,setOptions] = useState<Options>(DEFAULT_OPTIONS);
  const [result,setResult] = useState<Analysis[] | null>(null);
  const [quality,setQuality] = useState<Quality | null>(null);
  const [error,setError] = useState('');
  const [busy,setBusy] = useState('');
  const [consent,setConsent] = useState(false);
  const [filter,setFilter] = useState('全部');
  const [resultPage,setResultPage] = useState(0);
  const [editIndex,setEditIndex] = useState(0);
  const operation = useRef(0);
  const demoAnalyzed = useRef(false);
  const sheet = sheets[sheetIndex];
  const validated = useMemo(()=>sheet ? validateVms(sheet,mapping) : {vms:[],issues:[],warnings:[]},[sheet,mapping]);
  const changed = () => { operation.current++;setBusy('');setResult(null);setQuality(null);setConsent(false);setError(''); };
  const setOption = <K extends keyof Options>(key: K, value: Options[K]) => {
    setOptions(o=>({...o,[key]:value}));
    if (!['title','redact'].includes(key)) {operation.current++;setBusy('');setResult(null);setQuality(null);}
  };
  const useSheet = (index: number) => {setSheetIndex(index);setMapping(automaticMapping(sheets[index].headers));setEditIndex(0);changed();};
  async function load(file: File | undefined, type: 'vm' | 'price' | 'supplement') {
    if (!file) return;
    const token = ++operation.current;
    setBusy('读取与解析文件…'); setError('');
    try {
      const incoming = await readFile(file);
      if (token !== operation.current) return;
      if (type === 'price') {setPriceSheets(incoming);setPriceSheetIndex(0);setPriceIssues([]);}
      else if (type === 'supplement') {
        if (!sheet) throw new Error('请先导入主 VM 表。');
        if (incoming.length !== 1) throw new Error('补充资料请导出为单个工作表后导入，避免静默选择错误的表。');
        const merged = mergeSupplement(sheet,incoming[0],mapping,automaticMapping(incoming[0].headers));
        setSheets([merged]);setSheetIndex(0);setMapping(automaticMapping(merged.headers));setEditIndex(0);changed();
      } else {
        setSheets(incoming);setSheetIndex(0);setMapping(automaticMapping(incoming[0].headers));setFileName(file.name);setEditIndex(0);
        setPrices([]);setPriceSheets([]);setPriceIssues([]);changed();
      }
    } catch (e) {
      if (token === operation.current) setError(e instanceof Error ? e.message : '导入失败，请检查文件。');
    } finally {if (token === operation.current) setBusy('');}
  }
  function demo() {
    if (sheet && !window.confirm(t('加载教学案例将替换当前主表和价格。尚未导出的数据不会自动保存，是否继续？'))) return;
    const rows = DEMO_VMS.map(v=>Object.fromEntries(FIELDS.map(f=>[f.key,v[f.key] === undefined ? '' : String(v[f.key])])));
    const newSheet = {name:'教学模拟',headers:FIELDS.map(f=>f.key),rows};
    setSheets([newSheet]);setSheetIndex(0);setMapping(automaticMapping(newSheet.headers));
    setPrices(DEMO_PRICES);setFileName('六个教学模拟案例');setPriceSheets([]);setPriceIssues([]);
    setOptions({...DEFAULT_OPTIONS,title:options.title,redact:options.redact});setEditIndex(0);changed();
  }
  useEffect(()=>{
    if (new URLSearchParams(location.search).get('demo')==='1') demo();
  },[]);
  function edit(field: keyof Vm, value: string) {
    if (!sheet) return;
    const column = mapping[field] || field;
    const updated: Sheet = {...sheet,headers:sheet.headers.includes(column)?sheet.headers:[...sheet.headers,column],
      rows:sheet.rows.map((r,i)=>i===editIndex?{...r,[column]:value}:r)};
    setSheets(s=>s.map((s,i)=>i===sheetIndex?updated:s));setMapping(m=>({...m,[field]:column}));changed();
  }
  function applyPrices() {
    changed();
    const v = validatePrices(priceSheets[priceSheetIndex]);
    setPriceIssues(v.issues);
    if (!v.issues.length) {setPrices(v.prices);setError('');}
    else setError('价格表存在错误，未更新原有价格。请修正后重新导入。');
  }
  async function run() {
    setError('');
    if (!isDate(options.date)) return setError('请输入有效评估日期。');
    if (![options.cpuTarget,options.memoryTarget,options.batchTarget].every(n=>Number.isFinite(n)&&n>0&&n<=95) ||
      !Number.isInteger(options.minDays) || options.minDays<7 || options.minDays>365 ||
      !Number.isFinite(options.legacyPercent) || options.legacyPercent<0 || options.legacyPercent>100)
      return setError('资源目标须 >0 且 ≤95%；观察窗须 7–365 整数天；情景涨幅须 0–100%。');
    if (!sheet || !validated.vms.length) return setError('没有有效记录，请先导入并完成映射/校验。');
    if (validated.issues.length && !consent) return setError('存在错误记录。请修正，或明确确认只分析有效记录。');
    const token = ++operation.current;
    const results: Analysis[] = [];
    setResult(null);setQuality(null);
    try {
      for (let i=0;i<validated.vms.length;i++) {
        if (i % 50 === 0) {
          setBusy(`本地分析 ${i} / ${validated.vms.length} 条…`);
          await new Promise<void>(resolve=>setTimeout(resolve,0));
          if (token!==operation.current) return;
        }
        results.push(analyze(validated.vms[i],prices,options));
      }
      if (token!==operation.current) return;
      setResult(results);setResultPage(0);
      setQuality({total:sheet.rows.length,valid:validated.vms.length,issues:validated.issues,warnings:validated.warnings,file:fileName});
      setTimeout(()=>document.getElementById('results')?.scrollIntoView({behavior:'smooth'}),50);
    } catch (e) {
      if (token===operation.current) setError(`分析失败，未采纳部分结果：${e instanceof Error ? e.message : '未知分析错误'}`);
    } finally {
      if (token===operation.current) setBusy('');
    }
  }
  useEffect(()=>{
    if (new URLSearchParams(location.search).get('demo')==='1' && validated.vms.length && !demoAnalyzed.current) {
      demoAnalyzed.current=true;
      void run();
    }
  },[validated]);
  function reset() {
    if (sheet && !window.confirm(t('清除当前浏览器中的主表、价格及结果？请先导出所需文件。'))) return;
    operation.current++;setBusy('');setSheets([]);setPrices([]);setPriceSheets([]);setPriceIssues([]);setMapping({});setFileName('');changed();
  }
  const groups = result ? summarize(result) : [];
  const visible = (result ?? []).filter(a=>filter==='全部' || (filter==='有候选'&&a.candidates.length) ||
    (filter==='生命周期期限'&&a.lifecycle.date) || (filter==='价格依据不足'&&a.noChange===null) ||
    (filter==='需准备/专项'&&a.wave.startsWith('准备')));
  const upload = (type: 'vm'|'price'|'supplement', label: string) => <label>{label}<input type="file" accept=".csv,.xlsx" disabled={!!busy} onChange={e=>{const file=e.target.files?.[0];e.target.value='';void load(file,type);}}/></label>;
  return <><Header active="calculator"/><main className="workspace">
    <div className="page-heading"><div><div className="eyebrow">OFFLINE ASSESSMENT / LOCAL FIRST</div><h1>把客户用量，<span className="accent">变成可解释的建议。</span></h1><p>识别生命周期与价格影响，比较候选配置，保留每一项前提与不确定性。</p></div><div className="actions"><button onClick={demo} disabled={!!busy}>加载教学案例</button><button onClick={reset}>清除本地数据</button></div></div>
    <Notice><strong>数据不离开浏览器。</strong>无登录、无上传、无自动保存、无 Azure 变更权限。CSV/XLSX 均本地解析；20 MiB / 20,000 行 / 250 列保护上限。报告外发前仍需审查。</Notice>
    <div className="stepbar"><strong>01 导入与校验</strong><span>→</span><strong>02 设定口径</strong><span>→</span><strong>03 比较与报告</strong></div>
    {error && <Notice error><strong>未完成操作：</strong>{error}</Notice>}
    {busy && <Notice><span role="status">{busy}</span> <button onClick={()=>{operation.current++;setBusy('');}}>取消处理</button><small>取消不采纳新结果；解析仍受保护上限约束。</small></Notice>}
    <section className="section" style={{borderTop:0,paddingTop:0}}><div className="section-heading"><div><span className="section-index">01 / IMPORT</span><h2>导入，不猜测字段。</h2><p>逐台 VM 与明确聚合组均可；原始账单先汇总，计量项 Quantity 不等于实例数。</p></div>
      <div className="actions"><button onClick={()=>download('VM-用量模板.csv',toCsv([],FIELDS.map(f=>f.key)),'text/csv;charset=utf-8')}>下载 VM 模板</button><button onClick={()=>download('价格快照模板.csv',toCsv([],PRICE_HEADERS),'text/csv;charset=utf-8')}>价格模板</button><button onClick={()=>download(`sample-vms-${getLanguage()}.csv`,toCsv(DEMO_VMS.map(v=>({...v,name:t(v.name),priceSource:t(v.priceSource??'')})),FIELDS.map(f=>f.key)),'text/csv;charset=utf-8')}>下载案例数据</button><button onClick={()=>download(`sample-prices-${getLanguage()}.csv`,toCsv(DEMO_PRICES.map(p=>({...p,source:t(p.source)})),PRICE_HEADERS),'text/csv;charset=utf-8')}>下载模拟价格</button></div></div>
      <div className="dropzone"><div className="upload-icon" aria-hidden="true">↥</div><h3>选择客户 CSV / Excel 文件</h3><p className="muted">UTF-8 CSV 或 XLSX；不支持 XLS、加密文件或公式单元格。日期用 YYYY-MM-DD。</p>{upload('vm','主 VM 用量表')}</div>
      {sheet && <>
        <div className="form-grid two" style={{marginTop:20}}><label>选择工作表<select value={sheetIndex} onChange={e=>useSheet(Number(e.target.value))}>{sheets.map((s,i)=><option key={i} value={i} data-no-i18n>{s.name} · {s.rows.length}</option>)}</select><small>仅列出含数据记录的工作表；空表及仅有表头的表不参与分析。</small></label><div><p><strong data-no-i18n={fileName!=='六个教学模拟案例'}>{fileName}</strong><br/><small>有效 {validated.vms.length} / 总记录 {sheet.rows.length}；错误 {validated.issues.length} 项</small></p></div></div>
        <details><summary>字段映射 · 自动匹配 {Object.values(mapping).filter(Boolean).length}/{FIELDS.length} 项（点击调整）</summary><div className="detail-body">
          {['必填','部署','用量','性能','兼容','商务','价格','存储'].map(group=><details key={group} open={group==='必填'}><summary>{group}</summary><div className="detail-body form-grid">{FIELDS.filter(f=>f.group===group).map(f=><label key={f.key}>{f.label}{f.required?' *':''}<select value={mapping[f.key]??''} onChange={e=>{setMapping(m=>({...m,[f.key]:e.target.value}));changed();}}><option value="">未映射 / 未知</option>{sheet.headers.map(h=><option key={h} value={h}>{h}</option>)}</select><small>{f.hint}</small></label>)}</div></details>)}
        </div></details>
        <details><summary>预览前 5 行原始数据</summary><div className="detail-body table-wrap"><table><thead><tr>{sheet.headers.map(h=><th key={h} data-no-i18n>{h}</th>)}</tr></thead><tbody>{sheet.rows.slice(0,5).map((r,i)=><tr key={i}>{sheet.headers.map(h=><td key={h} data-no-i18n>{r[h]}</td>)}</tr>)}</tbody></table></div></details>
        <Issues items={validated.issues} title="需修正的错误"/><Issues items={validated.warnings} title="完整性提示"/>
        {validated.issues.length>0 && <label className="check"><input type="checkbox" checked={consent} onChange={e=>setConsent(e.target.checked)}/>我已确认，仅分析有效记录；报告列明未分析数量与错误。</label>}
        <details><summary>补充 / 修正单条记录（本地编辑，不改原文件）</summary><div className="detail-body">
          <label>选择原始数据记录<select value={editIndex} onChange={e=>setEditIndex(Number(e.target.value))}>{sheet.rows.map((r,i)=><option key={i} value={i} data-no-i18n>{i+2} · {r[mapping.name] || r[mapping.id] || t('标识缺失')}</option>)}</select></label>
          {['必填','部署','用量','性能','兼容','商务','价格','存储'].map(g=><details key={g}><summary>{g}</summary><div className="detail-body form-grid">{FIELDS.filter(f=>f.group===g).map(f=><label key={f.key}>{f.label}<input value={sheet.rows[editIndex]?.[mapping[f.key]] ?? ''} onChange={e=>edit(f.key,e.target.value)} aria-label={`编辑 ${f.label}`}/><small>{f.hint}</small></label>)}</div></details>)}
          <div className="actions"><button onClick={()=>download('已补充-VM用量.csv',toCsv(sheet.rows.map(r=>Object.fromEntries(FIELDS.map(f=>[f.key,r[mapping[f.key]]??''])))),'text/csv;charset=utf-8')}>下载已补充数据</button></div>
        </div></details>
        <details><summary>通过稳定标识关联补充资料</summary><div className="detail-body"><p>单工作表 CSV/XLSX，使用标准字段/可识别列名。必须唯一标识匹配；冲突、重复和无法关联的记录会拒绝合并，不静默覆盖。</p>{upload('supplement','补充指标 / 合同 / 兼容资料')}</div></details>
      </>}
      <details><summary>价格快照 · 已载入 {prices.length} 条</summary><div className="detail-body">
        <p>使用价格模板导入同云、区域、SKU、OS、币种和购买方式的小时费率。客户模式要求 <code>basis=effective</code>、<code>includesUpdate=yes</code> 与有效日期；模拟价格不会被当作客户价。</p>
        {upload('price','价格快照 CSV / XLSX')}
        {priceSheets.length>0 && <div className="form-grid two"><label>价格工作表<select value={priceSheetIndex} onChange={e=>setPriceSheetIndex(Number(e.target.value))}>{priceSheets.map((s,i)=><option key={i} value={i}>{s.name} · {s.rows.length} 行</option>)}</select></label><div className="actions"><button onClick={applyPrices}>校验并采用价格表</button></div></div>}
        <Issues items={priceIssues} title="价格表错误"/>
        <small>价格有效期重叠会在匹配时标为冲突。公开零售 API 仅商业云参考，价格不证明 SKU 可部署；离线更新需用户自行提供快照。</small>
      </div></details>
    </section>
    <section className="section"><div className="section-heading"><div><span className="section-index">02 / ASSUMPTIONS</span><h2>让假设看得见。</h2><p>分析日选择有效费率，源期间用量固定不变。不是跨期账单预测。</p></div></div>
      <div className="card"><div className="form-grid">
        <label>测算模式<select aria-label="测算模式" value={options.mode} onChange={e=>setOption('mode',e.target.value as Options['mode'])}><option value="scenario">培训情景 · 非官方报价</option><option value="customer">客户价格依据</option></select></label>
        <label>评估日期<input type="date" value={options.date} onChange={e=>setOption('date',e.target.value)}/></label>
        <label>报告标题<input value={options.title===DEFAULT_OPTIONS.title?t(options.title):options.title} onChange={e=>setOption('title',e.target.value)}/></label>
        <label>用户型 CPU / 网络目标 %<input type="number" min={1} max={95} value={options.cpuTarget} onChange={e=>setOption('cpuTarget',Number(e.target.value))}/></label>
        <label>用户型内存目标 %<input type="number" min={1} max={95} value={options.memoryTarget} onChange={e=>setOption('memoryTarget',Number(e.target.value))}/></label>
        <label>批处理资源目标 %<input type="number" min={1} max={95} value={options.batchTarget} onChange={e=>setOption('batchTarget',Number(e.target.value))}/></label>
        <label>缩容最短观察窗（天）<input type="number" min={7} max={365} value={options.minDays} onChange={e=>setOption('minDays',Number(e.target.value))}/></label>
        <label>旧代际情景涨幅 %<input type="number" min={0} max={100} value={options.legacyPercent} disabled={options.mode==='customer'} onChange={e=>setOption('legacyPercent',Number(e.target.value))}/></label>
        <label className="check"><input type="checkbox" checked={options.redact} onChange={e=>setOption('redact',e.target.checked)}/>报告省略名称、资源/订阅标识</label>
      </div><p className="muted" style={{marginTop:20}}>默认 CPU/网络 40%、内存 60%、批处理 80% 参考 Advisor 的资源余量目标；30 天观察窗是本工具的保守默认。须覆盖业务峰值，不复刻 Advisor 的机器学习或采样流程。</p></div>
      {options.mode==='scenario' ? <Notice><strong>培训情景：</strong>涨幅与商业规则尚未充分公开核验。示例单价全部模拟；未含调整的基准按规则投影，已含调整的有效费率不重复乘涨幅。</Notice> : <Notice><strong>客户模式：</strong>不会自动应用邮件涨幅。请导入匹配评估日的有效价格或填写行内有效费率，RI/SP 剩余承诺必须另审查；缺少依据时仅给技术建议。</Notice>}
      <Rules/><Sources/>
      <div className="actions" style={{marginTop:24}}><button className="primary" data-action="analyze" onClick={run} disabled={!!busy}>分析配置与影响 →</button><small>不会修改任何 Azure VM。</small></div>
    </section>
    {result && quality && <section className="section" id="results"><div className="section-heading"><div><span className="section-index">03 / FINDINGS</span><h2>建议，带着依据一起交付。</h2><p>所有候选都有待验证前提；缺失价格或承诺成本不伪造节省。</p></div>
      <div className="actions"><button onClick={()=>download(`Azure-VM-report-${getLanguage()}.html`,reportHtml(result,options,quality),'text/html;charset=utf-8')}>下载 HTML 报告</button><button onClick={()=>download(`Azure-VM-recommendations-${getLanguage()}.csv`,reportCsv(result,options),'text/csv;charset=utf-8')}>导出 CSV</button></div></div>
      <div className="grid four"><div className="metric"><small>有效记录 / 总导入</small><div className="value">{result.length} <small>/ {quality.total}</small></div><small>未分析 {quality.total-quality.valid} 条</small></div><div className="metric"><small>实例数</small><div className="value">{result.reduce((n,a)=>n+a.vm.count,0)}</div><small>按显式实例数，非账单行数</small></div><div className="metric"><small>有候选配置</small><div className="value">{result.filter(a=>a.candidates.length).length}</div><small>候选不等于可直接部署</small></div><div className="metric"><small>缺少源价格依据</small><div className="value">{result.filter(a=>a.noChange===null).length}</div><small>未知不当作零</small></div></div>
      <div className="table-wrap"><table><thead><tr><th>云 / 币种 / 口径</th><th>有依据的不调整计算费</th><th>覆盖</th><th>首候选条件差额</th><th>差额覆盖</th></tr></thead><tbody>{groups.map(g=><tr key={g.key}><td>{g.key}</td><td>{g.known?money(g.cost,g.currency):'未知'}</td><td>{g.known}/{g.total}</td><td>{g.comparable?money(g.difference,g.currency):'未知'}</td><td>{g.comparable}/{g.total}</td></tr>)}</tbody></table></div>
      <small>只汇总有依据的子集；各币种和成本口径独立。条件计算费差额不等于总账单节省。</small>
      <div className="results-header"><h3>逐记录影响与候选</h3><div className="pills">{['全部','生命周期期限','有候选','价格依据不足','需准备/专项'].map(f=><button key={f} className={filter===f?'selected':''} onClick={()=>{setFilter(f);setResultPage(0);}}>{f}</button>)}</div></div>
      <p className="muted">筛选 {visible.length} / 全部 {result.length}，每页最多 25 条。报告导出始终包括全部已分析记录；HTML 报告可直接离线打开并打印为 PDF。</p>
      {visible.length>25 && <div className="actions no-print"><button disabled={resultPage===0} onClick={()=>setResultPage(p=>p-1)}>上一页</button><span>第 {resultPage+1} / {Math.ceil(visible.length/25)} 页</span><button disabled={(resultPage+1)*25>=visible.length} onClick={()=>setResultPage(p=>p+1)}>下一页</button></div>}
      {visible.slice(resultPage*25,(resultPage+1)*25).map(a=><details className="analysis-detail" key={a.vm.id}><summary><div><strong data-no-i18n={!DEMO_VMS.some(v=>v.name===a.vm.name)}>{a.vm.name}</strong><small className="mono" style={{display:'block'}}>{a.vm.sku} · {a.vm.region} · {a.vm.count} 实例</small></div><div><span className="badge">{a.lifecycle.stage}{a.lifecycle.date?` / ${a.lifecycle.date}`:''}</span><span className="badge">{a.candidates.length ? `${a.candidates.length} 条候选路径` : '需专项/补数'}</span></div></summary><div className="detail-body">
        <p><strong>{a.lifecycle.note}</strong></p><p>{a.effect.reason}<br/><small>规则 {a.effect.rule} · <span data-no-i18n>{priceEvidence(a.priceEvidence)}</span> · {a.priceExplanation}</small></p>
        <div className="grid three"><div className="card"><small>源基准计算费</small><h3>{money(a.baseline,a.vm.currency)}</h3></div><div className="card"><small>不调整 / 相同用量</small><h3>{money(a.noChange,a.vm.currency)}</h3></div><div className="card"><small>关联存储（单独列出）</small><h3>{money(a.storageFuture,a.vm.currency)}</h3><small>{a.storageEffect.reason}</small></div></div>
        <p style={{marginTop:20}}><span className="badge accent">{a.wave}</span></p>
        <div className="grid three">{a.candidates.map((c,i)=><CandidateCard key={c.sku.name} a={a} index={i}/>)}</div>
        <Notice><ul>{a.notes.map(n=><li key={n}>{n}</li>)}</ul></Notice>
      </div></details>)}
    </section>}
    <Footer/>
  </main></>;
}
mount(<Calculator/>);
