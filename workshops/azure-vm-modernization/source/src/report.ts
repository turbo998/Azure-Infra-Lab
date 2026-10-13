import css from './style.css?inline';
import { VERSION, SOURCES } from './data';
import { summarize } from './engine';
import { toCsv } from './import';
import type { Analysis, Issue, Options } from './model';
import { getLanguage, localizeMarkup, priceEvidence, t } from './i18n';

export type Quality = { total: number; valid: number; issues: Issue[]; warnings: Issue[]; file: string };
export const escapeHtml = (s: unknown) => String(s ?? '').replace(/[&<>"']/g, c => ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;' })[c]!);
const money = (n: number | null, c?: string) => n === null ? t('未知 / 待补依据') : `${c ?? ''} ${n.toFixed(2)}`;
const list = (items: string[]) => `<ul>${items.map(x => `<li>${escapeHtml(t(x))}</li>`).join('')}</ul>`;

export function reportCsv(rows: Analysis[], o: Options): string {
  const records = rows.map((a,i) => ({
    '评估记录': o.redact ? `VM-${String(i+1).padStart(3,'0')}` : a.vm.name,
    '资源标识': o.redact ? '' : a.vm.id, '订阅': o.redact ? '' : a.vm.subscription,
    '模式': o.mode === 'scenario' ? '培训情景（非报价）' : '客户价格依据',
    '评估日': o.date, 'SKU': a.vm.sku, '系列': a.series, '云': a.vm.cloud, '区域': a.vm.region,
    '实例数': a.vm.count, '成本口径': a.vm.costBasis, '币种': a.vm.currency,
    '生命周期': a.lifecycle.stage, '退役日': a.lifecycle.date, '价格规则': a.effect.rule,
    '规则说明': a.effect.reason, '源基准计算费': a.baseline, '不调整计算费': a.noChange,
    '关联存储成本': a.storageFuture, '首候选': a.candidates[0]?.sku.name,
    '候选计算费': a.candidates[0]?.cost, '候选含剩余承诺成本': a.candidates[0]?.totalWithCommitment,
    '条件计算费差额（非总账单节省）': a.candidates[0]?.difference,
    '波次': a.wave, '阻断项': a.candidates[0]?.blockers.join('；'),
    '注意事项': a.notes.join('；'), '资料版本': VERSION,
  }));
  const narrative = new Set(['模式','生命周期','规则说明','波次','阻断项','注意事项','资料版本']);
  return toCsv(records.map(record=>Object.fromEntries(Object.entries(record).map(([key,value])=>
    [t(key),narrative.has(key)&&typeof value==='string'?t(value):value]))));
}

export function reportHtml(rows: Analysis[], o: Options, quality: Quality): string {
  const protectedValues: string[] = [];
  // Keep imported values out of text localization, including escaped HTML-like customer names.
  const esc = (value: unknown) => { const index=protectedValues.push(escapeHtml(value))-1; return `\uE000${index}\uE001`; };
  const title = o.redact ? t('脱敏 Azure VM 现代化评估') : o.title;
  const totals = summarize(rows);
  const instances = rows.reduce((n,a) => n+a.vm.count,0);
  const cores = rows.reduce((n,a) => n+(a.vm.vcpus === undefined ? 0 : a.vm.vcpus*a.vm.count),0);
  const knownCores = rows.filter(a => a.vm.vcpus !== undefined).length;
  const distribution = (key: 'region' | 'series') => {
    const groups = new Map<string,number>();
    rows.forEach(a => { const k = key === 'region' ? a.vm.region : a.series ?? t('待核验'); groups.set(k,(groups.get(k) ?? 0)+a.vm.count); });
    return [...groups].map(([k,n]) => `<div class="bar-row"><span>${esc(k)}</span><div class="bar-track"><div class="bar-fill" style="width:${instances ? n/instances*100 : 0}%"></div></div><span>${n}</span></div>`).join('');
  };
  const html = `<!doctype html><html lang="${getLanguage()}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<script>(()=>{const p=new URLSearchParams(window.location.search).get("scoutTheme");document.documentElement.setAttribute("data-theme",p||(window.matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light"));})();</script>
<title>${esc(title)}</title><style>${css}</style></head><body><main class="report">
<div class="print-toolbar"><span class="eyebrow">AZURE VM / LOCAL ASSESSMENT REPORT</span><button onclick="window.print()">打印 / 保存 PDF</button></div>
<h1>${esc(title)}</h1><p class="lead">从适用范围到迁移前提，保留每一项依据与不确定性。</p>
<p><span class="badge accent">${o.mode === 'scenario' ? '培训情景 · 非官方报价' : '客户价格依据 · 条件分析'}</span><span class="badge">评估日 ${esc(o.date)}</span><span class="badge">${esc(t(VERSION))}</span></p>
<div class="notice"><strong>计算口径：</strong>采用源用量固定不变、评估日有效费率的 run-rate 对比，不模拟跨月真实账单。仅包含有依据的计算资源费和明确列出的存储；未输入的许可、网络、税费等不在范围内。价格与配额/容量不是实时数据，任何候选都需性能验证和部署前核验。${o.mode === 'scenario' ? '邮件具体涨幅、商业处理和 v4 限制解除细节尚未充分公开核验，情景不是已确认政策。' : '零售价不代表合同净价；缺少有效价格时不填金额。'}</div>
<p><strong>本次参数：</strong>用户型 CPU/网络目标 ${o.cpuTarget}%、内存目标 ${o.memoryTarget}%；批处理目标 ${o.batchTarget}%；最短观察窗 ${o.minDays} 天且须覆盖业务峰值。${o.mode === 'scenario' ? `旧代际情景 ${o.legacyPercent}%，七区域比例与精确排除规则按版本化清单。` : '不自动使用邮件调价情景。'}</p>
<div class="grid four"><div class="metric"><small>分析有效记录</small><div class="value">${rows.length}</div><small>总导入 ${quality.total}；未分析 ${quality.total-quality.valid}</small></div><div class="metric"><small>已知实例数</small><div class="value">${instances}</div><small>不是账单行数</small></div><div class="metric"><small>显式输入核心数</small><div class="value">${cores}</div><small>记录覆盖 ${knownCores}/${rows.length}；未知不视为零</small></div><div class="metric"><small>生命周期期限记录</small><div class="value">${rows.filter(a=>a.lifecycle.date).length}</div><small>按精确系列/云范围判断</small></div></div>
<section class="section"><h2>数据质量与金额覆盖</h2><p>输入：${o.redact ? '本地导入（文件标识已省略）' : esc(quality.file)}。导入错误 ${quality.issues.length} 项，提示 ${quality.warnings.length} 项。未知金额未当作零计入。</p>
<div class="table-wrap"><table><thead><tr><th>云 / 币种 / 成本口径</th><th>有依据的不调整计算费</th><th>金额覆盖</th><th>可比较条件差额</th><th>差额覆盖</th></tr></thead><tbody>${totals.map(g=>`<tr><td>${esc(g.key)}</td><td>${g.known ? esc(money(g.cost,g.currency)) : '未知'}</td><td>${g.known}/${g.total} 记录</td><td>${g.comparable ? esc(money(g.difference,g.currency)) : '未知'}</td><td>${g.comparable}/${g.total}；仅首候选</td></tr>`).join('')}</tbody></table></div>
<p class="muted">各分组独立，不进行自动汇率转换；有依据的子集不能代表全量账单。差额可能为负，且不是可兑现总账单节省。</p>
${quality.issues.length || quality.warnings.length ? `<details open><summary>导入质量记录</summary><div class="detail-body">${list([...quality.issues.map(i=>`错误 · 第 ${i.row} 行 / ${i.field}：${i.message}`),...quality.warnings.map(i=>`提示 · 第 ${i.row} 行 / ${i.field}：${i.message}`)])}</div></details>` : ''}</section>
<section class="section"><h2>实例分布</h2><div class="grid"><div class="card"><h3>区域</h3>${distribution('region')}</div><div class="card"><h3>识别系列</h3>${distribution('series')}</div></div></section>
<section class="section"><h2>逐记录建议与影响矩阵</h2>${rows.map((a,i)=>{
    const name = o.redact ? `VM-${String(i+1).padStart(3,'0')}` : a.vm.name;
    return `<article class="report-row"><span class="badge">${esc(t(a.wave))}</span><h3>${esc(name)}</h3>
<p class="mono">${esc(a.vm.sku)} · ${esc(a.vm.cloud)} / ${esc(a.vm.region)} · ${a.vm.count} 实例</p>
${o.redact ? '' : `<p>资源：${esc(a.vm.id)}；订阅：${esc(a.vm.subscription)}</p>`}
<p>源期间：${esc(a.vm.periodStart || t('未提供'))} 至 ${esc(a.vm.periodEnd || t('未提供'))}（结束日不包含）；${a.vm.hoursTotal !== undefined ? `实例小时总量 ${a.vm.hoursTotal}` : a.vm.hoursPerVM !== undefined ? `每实例 ${a.vm.hoursPerVM} 小时 × ${a.vm.count}` : '小时用量未知'}。</p>
<p>性能依据：源 ${esc(a.vm.vcpus ?? t('未知'))} vCPU / ${esc(a.vm.memoryGiB ?? t('未知'))} GiB；CPU P95 ${esc(a.vm.cpuP95 ?? t('未知'))}%，内存 P99 ${esc(a.vm.memoryP99 ?? t('未知'))}%，发送网络 P95 ${esc(a.vm.networkP95Mbps ?? t('未知'))} Mbps；观察 ${esc(a.vm.observationDays ?? t('未知'))} 天，峰值覆盖 ${a.vm.peakCovered === true ? '已确认' : a.vm.peakCovered === false ? '未覆盖' : '未知'}；类型 ${esc(a.vm.workload)}。</p>
<p>商务依据：${esc(a.vm.agreement)} / ${esc(a.vm.purchase)}；RI 覆盖 ${esc(a.vm.riCoverage ?? t('未知'))}%，到期 ${esc(a.vm.riEnd ?? t('未提供'))}；EA enrollment 续约 ${esc(a.vm.eaRenewal ?? t('未提供'))}。源/目标不自动继承承诺折扣。</p>
<p><strong>${esc(t(a.lifecycle.stage))} ${esc(a.lifecycle.date ?? '')}</strong> · ${esc(t(a.lifecycle.note))}</p>
<p>规则 ${esc(a.effect.rule)}：${esc(t(a.effect.reason))}<br>存储规则 ${esc(a.storageEffect.rule)}：${esc(t(a.storageEffect.reason))}</p>
<div class="table-wrap"><table><thead><tr><th>源基准计算费</th><th>不调整计算费</th><th>关联存储情景/有效成本</th><th>价格依据</th></tr></thead><tbody><tr><td>${esc(money(a.baseline,a.vm.currency))}</td><td>${esc(money(a.noChange,a.vm.currency))}</td><td>${esc(money(a.storageFuture,a.vm.currency))}</td><td>${o.redact ? `${esc(t(a.vm.priceKind ?? '未提供'))}；原始标题已省略，需回查源资料。` : esc(`${priceEvidence(a.priceEvidence)}; ${t(a.priceExplanation)}`)}</td></tr></tbody></table></div>
${a.candidates.length ? `<div class="grid three">${a.candidates.map((c,j)=>`<div class="candidate"><span class="badge">${j===0?'默认首候选':'替代路径'} / v${c.sku.generation}</span><h4>${esc(c.sku.name)}</h4>${list(c.reasons)}
<p>计算费：<strong>${esc(money(c.cost,a.vm.currency))}</strong><br>含已提供剩余承诺：${esc(money(c.totalWithCommitment,a.vm.currency))}<br>条件差额：<strong>${esc(money(c.difference,a.vm.currency))}</strong></p>
<p>${c.downsizing ? '资源余量投影筛选出的缩容候选，不是安全保证。' : '不低于源 CPU/内存容量的现代化候选。'}</p>
<p class="muted">${o.redact ? '本地价格快照；原始依据标题已省略。' : esc(c.source?priceEvidence(c.source):t('目标价格依据不足'))}</p>
<h4>阻断 / 待验证</h4>${list(c.blockers)}<a href="${esc(c.sku.source)}" target="_blank" rel="noreferrer">官方 SKU 规格（需联网）</a></div>`).join('')}</div>` : '<div class="notice">无具体通用候选：补齐源配置、指标或转专项评估，不能强行放宽约束。</div>'}
${list(a.notes)}</article>`;
  }).join('')}</section>
<section class="section"><h2>实施与回退检查清单</h2>${list(['确认业务负责人、关键性和停机窗口；状态型系统先设计同步与角色切换。','核对源/目标镜像、启动代次、NVMe/MANA、临时盘、网络、磁盘与许可。','在客户订阅核验目标区域/可用区、系列配额和实际容量；不能以配额推断容量。','确认 RI/SP 系列覆盖、到期/续约、剩余承诺及有效合同价，重新分配承诺前先测算。','建立应用性能、数据一致性、备份和监控基线，先验证代表性低风险实例。','定义停止扩展、回切、数据恢复和业务验收条件，再按风险推进受控波次。'])}</section>
<section class="section"><h2>来源与免责声明</h2><p>${esc(t(VERSION))}。公开核验的生命周期与规格，与未充分公开核验的培训价格情景分开使用。报告不执行配置更改，不替代 Azure 公告、客户账单或供应商认证。</p>${list(SOURCES.map(([t,u])=>`${t}：${u}`))}<p>报告仅由本地数据生成。${o.redact ? '已省略名称、资源、订阅及价格依据原始标题；SKU、区域和数量仍会披露，请自行审查再外发。' : '本报告保留输入标识，外发前请审查授权。'}</p></section>
<footer class="footer">LOCAL FIRST · 离线独立报告 · 生成 ${esc(new Date().toISOString())}</footer></main></body></html>`;
  return localizeMarkup(html).replace(/\uE000(\d+)\uE001/g,(_,i:string)=>protectedValues[Number(i)]);
}
