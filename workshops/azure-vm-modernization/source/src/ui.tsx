import React, { type ReactNode, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { LEGACY, REGIONS, SOURCES, STORAGE_EXCLUDED, STORAGE_INCLUDED, V4_LIFTED, V7_EXEMPT, VERSION } from './data';
import './style.css';
import { getLanguage, pageLink, setLanguage, t, useLanguage, type Language } from './i18n';

export function money(amount: number | null | undefined, currency?: string): string {
  if (amount === null || amount === undefined) return '待补价格依据';
  return currency ? new Intl.NumberFormat(getLanguage(), { style: 'currency', currency, maximumFractionDigits: 2 }).format(amount) : amount.toFixed(2);
}
export function download(name: string, text: string, type = 'text/plain;charset=utf-8') {
  const url = URL.createObjectURL(new Blob([text], { type }));
  const a = document.createElement('a');
  a.href = url; a.download = name; document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 30000);
}
export function Header({ active }: { active: 'workshop' | 'calculator' | 'demo' }) {
  const language = useLanguage();
  const [dark, setDark] = useState(document.documentElement.dataset.theme === 'dark');
  return <header className="topbar"><div className="topbar-inner">
    <a className="brand" href={pageLink('workshop.html')}><span className="brand-mark" aria-hidden="true">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M3 20 12 3l9 17H3Z"/><path d="m8 14 8 0M10 10h4"/></svg>
    </span><span>Azure VM 现代化<small>PARTNER ENABLEMENT / FIELD LAB</small></span></a>
    <nav className="top-actions" aria-label="页面导航">
      <a className={`button ${active === 'workshop' ? 'current' : ''}`} href={pageLink('workshop.html')}>伙伴 Workshop</a>
      <a className={`button ${active === 'calculator' ? 'current' : ''}`} href={pageLink('calculator.html')}>评估工作台</a>
      <a className={`button ${active === 'demo' ? 'current' : ''}`} href={pageLink('demo.html')}>Demo</a>
      <div className="language-switch" role="group" aria-label="Language">
        {([['zh-CN','简体'],['zh-TW','繁體'],['en','English']] as const).map(([code,label])=><button key={code} data-no-i18n aria-label={`Language: ${code}`} aria-pressed={language===code} className={language===code?'current':''} onClick={()=>setLanguage(code as Language)}>{label}</button>)}
      </div>
      <button className="quiet" aria-label={dark ? '切换浅色主题' : '切换深色主题'} onClick={() => {
        document.documentElement.dataset.theme = dark ? 'light' : 'dark'; setDark(!dark);
      }}>{dark ? '浅色' : '深色'}</button>
    </nav>
  </div></header>;
}
export function Notice({ children, error = false }: { children: ReactNode; error?: boolean }) {
  return <div className={`notice ${error ? 'error' : ''}`} role={error ? 'alert' : undefined}>{children}</div>;
}
export function Sources() {
  return <details><summary>资料来源、规则版本与适用边界</summary><div className="detail-body">
    <p><strong>{VERSION}</strong> · 生命周期/现代化规格来自公开 Microsoft Learn；价格和 v4 解除限制细节来自用户提供的培训材料，尚未充分公开核验。</p>
    <ul>{SOURCES.map(([title, url]) => <li key={url}><a href={url} target="_blank" rel="noreferrer">{title}</a></li>)}</ul>
    <p className="muted">离线快照不是实时价格、订阅配额或容量保证。本工具不连接 Azure，不复刻 Advisor，不执行任何资源变更。</p>
  </div></details>;
}
export function Rules() {
  return <details><summary>查看培训情景的精确清单与排除规则</summary><div className="detail-body">
    <Notice>以下价格情景尚未充分公开核验，仅供教学/条件性测算。生效日假设为 2027-02-01；客户实际影响以适用通知与合同为准。</Notice>
    <h4>旧代际基础费率情景约 +25%</h4><p className="mono">{LEGACY.join(' · ')}</p>
    <p>排除中国、政府与主权云；这些系列不参与区域 VM 情景调价，不叠加两种涨幅。</p>
    <div className="table-wrap"><table><thead><tr><th>区域 ARM 名称</th><th>情景涨幅</th></tr></thead><tbody>{Object.entries(REGIONS).map(([r,n]) => <tr key={r}><td className="mono">{r}</td><td>{n}%</td></tr>)}</tbody></table></div>
    <h4>区域 VM 调价排除</h4><p>{[...LEGACY, ...V7_EXEMPT].join(' · ')}</p>
    <h4>存储产品清单（仍需精确计量项）</h4><p>{STORAGE_INCLUDED.join('；')}</p>
    <h4>存储排除</h4><p>{STORAGE_EXCLUDED.join('；')}</p>
    <p><strong>名称不能互换：</strong>General Block Blob ≠ General Block Blob v2；Standard Page Blob ≠ Standard Page Blob v2。Files/Files v2 必须排除 Transaction-Optimized；ANF 必须排除 Cross Region Replication。仅提供父产品名时，工具标为待核验。</p>
    <h4>邮件 v4 增长限制解除清单（待公开核验）</h4><p>{V4_LIFTED.join(' · ')}</p>
    <p>解除限制不等于容量预留、配额自动批准或区域规格可用。</p>
  </div></details>;
}
export function Footer() {
  return <footer className="footer"><strong>LOCAL FIRST.</strong> 客户数据留在本地浏览器；不上传、不自动保存。教学案例均为模拟。<br/>{VERSION} · 可外发版本不包含内部客户名单、仪表板或内部资源。分析不是正式报价，也不是部署许可。</footer>;
}
class ErrorBoundary extends React.Component<{ children: ReactNode }, { error: string }> {
  state = { error: '' };
  static getDerivedStateFromError(error: Error) { return { error: error.message }; }
  componentDidCatch(error: Error) { console.error('页面运行失败', error); }
  render() { return this.state.error ? <main className="workspace"><Notice error><h1>页面无法继续运行</h1><p>{this.state.error}</p><p>请重新打开文件；尚未导出的数据不会自动保存。</p></Notice></main> : this.props.children; }
}
export function mount(app: ReactNode) {
  document.documentElement.lang = getLanguage();
  document.title = t(document.title);
  let closed: HTMLDetailsElement[] = [];
  window.addEventListener('beforeprint', () => {
    closed = [...document.querySelectorAll<HTMLDetailsElement>('details:not([open])')];
    closed.forEach(d => d.open = true);
  });
  window.addEventListener('afterprint', () => closed.forEach(d => d.open = false));
  createRoot(document.getElementById('root')!).render(<React.StrictMode><ErrorBoundary>{app}</ErrorBoundary></React.StrictMode>);
}
