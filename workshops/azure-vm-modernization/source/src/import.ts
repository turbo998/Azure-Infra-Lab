import Papa from 'papaparse';
import ExcelJS from 'exceljs';
import { FIELDS, PRICE_HEADERS, type Field, type Issue, type Price, type RawRow, type Vm } from './model';
import { isDate } from './engine';
import { CATALOG, normalizeRegion } from './data';
import { labelVariants } from './i18n';

export type Sheet = { name: string; headers: string[]; rows: RawRow[] };
export const MAX_ROWS = 20000;
export const MAX_BYTES = 20 * 1024 * 1024;
const numberKeys = new Set<keyof Vm>(['count','hoursTotal','hoursPerVM','vcpus','memoryGiB','cpuP95','memoryP99','networkP95Mbps','observationDays','tempGiB','dataDisks','nics','diskIOPS','diskMBps','bootGeneration','riCoverage','riRate','eaCapRate','residualCommitmentCost','currentRate','currentCost','storageCost','futureStorageCost']);
const booleanKeys = new Set<keyof Vm>(['peakCovered','accelNetworking','nvmeReady','manaReady','licenseReady','priceIncludesUpdate','storagePriceIncludesUpdate']);
const dateKeys = new Set<keyof Vm>(['periodStart','periodEnd','riEnd','eaRenewal','rateFrom','rateTo']);
const integerKeys = new Set<keyof Vm>(['count','vcpus','dataDisks','nics','bootGeneration','observationDays']);
const normalizeHeader = (s: string) => s.replace(/[\s_\-()%（）]/g, '').toLowerCase();
export function automaticMapping(headers: string[]): Record<string, string> {
  return Object.fromEntries(FIELDS.map(f => [f.key, headers.find(h =>
    [f.key, ...labelVariants(f.label), ...(f.aliases ?? [])].some(a => normalizeHeader(a) === normalizeHeader(h))) ?? '']));
}
function makeSheet(name: string, grid: string[][]): Sheet {
  const first = grid.findIndex(row => row.some(cell => cell.trim()));
  if (first < 0) throw new Error('文件没有非空数据。');
  const headers = grid[first].map(h => h.trim().replace(/^\uFEFF/, ''));
  if (headers.length > 250) throw new Error('超过 250 列保护上限，请拆分不相关列。');
  if (headers.some(h => !h)) throw new Error('表头存在空列名，请修正或删除空列。');
  if (new Set(headers.map(normalizeHeader)).size !== headers.length) throw new Error('表头名称重复，不能安全映射。');
  const body = grid.slice(first + 1).filter(row => row.some(cell => cell.trim()));
  if (!body.length) throw new Error('只有表头，没有数据记录。');
  if (body.length > MAX_ROWS) throw new Error(`超过 ${MAX_ROWS.toLocaleString()} 行保护上限，请拆分文件。`);
  if (body.some(r => r.length > headers.length)) throw new Error('数据行比表头列数多，请检查分隔符/合并单元格。');
  return { name, headers, rows: body.map(row => Object.fromEntries(headers.map((h, i) => [h, row[i] ?? '']))) };
}
export function parseCsv(text: string): Sheet {
  const result = Papa.parse<string[]>(text.replace(/^\uFEFF/, ''), { skipEmptyLines: 'greedy' });
  if (result.errors.length) throw new Error(`CSV 解析失败：${result.errors[0].message}（数据行 ${(result.errors[0].row ?? 0) + 1}）。`);
  return makeSheet('CSV', result.data);
}

function checkZip(buffer: ArrayBuffer) {
  const d = new DataView(buffer);
  let end = -1;
  for (let i = d.byteLength - 22; i >= Math.max(0, d.byteLength - 65557); i--)
    if (d.getUint32(i, true) === 0x06054b50) { end = i; break; }
  if (end < 0) throw new Error('不是有效 XLSX ZIP，或文件已加密/损坏。');
  const entries = d.getUint16(end + 10, true);
  let pos = d.getUint32(end + 16, true), expanded = 0;
  if (entries > 1000 || entries === 0xffff || pos === 0xffffffff) throw new Error('工作簿结构超出保护上限或采用不支持的 ZIP64。');
  for (let i = 0; i < entries; i++) {
    if (pos + 46 > d.byteLength || d.getUint32(pos, true) !== 0x02014b50) throw new Error('工作簿 ZIP 目录损坏。');
    if (d.getUint16(pos + 8, true) & 1) throw new Error('不支持加密工作簿。');
    expanded += d.getUint32(pos + 24, true);
    if (expanded > 100 * 1024 * 1024) throw new Error('解压后超过 100 MiB 保护上限，请拆分工作簿。');
    pos += 46 + d.getUint16(pos + 28, true) + d.getUint16(pos + 30, true) + d.getUint16(pos + 32, true);
  }
}
export async function readFile(file: File): Promise<Sheet[]> {
  if (file.size > MAX_BYTES) throw new Error('文件超过 20 MiB 保护上限，请拆分后导入。');
  if (/\.csv$/i.test(file.name)) {
    const text = new TextDecoder('utf-8', { fatal: true }).decode(await file.arrayBuffer());
    return [parseCsv(text)];
  }
  if (!/\.xlsx$/i.test(file.name)) throw new Error('仅支持 UTF-8 CSV 或 XLSX，不支持 XLS/加密工作簿。');
  const buffer = await file.arrayBuffer();
  checkZip(buffer);
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.load(buffer);
  const sheets: Sheet[] = [];
  workbook.eachSheet(sheet => {
    if (!sheet.actualRowCount) return;
    if (sheet.rowCount > MAX_ROWS + 1 || sheet.columnCount > 250) throw new Error(`${sheet.name} 超出行/列保护上限。`);
    const grid: string[][] = [];
    sheet.eachRow(row => {
      const cells: string[] = [];
      for (let c = 1; c <= sheet.columnCount; c++) {
        const cell = row.getCell(c), value = cell.value;
        if (value && typeof value === 'object' && ('formula' in value || 'sharedFormula' in value))
          throw new Error(`${sheet.name} ${cell.address} 含公式。请复制为值后导入，以免误用陈旧缓存。`);
        if (value instanceof Date) cells.push(value.toISOString().slice(0, 10));
        else if (typeof value === 'number' && cell.numFmt?.includes('%')) cells.push(`${value * 100}%`);
        else cells.push(cell.text);
      }
      grid.push(cells);
    });
    if (grid.filter(row => row.some(cell => cell.trim())).length < 2) return;
    sheets.push(makeSheet(sheet.name, grid));
  });
  if (!sheets.length) throw new Error('工作簿没有可用数据工作表。');
  return sheets;
}

const enumValues: Partial<Record<keyof Vm, readonly string[]>> = {
  cloud: ['Commercial','China','Government','Sovereign','Unknown'], workload: ['user-facing','batch','unknown'],
  agreement: ['EA','MCA','Unknown'], purchase: ['PAYG','RI','SavingsPlan','Mixed','Unknown'],
  costBasis: ['Actual','Amortized'], rateBasis: ['baseline','effective'], priceKind: ['customer','retail','demo'],
};
export function validateVms(sheet: Sheet, mapping: Record<string, string>): { vms: Vm[]; issues: Issue[]; warnings: Issue[] } {
  const issues: Issue[] = [], warnings: Issue[] = [], vms: Vm[] = [];
  const mappedColumns = Object.values(mapping).filter(Boolean);
  if (new Set(mappedColumns).size !== mappedColumns.length) {
    return { vms: [], warnings, issues: [{ row: 1, field: '列映射', message: '同一源列被映射到多个字段，请修正。' }] };
  }
  const idCounts = new Map<string, number>();
  for (const row of sheet.rows) {
    const id = row[mapping.id]?.trim().toLowerCase();
    if (id) idCounts.set(id, (idCounts.get(id) ?? 0) + 1);
  }
  sheet.rows.forEach((row, i) => {
    const rowNo = i + 2, start = issues.length;
    const values: Record<string, string | number | boolean> = {};
    const fail = (field: string, message: string) => issues.push({ row: rowNo, field, message });
    for (const f of FIELDS) {
      let text = (row[mapping[f.key]] ?? '').trim();
      if (!text) {
        if (f.required) fail(f.label, '必填字段缺失。');
        continue;
      }
      if (numberKeys.has(f.key)) {
        text = text.replace(/%$/, '');
        if (!/^(?:\d+(?:\.\d*)?|\.\d+)$/.test(text)) { fail(f.label, '须为非负数字，不含千位符/货币符号。'); continue; }
        const n = Number(text);
        if (!Number.isFinite(n) || n > Number.MAX_SAFE_INTEGER) { fail(f.label, '数值超出精度范围。'); continue; }
        if (integerKeys.has(f.key) && !Number.isInteger(n)) fail(f.label, '须为整数。');
        if (['count','vcpus','memoryGiB','nics','observationDays'].includes(f.key) && n === 0) fail(f.label, '必须大于 0。');
        if (['cpuP95','memoryP99','riCoverage'].includes(f.key) && n > 100) fail(f.label, '百分比须为 0–100，不是 0–1 比例。');
        if (f.key === 'bootGeneration' && ![1,2].includes(n)) fail(f.label, '只能为 1 或 2。');
        values[f.key] = n;
      } else if (booleanKeys.has(f.key)) {
        if (/^(yes|true|1|是|已确认)$/i.test(text)) values[f.key] = true;
        else if (/^(no|false|0|否)$/i.test(text)) values[f.key] = false;
        else fail(f.label, '填 yes/no，留空表示未知。');
      } else if (dateKeys.has(f.key)) {
        if (!isDate(text)) fail(f.label, '必须是有效 YYYY-MM-DD 日期。');
        else values[f.key] = text;
      } else if (enumValues[f.key]) {
        const canonical = enumValues[f.key]!.find(v => v.toLowerCase() === text.toLowerCase());
        if (!canonical) fail(f.label, `填 ${enumValues[f.key]!.join(' / ')}。`);
        else values[f.key] = canonical;
      } else values[f.key] = text;
    }
    const getN = (key: keyof Vm) => typeof values[key] === 'number' ? values[key] as number : undefined;
    const getS = (key: keyof Vm) => typeof values[key] === 'string' ? values[key] as string : undefined;
    if (getS('sku') && !/^Standard_[A-Za-z0-9_-]+$/i.test(getS('sku')!)) fail('ARM SKU', '需为 Standard_ 开头的 ARM 名称，不接受产品展示名。');
    if (getS('currency') && !/^[A-Z]{3}$/i.test(getS('currency')!)) fail('币种', '需为三位货币代码。');
    if (getN('hoursTotal') !== undefined && getN('hoursPerVM') !== undefined) fail('用量', '实例小时总量与每实例小时互斥，避免重复乘实例数。');
    if ((getN('hoursTotal') !== undefined || getN('hoursPerVM') !== undefined) && getS('usageUnit') !== '1 Hour') fail('用量单位', '提供小时用量时必须明确填 1 Hour。');
    for (const [a,b] of [['periodStart','periodEnd'],['rateFrom','rateTo']] as const) {
      if (getS(a) && getS(b) && getS(a)! >= getS(b)!) fail(a, '开始日须早于结束日（结束日不包含）。');
    }
    if (!!getS('periodStart') !== !!getS('periodEnd')) fail('源期间', '开始日和结束日需同时提供。');
    if (getS('periodStart') && getS('periodEnd')) {
      const limit = (Date.parse(getS('periodEnd')!) - Date.parse(getS('periodStart')!)) / 3600000;
      if (getN('hoursPerVM') !== undefined && getN('hoursPerVM')! > limit) fail('每实例小时', '超过源期间最大可能小时数。');
      if (getN('hoursTotal') !== undefined && getN('count') !== undefined && getN('hoursTotal')! > limit * getN('count')!) fail('实例小时总量', '超过源期间实例数 × 最大小时数。');
    }
    const id = getS('id');
    if (id && idCounts.get(id.toLowerCase())! > 1) fail('资源唯一标识', '重复/冲突标识：所有同标识行均不分析，请先汇总或修正，避免先到先得。');
    const spec = CATALOG.find(s => s.name.toLowerCase() === getS('sku')?.toLowerCase());
    if (spec && ((getN('vcpus') !== undefined && getN('vcpus') !== spec.cores) || (getN('memoryGiB') !== undefined && getN('memoryGiB') !== spec.memory)))
      fail('源配置', '显式 vCPU/内存与本地已核验 SKU 规格冲突，请修正。');
    if (issues.length === start) {
      // Required fields have been validated above; construct typed records rather than coercing the input table.
      const vm: Vm = {
        id: id!, name: getS('name') ?? id!, sku: getS('sku')!, region: normalizeRegion(getS('region')!),
        count: getN('count')!, cloud: (getS('cloud') ?? 'Unknown') as Vm['cloud'],
        os: getS('os') ?? 'Unknown', workload: (getS('workload') ?? 'unknown') as Vm['workload'],
        agreement: (getS('agreement') ?? 'Unknown') as Vm['agreement'], purchase: (getS('purchase') ?? 'Unknown') as Vm['purchase'],
      };
      for (const f of FIELDS) {
        if (values[f.key] !== undefined && !['id','name','sku','region','count','cloud','os','workload','agreement','purchase'].includes(f.key))
          Object.assign(vm, { [f.key]: values[f.key] });
      }
      if (vm.currency) vm.currency = vm.currency.toUpperCase();
      if (vm.architecture) vm.architecture = vm.architecture.toLowerCase();
      if (vm.specialRequirements) vm.specialRequirements = vm.specialRequirements.toLowerCase();
      if (vm.cloud === 'Unknown') warnings.push({ row: rowNo, field: '云环境', message: '未知云环境，相关适用性需确认。' });
      if (vm.currentCost !== undefined && (!vm.currency || !vm.costBasis || !vm.priceSource || !vm.priceKind))
        warnings.push({ row: rowNo, field: '成本依据', message: '缺少币种/口径/来源/类型，成本不会作为可信金额输出。' });
      if (vm.cpuP95 !== undefined && vm.cpuP95 > 0 && vm.cpuP95 < 1)
        warnings.push({ row: rowNo, field: 'CPU P95', message: '数值小于 1%；请确认不是将 0–1 比例误当百分比。' });
      vms.push(vm);
    }
  });
  return { vms, issues, warnings };
}

export function validatePrices(sheet: Sheet): { prices: Price[]; issues: Issue[] } {
  const prices: Price[] = [], issues: Issue[] = [];
  const headers = new Map(sheet.headers.map(h => [h.toLowerCase(), h]));
  if (PRICE_HEADERS.some(h => h !== 'to' && !headers.has(h.toLowerCase())))
    return { prices, issues: [{ row: 1, field: '价格表头', message: `请使用价格模板：${PRICE_HEADERS.join(', ')}。` }] };
  sheet.rows.forEach((raw, i) => {
    const r = Object.fromEntries(PRICE_HEADERS.map(h => [h, (raw[headers.get(h.toLowerCase()) ?? h] ?? '').trim()]));
    const bad = (message: string) => issues.push({ row: i + 2, field: '价格', message });
    if (!/^Standard_[A-Za-z0-9_-]+$/i.test(r.sku) || !r.region || !r.source || !/^[A-Z]{3}$/i.test(r.currency)) return bad('SKU、区域、币种或来源缺失/非法。');
    if (!['Commercial','China','Government','Sovereign'].includes(r.cloud) || !['Linux','Windows'].includes(r.os) ||
      !['PAYG','RI','SavingsPlan'].includes(r.purchase) || !['customer','retail','demo'].includes(r.kind) ||
      !['baseline','effective'].includes(r.basis) || r.unit !== '1 Hour') return bad('云、OS、购买方式、来源类型、basis 或单位不符合模板。');
    if (!/^(?:\d+(?:\.\d*)?|\.\d+)$/.test(r.rate) || !Number.isFinite(Number(r.rate)) || Number(r.rate) > Number.MAX_SAFE_INTEGER) return bad('小时费率须为非负有限数值。');
    if (!isDate(r.from) || (r.to && (!isDate(r.to) || r.from >= r.to))) return bad('有效期间非法。');
    if (!/^(yes|no|true|false)$/i.test(r.includesUpdate)) return bad('includesUpdate 填 yes/no。');
    const p: Price = { sku: r.sku, region: normalizeRegion(r.region), cloud: r.cloud as Price['cloud'],
      os: r.os, currency: r.currency.toUpperCase(), purchase: r.purchase as Price['purchase'], unit: '1 Hour',
      rate: Number(r.rate), from: r.from, to: r.to || undefined, basis: r.basis as Price['basis'],
      includesUpdate: /^(yes|true)$/i.test(r.includesUpdate), source: r.source, kind: r.kind as Price['kind'] };
    prices.push(p);
  });
  return { prices, issues };
}

export function mergeSupplement(base: Sheet, supplement: Sheet, baseMap: Record<string,string>, extraMap: Record<string,string>): Sheet {
  if (!baseMap.id || !extraMap.id) throw new Error('主表与补充表都需要映射资源唯一标识。');
  const index = new Map<string, RawRow>();
  for (const row of supplement.rows) {
    const id = row[extraMap.id]?.trim().toLowerCase();
    if (!id) throw new Error('补充表存在缺失资源标识。');
    if (index.has(id)) throw new Error(`补充表标识重复：${id}。请先汇总，避免错误连接。`);
    index.set(id, row);
  }
  const normalized = base.rows.map(row => {
    const result = Object.fromEntries(FIELDS.map(f => [f.key, row[baseMap[f.key]] ?? '']));
    const extra = index.get(row[baseMap.id]?.trim().toLowerCase());
    if (!extra) return result;
    index.delete(row[baseMap.id]?.trim().toLowerCase());
    for (const f of FIELDS.filter(f => f.key !== 'id')) {
      const value = (extra[extraMap[f.key]] ?? '').trim();
      if (!value) continue;
      if (result[f.key]?.trim() && result[f.key].trim() !== value) throw new Error(`标识 ${result.id} 的 ${f.label} 冲突；请在源文件修正后重试。`);
      result[f.key] = value;
    }
    return result;
  });
  if (index.size) throw new Error(`补充表有 ${index.size} 个无法关联的标识；请先解决，不会静默忽略。`);
  return { name: '已关联资料', headers: FIELDS.map(f => f.key), rows: normalized };
}

export function toCsv(rows: Record<string, unknown>[], headers?: string[]): string {
  const fields = headers ?? (rows.length ? Object.keys(rows[0]) : []);
  const safe = (value: unknown) => {
    const text = value === null || value === undefined ? '' : String(value);
    return /^[\s\uFEFF]*[=+\-@\t\r]/.test(text) ? `'${text}` : text;
  };
  return '\uFEFF' + Papa.unparse({ fields, data: rows.map(r => fields.map(h => safe(r[h]))) });
}
export const fieldDescription = (field: Field) => `${field.label}${field.hint ? ` · ${field.hint}` : ''}`;
