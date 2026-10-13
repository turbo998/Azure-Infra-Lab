import { jsx as reactJsx, jsxs as reactJsxs, Fragment } from 'react/jsx-runtime';
import type React from 'react';
import { isValidElement } from 'react';
import { getLanguage, t } from './index';
export { Fragment };
export namespace JSX {
  export type Element = React.JSX.Element;
  export type ElementType = React.JSX.ElementType;
  export type IntrinsicElements = React.JSX.IntrinsicElements;
  export type ElementChildrenAttribute = React.JSX.ElementChildrenAttribute;
  export type IntrinsicAttributes = React.JSX.IntrinsicAttributes;
  export type IntrinsicClassAttributes<T> = React.JSX.IntrinsicClassAttributes<T>;
  export type LibraryManagedAttributes<C, P> = React.JSX.LibraryManagedAttributes<C, P>;
}
function children(value: unknown): unknown {
  if (typeof value === 'string') return t(value);
  if (!Array.isArray(value)) return value;
  const translated = value.map(child => typeof child === 'string' ? t(child) : Array.isArray(child) ? children(child) : child);
  if (getLanguage()!=='en') return translated;
  return translated.map((child,index)=>{
    if (typeof child!=='string') return child;
    let text=child;
    if (index>0 && isValidElement(translated[index-1]) && /^[A-Za-z0-9]/.test(text)) text=` ${text}`;
    if (index+1<translated.length && isValidElement(translated[index+1]) && /[A-Za-z0-9.:]$/.test(text)) text=`${text} `;
    return text;
  });
}
function props(input: unknown) {
  if (!input || typeof input!=='object' || Array.isArray(input)) return input;
  const record: Record<string, unknown> = Object.fromEntries(Object.entries(input));
  if (record['data-no-i18n']) return input;
  const output = { ...record };
  if ('children' in output) output.children = children(output.children);
  for (const key of ['aria-label','title','placeholder','alt']) if (typeof output[key] === 'string') output[key] = t(output[key]);
  return output;
}
export const jsx: typeof reactJsx = (type, input, key) => reactJsx(type, props(input), key);
export const jsxs: typeof reactJsxs = (type, input, key) => reactJsxs(type, props(input), key);
