import { getLanguage, pageLink, useLanguage } from './i18n';
import { DEMO_VMS } from './data';
import { Footer, Header, mount, Notice } from './ui';

function Demo() {
  useLanguage();
  const folder = `sample-data/${getLanguage()}`;
  const objectives = ['完整指标，条件缩容','RI 与临时盘约束','EA 上限，不叠涨幅','单公告云排除','专项计算，不给通用替代','缺少指标，禁止确定缩容'];
  const results = ['870.91 USD 条件差额；非保证节省','剩余承诺未知，差额留空','不调整计算费 648.00 USD','价格未知；不扩大云排除范围','转人工专项评估','不降低源 CPU/内存容量'];
  return <><Header active="demo"/><main className="workspace">
    <div className="hero"><div><div className="eyebrow">LIVE DEMO / SYNTHETIC DATA / OFFLINE</div><h1>一键体验，从样例到报告。</h1>
      <p className="lead">同一个页面，随时切换简体、繁体和英文；切换语言不清除导入数据、分析结果或课程进度。</p>
      <div className="actions"><a className="button primary" href={pageLink('calculator.html',true)}>开始自动演示 →</a><a className="button" href={pageLink('workshop.html')}>打开培训课程</a></div></div>
      <div className="hero-visual"><div className="eyebrow">6 CASES · 12 INSTANCES · 3 LANGUAGES</div>
        <h3>演示步骤</h3>{[
          ['选择语言','点击页首语言按钮，整个课程、工作台、校验提示及报告随语言切换。'],
          ['载入六个模拟案例','自动演示会在评估工作台载入案例和模拟价格，并立即执行分析；不上传或修改 Azure 资源。'],
          ['比较配置与阻断项','展开案例 A，查看 D4s_v5 与条件差额；案例 B 查看临时盘和剩余 RI 承诺，案例 F 查看缺少指标时为何不能缩容。'],
          ['导出当前语言报告','下载 HTML 报告或建议 CSV；HTML 可独立离线打开并打印为 PDF。默认省略客户标识。'],
        ].map(([heading,body],i)=><div className="flow-node" key={heading}><span className="flow-number">{i+1}</span><div><strong>{heading}</strong><small>{body}</small></div></div>)}
      </div></div>
    <Notice><strong>演示免责声明：</strong>所有名称、价格和用量都是虚构教学数据；模拟价格不会被客户价格模式当作真实报价。<br/>不得作为报价或配置变更许可。所有候选仍需应用性能、平台、配额、容量及回退验证。</Notice>
    <section className="section"><h2>样例与预期结果</h2><div className="table-wrap"><table><thead><tr><th>案例</th><th>ARM SKU</th><th>学习重点</th><th>预期结论</th></tr></thead><tbody>{DEMO_VMS.map((vm,i)=><tr key={vm.id}><td>{vm.name}</td><td className="mono">{vm.sku}</td><td>{objectives[i]}</td><td>{results[i]}</td></tr>)}</tbody></table></div>
      <div className="actions">{[
        ['sample-vms.csv','CSV 用量样例'],['sample-vms.xlsx','Excel 用量样例'],
        ['sample-prices.csv','CSV 模拟价格'],['sample-prices.xlsx','Excel 模拟价格'],
        ['sample-report.html','独立示例报告'],
      ].map(([name,label])=><a className="button" key={name} href={`${folder}/${name}`} download={name}>{label}</a>)}</div>
      <p className="muted" style={{marginTop:20}}>文件下载后可手动导入工作台。ARM 字段名、SKU、地区、日期和数值在三种语言间保持一致。</p>
      <p className="muted">截图由真实离线演示流程生成，见交付包 screenshots 文件夹。</p>
    </section><Footer/>
  </main></>;
}
mount(<Demo/>);
