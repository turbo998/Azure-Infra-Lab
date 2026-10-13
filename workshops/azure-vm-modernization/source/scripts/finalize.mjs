import { copyFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const root = fileURLToPath(new URL('..', import.meta.url));
for (const name of ['workshop.html','calculator.html','demo.html'])
  await copyFile(resolve(root,'dist',name),resolve(root,'..',name));
console.log('Published three self-contained trilingual HTML files to the delivery folder.');
