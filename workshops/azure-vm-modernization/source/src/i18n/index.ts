import { useSyncExternalStore } from 'react';
import { Converter } from 'opencc-js/cn2t';
import english from './en.json';
import additions from './extras-en.json';

export type Language = 'zh-CN' | 'zh-TW' | 'en';
const languages: Language[] = ['zh-CN', 'zh-TW', 'en'];
let language: Language = typeof location !== 'undefined' && languages.includes(new URLSearchParams(location.search).get('lang') as Language)
  ? new URLSearchParams(location.search).get('lang') as Language : 'zh-CN';
const listeners = new Set<() => void>();
const originalTitle = typeof document !== 'undefined' ? document.title : '';
const convertTraditional = Converter({ from: 'cn', to: 'twp' });
const traditional = (text: string) => convertTraditional(text).replaceAll('例項','執行個體').replaceAll('臨時盤','暫存磁碟');
const dictionary: Record<string, string> = { ...english, ...additions };
const chinese = /[\u3400-\u9fff]/;
const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const patterns = Object.entries(dictionary).filter(([key]) => /\{\d+\}/.test(key)).map(([key, value]) => ({
  key, value, indices: [...key.matchAll(/\{(\d+)\}/g)].map(m=>m[1]),
  regex: new RegExp('^' + key.split(/(\{\d+\})/).map(p => /^\{\d+\}$/.test(p) ? '([\\s\\S]*?)' : escapeRegex(p)).join('') + '$'),
}));
const fragments = Object.entries(dictionary).filter(([key]) => !/\{\d+\}/.test(key) && chinese.test(key)).sort((a,b) => b[0].length-a[0].length);
const missing = new Set<string>();

export const getLanguage = () => language;
export const getMissingTranslations = () => [...missing];
export function setLanguage(next: Language) {
  if (!languages.includes(next)) throw new Error(`Unsupported language: ${next}`);
  language = next;
  if (typeof document !== 'undefined') document.documentElement.lang = next;
  if (typeof document !== 'undefined') document.title = t(originalTitle);
  if (typeof location !== 'undefined' && typeof history !== 'undefined') {
    const url = new URL(location.href);
    url.searchParams.set('lang', next);
    history.replaceState(null, '', url);
  }
  listeners.forEach(notify => notify());
}
export function useLanguage() {
  return useSyncExternalStore(notify => { listeners.add(notify); return () => listeners.delete(notify); }, getLanguage, getLanguage);
}
export function t(text: string): string {
  if (language === 'zh-CN' || !chinese.test(text)) return text;
  if (language === 'zh-TW') return traditional(text);
  const key = text.trim();
  const leading = text.slice(0, text.length-text.trimStart().length);
  const trailing = text.slice(text.trimEnd().length);
  if (dictionary[key] !== undefined) return leading + dictionary[key] + trailing;
  for (const p of patterns) {
    const match = p.regex.exec(key);
    if (match) return leading + p.value.replace(/\{(\d+)\}/g, (_, i: string) => t(match[p.indices.indexOf(i)+1] ?? '')) + trailing;
  }
  let translated = text;
  for (const [source, target] of fragments) translated = translated.replaceAll(source, target);
  if (chinese.test(translated)) missing.add(text);
  return translated;
}
export function pageLink(page: string, demo = false): string {
  return `${page}?lang=${language}${demo ? '&demo=1' : ''}`;
}
export function localizeMarkup(html: string): string {
  const output=html.split(/(<[^>]*>)/g).map(part => part.startsWith('<') ? part : t(part)).join('');
  return language==='en' ? output.replace(/<\/strong>(?=[A-Za-z0-9])/g,'</strong> ') : output;
}
export function priceEvidence(text: string) {
  if (!text) return t('价格依据不足');
  const match = /^(教学模拟|公开零售参考，非合同净价|客户提供价格)：([\s\S]*)$/.exec(text);
  if (!match) return text;
  const source = match[2] === '教学模拟价格，非 Azure 报价' ? t(match[2]) : match[2];
  return `${t(match[1])}: ${source}`;
}
const variants = new Map<string, string[]>();
export function labelVariants(label: string) {
  const existing=variants.get(label);
  if (existing) return existing;
  const values=[label,traditional(label),dictionary[label]??label];
  variants.set(label,values);
  return values;
}
