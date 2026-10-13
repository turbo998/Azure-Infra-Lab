import { useEffect, useState, type ReactNode } from 'react';
import { DEFAULT_OPTIONS } from './model';
import { DEMO_PRICES, DEMO_VMS } from './data';
import { analyze } from './engine';
import { Footer, Header, money, mount, Notice, Rules, Sources } from './ui';
import { pageLink, useLanguage } from './i18n';

const chapters = ['从客户目标出发','理解四项更新','判断适用范围','商务影响与测算','配置与迁移设计','动手实验','沟通与知识检验'];
const questions = [
  { q: 'Dsv3 进入 End of Life，意味着什么？', choices: ['现在所有 Dsv3 都立即停机','按具体公告期限规划并完成过渡','任何含 v3 的 SKU 都在同一天退役'], answer: 1, why: 'Dv3/Dsv3/Ev3/Esv3 的公开期限为 2029-11-15；阶段、系列和云环境需分别判断。' },
  { q: '培训情景中，北欧的 Dsv2 该怎么计算涨幅？', choices: ['25% + 17% 直接相加','25% 再乘 17%，两次叠加','只用旧代际规则，不叠加区域 VM 规则'], answer: 2, why: '旧代际清单同时在区域 VM 情景的排除清单内。具体净成本还受到 EA/RI/SP 的约束。' },
  { q: '仅有账单与 CPU 平均利用率 8%，能否认定 VM 可以安全缩容？', choices: ['可以，直接减半','不可以，缺少内存、峰值窗口、网络/磁盘与业务约束','只要费用高就可以缩容'], answer: 1, why: '低平均 CPU 可能掩盖月末峰值、内存压力或认证限制；工具只给补数据或不降低容量的候选。' },
  { q: '从 Dsv3 迁移到 Dsv7 的正确做法是？', choices: ['同为 D 系列，盲目原地 resize','先验证 Gen2、NVMe、MANA、镜像、区域/配额，规划受控迁移','保证不重启、不迁移数据'], answer: 1, why: 'v6/v7 是平台现代化，不只是改一个 SKU 字符串；状态型应用还需要同步、角色切换与回退。' },
  { q: 'VM 迁移后计算资源费下降，是否必然减少客户总账单？', choices: ['必然，RI/SP 都自动退款','不必然，剩余购买承诺、许可和关联费用需评估','可以忽略 RI 到期日'], answer: 1, why: '资源费用差额与可兑现账单节省不同；承诺消耗、系列覆盖与客户净价需单独核验。' },
  { q: '中国区 Dsv3 不适用该 v3 退役公告，能推论什么？', choices: ['所有中国区 VM 永远不退役也不涨价','只能确认该公告排除，其他政策要单独核验','中国区可直接使用全球零售价作为合同报价'], answer: 1, why: '排除规则是逐公告的。Retail Prices API 仅有商业云范围，不能代替中国区合同价。' },
];

function Workshop() {
  useLanguage();
  const [completed, setCompleted] = useState<number[]>([]);
  const [active, setActive] = useState(0);
  const [presenter, setPresenter] = useState(false);
  const [caseIndex, setCaseIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<number,number>>({});
  const [submitted, setSubmitted] = useState(false);
  useEffect(() => {
    const observer = new IntersectionObserver(entries => {
      for (const e of entries) if (e.isIntersecting) setActive(Number(e.target.id.replace('chapter-','')));
    }, { rootMargin: '-10% 0px -65% 0px' });
    document.querySelectorAll('.section').forEach(e => observer.observe(e));
    return () => observer.disconnect();
  }, []);
  const caseResult = analyze(DEMO_VMS[caseIndex], DEMO_PRICES, DEFAULT_OPTIONS);
  const section = (i: number, intro: string, children: ReactNode) => <section className="section" id={`chapter-${i}`} key={i}>
    <div className="section-heading"><div><div className="section-index">MODULE {String(i+1).padStart(2,'0')}</div><h2>{chapters[i]}</h2><p>{intro}</p></div>
      <button className="no-print" aria-pressed={completed.includes(i)} onClick={() => setCompleted(c => c.includes(i) ? c.filter(n => n !== i) : [...c,i])}>{completed.includes(i) ? '✓ 已完成' : '标记完成'}</button></div>{children}</section>;
  const instructor = (prompt: string, takeaway: string) => <details className="instructor" open={presenter || undefined}><summary>讲师引导 / 小组讨论</summary><div className="detail-body"><p><strong>讨论：</strong>{prompt}</p><p><strong>收敛：</strong>{takeaway}</p></div></details>;
  return <div className={presenter ? 'presenter' : ''}><Header active="workshop"/>
    <div className="layout"><aside className="sidebar" aria-label="课程章节">
      <div className="sidebar-progress"><div className="eyebrow">LEARNING PATH</div><div className="progress-row"><span>课程进度</span><span>{completed.length} / 7</span></div><progress max={7} value={completed.length} aria-label="已完成章节"/></div>
      {chapters.map((c,i) => <a key={c} href={`#chapter-${i}`} className={active === i ? 'active' : ''}><span>{String(i+1).padStart(2,'0')}</span>{c}{completed.includes(i) && ' ✓'}</a>)}
      <small>面向销售 · 售前 · 服务交付<br/>三语 / 离线 / 本地数据</small>
    </aside><main className="content">
      <div className="hero"><div><div className="eyebrow">AZURE COMPUTE / PARTNER WORKSHOP</div>
        <h1>把生命周期变化，<br/>转成客户的<br/><span className="accent">现代化行动。</span></h1>
        <p className="lead">不是“所有 VM 都要换”。从客户的工作负载、购买承诺与业务目标出发，识别影响，量化情景，设计可验证的迁移路径。</p>
        <div><span className="badge">7 个学习模块</span><span className="badge">6 个模拟案例</span><span className="badge">交互练习 + 离线计算器</span></div>
        <div className="actions"><a href="#chapter-0" className="button primary">开始 Workshop →</a><button onClick={() => setPresenter(!presenter)} aria-pressed={presenter}>{presenter ? '退出讲师模式' : '讲师模式'}</button><button onClick={() => window.print()}>打印讲义</button></div>
      </div><div className="hero-visual" aria-label="评估到行动的闭环"><div className="eyebrow">FROM INSIGHT TO ACTION</div>
        {[['识别','系列 × 云 × 区域 × 合同'],['测算','同用量 · 同口径 · 有依据'],['设计','配置匹配 · 平台准备 · 回退'],['验证','小范围试点 · 业务验收']].map(([t,d],i) => <div className="flow-node" key={t}><span className="flow-number">{i+1}</span><div><strong>{t}</strong><small>{d}</small></div></div>)}
      </div></div>
      <Notice><strong>对外资料口径：</strong>公开已确认的生命周期与现代化要求，与用户材料中尚未充分公开核验的价格情景分开展示。价格情景不是官方报价；本版本不包含任何内部客户名单或资源链接。</Notice>
      {section(0, '先找到业务目标，再判断哪些变化与客户有关。', <>
        <div className="grid three role-cards">{[['销售角色','识别客户诉求与购买安排','业务目标、协议、覆盖与到期、预算来源、关键决策人。'],['售前角色','把政策翻译为可比较选项','建立 VM 清单、核对适用范围、补充用量与价格依据。'],['服务角色','将方案落实为可验收的服务','验证平台兼容与性能，执行受控迁移，落实备份、回退、监控和业务验收。']].map(([t,h,d],i) => <article className="card" key={t}><div className="card-index">ROLE 0{i+1}</div><h3>{t}</h3><strong>{h}</strong><p className="muted">{d}</p></article>)}</div>
        <div className="split" style={{marginTop:24}}><div><h3>用四个问题开启客户讨论</h3><ol><li>这批 VM 支撑哪些业务，哪些不能停？</li><li>资源是否受退役/容量约束，还是单纯存在优化机会？</li><li>价格、承诺覆盖与到期数据是否可信且完整？</li><li>是低扰动过渡，还是同步推进镜像与平台升级？</li></ol></div><div className="callout"><h3>共同交付物</h3><p>一份可核对的影响清单、一组有条件的方案对比、一条有验证和回退的现代化路径。</p><p><strong>禁用话术：</strong>“所有客户都涨价”“v3 已经停机”“最新 SKU 一定更便宜”“配额通过就一定有容量”。</p></div></div>
        {instructor('同一客户的测试环境与数据库，为什么可能需要不同迁移路径？','按业务风险和状态特征分组，而不是按同一个 VM 代际统一处理。')}
      </>)}
      {section(1, '生命周期、退役、价格与容量是四个不同维度。', <>
        <div className="grid four">{[['Current','采用并扩展','通用型 v6/v7 示例；适合新部署，仍需核验系列。'],['Extended','继续使用并评估','通用型 v4/v5 示例；受支持，不等于已停用。'],['End of Life','规划并完成过渡','具体系列公告定义期限，不等于立即关机。'],['Retired','完成过渡','不能创建、切入、运行；剩余 VM 可被释放。']].map(([t,h,d]) => <div className="card" key={t}><span className="badge accent">{t}</span><h3>{h}</h3><p className="muted">{d}</p></div>)}</div>
        <Notice><strong>公开确认：</strong>Dv3、Dsv3、Ev3、Esv3 在 2029-11-15 退役，排除政府云、中国区世纪互联云与主权云。其他 v3、v1/v2 的期限与排除范围必须单独查公告。</Notice>
        <div className="timeline"><div className="timeline-item"><small>培训材料中的沟通节点</small><strong>2026-09-28</strong><p>不等于价格生效或停机。</p></div><div className="timeline-item"><small>未充分公开核验 · 价格情景</small><strong>2027-02-01</strong><p>旧代际约 25% 与七区域 8–17%，需核对适用通知。</p></div><div className="timeline-item"><small>公开确认 · 四个 v3 系列</small><strong>2029-11-15</strong><p>必须在对应退役前完成过渡。</p></div></div>
        <div className="grid"><div className="card"><h3>容量限制 ≠ 退役公告</h3><p>某系列可能仍受支持，但新订阅、增配额或区域扩展受到限制。已经批准的配额也不保证容量。</p></div><div className="card"><h3>解除限制 ≠ 容量预留</h3><p>邮件提及指定 v4 系列解除增长限制。该细节标为待公开核验；仍需标准配额申请与目标区域容量检查。</p></div></div>
        <Rules/>{instructor('客户问“是不是到 2027 年 2 月就必须停机”，如何回应？','把定价情景与系列退役日期拆开；先确认系列、云环境和合同，再给行动路径。')}
      </>)}
      {section(2, '建立一张影响矩阵，不把排除规则扩大到其他公告。', <>
        <div className="table-wrap"><table><thead><tr><th>核对维度</th><th>需要的依据</th><th>最常见误判</th></tr></thead><tbody>
          {[['SKU/系列','ARM SKU + 精确系列目录','“所有 v3 一起退役”；D 与 DC 混用。'],['云环境','商业云 / 中国 / 政府 / 主权','套用商业云价格或把一个公告的排除复制给所有公告。'],['区域','ARM 区域码 + 适用通知','把七个区域当成所有区域，或把所有服务都算涨价。'],['产品/计量项','准确 SKU、版本和单位','General Block Blob 与 v2、Standard Page Blob 与 v2 混淆。'],['购买安排','EA/MCA、RI/SP 覆盖和期限','把基础费率变动直接当作净账单变动。']].map(([a,b,c]) => <tr key={a}><td><strong>{a}</strong></td><td>{b}</td><td>{c}</td></tr>)}
        </tbody></table></div>
        <div className="split"><div className="card"><h3>判断练习</h3><p>北欧 Dsv2、中国区 Dsv3、新加坡 Dsv7，三者是否都受相同规则影响？</p><details><summary>展开解析</summary><div className="detail-body"><p>北欧 Dsv2：旧代际价格情景，不叠加北欧 VM 调价。中国区 Dsv3：排除该 v3 退役公告，但其他政策独立核验。新加坡 Dsv7：在该区域 VM 情景排除清单，不代表关联存储也排除。</p></div></details></div><div className="card"><h3>交付前必须能追溯</h3><p>每个“受影响/排除/未知”都给出命中的规则、原始字段、来源和核验状态。无法确定的记录是“待核验”，不是“没有风险”。</p></div></div>
      </>)}
      {section(3, '区分基础费率、资源费用和可兑现总账单节省。', <>
        <div className="table-wrap"><table><thead><tr><th>购买安排</th><th>邮件培训情景的处理</th><th>客户分析要补什么</th></tr></thead><tbody>
          {[['现有 RI','优惠延续至到期；续订不是 EA enrollment 续约。','覆盖比例、已覆盖费率、到期、跨系列适用性及剩余承诺。'],['Savings Plan','不保留旧基础价；受影响消耗反映更新费率。','有效消耗费率、覆盖、承诺再分配；不能直接套固定折扣。'],['EA PAYG','续约前受 enrollment 价格上限约束。','续约日、可适用价格上限、目标 SKU 对应合同费率。'],['MCA PAYG','按适用通知与有效价格。','客户价格快照、OS、币种、单位、生效期间。']].map(([a,b,c]) => <tr key={a}><td><strong>{a}</strong></td><td>{b}</td><td>{c}</td></tr>)}
        </tbody></table></div>
        <div className="grid"><div className="card"><div className="card-index">MEASURE LIKE FOR LIKE</div><h3>同用量、同口径比较</h3><p className="mono">计算资源费 = 小时费率 × 实例小时总量</p><p>若是每实例小时，才再乘实例数。Actual 与 Amortized、不同币种、不同 OS 不混算。存储、许可与税费未输入时必须注明。</p></div><div className="card featured"><div className="card-index">DO NOT OVER-PROMISE</div><h3>承诺还在，账单未必下降</h3><p>不能把“换小 SKU 后 PAYG 计算费更低”直接称为节省。先检查 RI/SP 是否仍占用预算，再报告条件差额和缺失依据。</p></div></div>
        <Notice>计算器的分析日期只选择适用费率。源期间的用量保持不变：这是固定用量 run-rate 情景，不是假装精确预测跨月、跨续约的真实账单。</Notice>
        {instructor('RI 70% 覆盖且尚未到期，为什么不是把全部 VM 成本乘以涨幅？','覆盖部分按已覆盖费率，未覆盖部分按适用 PAYG；到期后再按有效规则，迁移还需审查剩余承诺。')}
      </>)}
      {section(4, '配置不是只有 CPU 和内存，最新代际也不是无条件直切。', <>
        <div className="split"><article className="card"><span className="badge">PATH A / v5</span><h3>低扰动过渡</h3><p>v5 属于 Extended，适合作为受支持的过渡目标。保持工作负载需求，核对临时盘、加速网络、远程盘和 NIC 上限。</p><ul><li>无临时盘需求：Dsv5 / Esv5。</li><li>需临时盘：Ddsv5 / Edsv5 等 d 变体。</li><li>resize 可能需要重启/释放；备份与回退不可省。</li></ul></article><article className="card featured"><span className="badge accent">PATH B / v6–v7</span><h3>平台现代化</h3><p>以当前 Gen2、NVMe 和 MANA-ready 镜像建立新基线。按应用模式选择重建、替换池或复制切换。</p><ul><li>Gen1 源不能盲目原地切为新代际。</li><li>状态型与集群需要数据同步、角色转移。</li><li>以应用性能验收，不假设跨代固定加速比例。</li></ul></article></div>
        <div className="grid four" style={{marginTop:16}}>{[['盘','临时数据、磁盘数、IOPS/吞吐、NVMe'],['网','带宽、NIC、加速网络、MANA 驱动'],['镜像','Gen2、OS 支持、代理、认证与许可'],['上线','区域/可用区、配额容量、备份与回退']].map(([h,d]) => <div className="card" key={h}><h3>{h}</h3><p className="muted">{d}</p></div>)}</div>
        <h3 style={{marginTop:24}}>建议的实施闭环</h3><div className="stepbar"><strong>发现与盘点</strong><span>→</span><strong>约束与候选</strong><span>→</span><strong>试点与回退</strong><span>→</span><strong>分波次迁移</strong><span>→</span><strong>业务验收</strong></div>
        <p>GPU、HPC、FPGA、B 系列额度特性、服务托管计算和厂商认证设备走专项路径，不套用通用 D/E 推荐。</p>
      </>)}
      {section(5, '在模拟案例中完成完整闭环，再换成客户真实依据。', <>
        <div className="card"><label>选择联合实验案例<select value={caseIndex} onChange={e => setCaseIndex(Number(e.target.value))}>{DEMO_VMS.map((v,i) => <option key={v.id} value={i}>{v.name}</option>)}</select></label>
          <div className="grid" style={{marginTop:20}}><div><span className="badge accent">教学模拟 / 非报价</span><h3 className="mono">{caseResult.vm.sku}</h3><p>{caseResult.vm.cloud} · {caseResult.vm.region} · {caseResult.vm.count} 实例</p><p>{caseResult.lifecycle.stage} {caseResult.lifecycle.date ? `· ${caseResult.lifecycle.date}` : ''}</p><p>{caseResult.effect.reason}</p></div><div><h3>评估日固定用量情景</h3><p>源基准：<strong>{money(caseResult.baseline,caseResult.vm.currency)}</strong><br/>不调整计算费：<strong>{money(caseResult.noChange,caseResult.vm.currency)}</strong><br/>首候选：<strong className="mono">{caseResult.candidates[0]?.sku.name ?? '专项/补数评估'}</strong><br/>条件差额：<strong>{caseResult.candidates[0]?.difference === null || !caseResult.candidates.length ? '待补承诺/价格依据' : money(caseResult.candidates[0]?.difference,caseResult.vm.currency)}</strong></p></div></div>
        </div>
        <ol><li>进入评估工作台，选择“加载教学案例”；下载模板观察字段口径。</li><li>确认云、SKU、单位、期间与实例数；查看案例 F 为什么不能缩容。</li><li>查看默认 30 天、CPU P95 / 内存 P99 / 网络与峰值条件；比较 v5/v6/v7。</li><li>查看案例 B 的临时盘与 RI 承诺阻断，案例 C 的 EA 价格上限。</li><li>切换“客户价格依据”模式：模拟价格不会被当作合同价。</li><li>导出脱敏报告，核对未知金额、阻断项和下一步验证清单。</li></ol>
        <div className="actions"><a className="button primary" href={pageLink('calculator.html')} target="_blank" rel="noreferrer">打开离线评估工作台 ↗</a><span className="muted">页面不自动传递或覆盖客户数据。</span></div>
        {instructor('让小组解释为什么案例 F 没有“减半”结论，以及案例 B 没有确定节省。','报告应保留信息缺口和阻断项；能解释“不能算/不能定”与算出金额同样重要。')}
      </>)}
      {section(6, '带着可核验结论结束培训，而不是只记住一个涨幅。', <>
        <div className="grid"><div className="card"><h3>客户沟通模板</h3><p>“我们先核对受影响的系列、区域和购买安排。根据目前数据，可以确认的是……；尚需补充的是……。我们建议先验证……，再按业务风险推进。”</p><h4>每次沟通记录</h4><p>状态、业务单元覆盖、结论、时间/资金/资源/容量阻碍、责任人和下一项行动；不用内部仪表板也能建立伙伴交付清单。</p></div><div className="card"><h3>常见异议</h3><details><summary>“最新 VM 太复杂，我们先不迁。”</summary><div className="detail-body">先评估受支持的 v5 过渡，再安排 v6/v7 镜像平台现代化。按退役期限与业务风险排序，不强迫一步到位。</div></details><details><summary>“你们计算器说能省，为什么账单没下降？”</summary><div className="detail-body">核对合同净价、RI/SP 剩余承诺、覆盖、关联费用与成本口径。条件资源费差额不是总账单节省保证。</div></details><details><summary>“配额足够，为什么还无法部署？”</summary><div className="detail-body">配额是允许使用的上限，容量是区域中实际可供应的硬件；可用区和具体 SKU 也需核验。</div></details></div></div>
        <h3 style={{marginTop:28}}>知识检验 / 6 道题</h3>
        {questions.map((q,i) => <fieldset className="quiz" key={q.q}><legend>{i+1}. {q.q}</legend>{q.choices.map((c,j) => <label key={c}><input type="radio" name={`quiz-${i}`} checked={answers[i] === j} onChange={() => { setAnswers({...answers,[i]:j}); setSubmitted(false); }}/>{c}</label>)}
          {submitted && <div className={`answer ${answers[i] === q.answer ? 'good' : 'bad'}`}><strong>{answers[i] === q.answer ? '✓ 正确' : answers[i] === undefined ? '未作答' : '需再核对'}</strong> · {q.why}</div>}</fieldset>)}
        <div className="actions no-print"><button className="primary" onClick={() => setSubmitted(true)}>提交并查看解析</button><button onClick={() => {setAnswers({});setSubmitted(false);}}>重新作答</button>{submitted && <strong role="status">得分 {questions.filter((q,i) => answers[i] === q.answer).length} / 6</strong>}</div>
        <div className="callout" style={{marginTop:24}}><h3>培训后的伙伴行动清单</h3><label className="check"><input type="checkbox"/>完成客户清单与准确适用范围</label><label className="check"><input type="checkbox"/>收齐峰值、性能、合同与价格依据</label><label className="check"><input type="checkbox"/>评审候选与承诺成本，确认试点及回退</label><label className="check"><input type="checkbox"/>约定业务验收和后续行动责任人</label><small>勾选状态只在本次页面会话保留。</small></div>
      </>)}
      <Sources/><Footer/>
    </main></div></div>;
}
mount(<Workshop/>);
