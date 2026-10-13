import ts from 'typescript';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
const root = fileURLToPath(new URL('../src',import.meta.url));
const keys = new Set();
function add(value) {
  for (const chunk of value.split(/<[^>]*>/g)) {
    const key = chunk.trim();
    if (/[\u3400-\u9fff]/.test(key)) keys.add(key);
  }
}
for (const name of await readdir(root)) {
  if (!/\.(ts|tsx)$/.test(name) || /\.(test|d)\.ts$/.test(name)) continue;
  const file=ts.createSourceFile(name,await readFile(join(root,name),'utf8'),ts.ScriptTarget.Latest,true);
  function visit(node) {
    if (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node) || ts.isJsxText(node)) add(node.text);
    if (ts.isTemplateExpression(node)) add(node.head.text + node.templateSpans.map((s,i)=>`{${i}}${s.literal.text}`).join(''));
    ts.forEachChild(node,visit);
  }
  visit(file);
}
const dictionary=JSON.parse(await readFile(join(root,'i18n','en.json'),'utf8'));
const missing=[...keys].filter(key=>!dictionary[key]).sort((a,b)=>a.localeCompare(b,'zh'));
await writeFile(join(root,'..','locale-keys.json'),JSON.stringify(missing,null,2));
console.log(`${keys.size} authored keys; ${missing.length} without English translations`);
