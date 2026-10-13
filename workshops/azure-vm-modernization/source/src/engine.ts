import { CATALOG, KNOWN_COMMERCIAL_REGIONS, LEGACY, REGIONS, STORAGE_EXCLUDED, STORAGE_INCLUDED, V4_LIFTED, V7_EXEMPT } from './data';
import type { Analysis, Candidate, Effect, Lifecycle, Options, Price, Vm } from './model';

export const isDate = (s: string) => /^\d{4}-\d{2}-\d{2}$/.test(s) &&
  Number.isFinite(Date.parse(`${s}T00:00:00Z`)) && new Date(`${s}T00:00:00Z`).toISOString().slice(0, 10) === s;
export const hours = (v: Vm): number | null => v.hoursTotal ?? (v.hoursPerVM === undefined ? null : v.hoursPerVM * v.count);
export const rounded = (n: number): number | null => Number.isFinite(n) ? Math.round((n + Number.EPSILON) * 100) / 100 : null;
const yesSource = (v: Vm, o: Options) => !!v.priceSource && !!v.priceKind && (o.mode === 'scenario' || v.priceKind !== 'demo');

export function seriesOf(sku: string): string | null {
  const s = sku.replace(/^Standard_/i, '');
  const fixed: [RegExp, string][] = [
    [/^DS\d+_v2$/i, 'Dsv2'], [/^D\d+_v2$/i, 'Dv2'],
    [/^A\d+m_v2$/i, 'Amv2'], [/^A\d+_v2$/i, 'Av2'],
    [/^F\d+s_v2$/i, 'Fsv2'], [/^L\d+s_v2$/i, 'Lsv2'],
    [/^B\d+(?:s|ms|ls)$/i, 'Bv1'], [/^DS\d+$/i, 'Ds'], [/^D\d+$/i, 'D'],
    [/^F\d+s$/i, 'Fs'], [/^F\d+$/i, 'F'], [/^GS\d+$/i, 'Gs'], [/^G\d+$/i, 'G'],
    [/^L\d+s$/i, 'Ls'], [/^NP(?:10|20|40)s$/i, 'NP'], [/^HC44rs$/i, 'HC'],
  ];
  for (const [pattern, series] of fixed) if (pattern.test(s)) return series;
  const m = /^([DE])\d+(s|ds|d|as|a|ads|ad|ls|lds|als|alds)?_v([3-7])$/i.exec(s);
  if (!m) return null;
  const family = m[1].toUpperCase(), suffix = (m[2] || '').toLowerCase(), gen = Number(m[3]);
  if (gen === 3 && !['', 's'].includes(suffix)) return null;
  if (gen === 4 && !['', 's', 'd', 'ds', 'a', 'as'].includes(suffix)) return null;
  if (gen === 5 && !['', 's', 'd', 'ds', 'as', 'ads'].includes(suffix)) return null;
  if (family === 'E' && ['ls', 'lds', 'als', 'alds'].includes(suffix)) return null;
  return `${family}${suffix}v${gen}`;
}

export function lifecycle(series: string | null, cloud: Vm['cloud'], date: string): Lifecycle {
  if (!series) return { stage: '待核验', note: '不在精确识别目录内；请核对该系列公告，不视为无风险。' };
  const v3 = ['Dv3', 'Dsv3', 'Ev3', 'Esv3'].includes(series);
  if (v3 && ['China', 'Government', 'Sovereign'].includes(cloud))
    return { stage: '公告排除', note: '该 v3 退役公告明确排除此云；不代表其他生命周期或价格公告也不适用。' };
  const deadlines: Record<string, string> = {
    Dv3: '2029-11-15', Dsv3: '2029-11-15', Ev3: '2029-11-15', Esv3: '2029-11-15',
    D: '2028-05-01', Ds: '2028-05-01', Dv2: '2028-05-01', Dsv2: '2028-05-01', Ls: '2028-05-01',
    Bv1: '2028-11-15', Av2: '2028-11-15', Amv2: '2028-11-15', F: '2028-11-15',
    Fs: '2028-11-15', Fsv2: '2028-11-15', G: '2028-11-15', Gs: '2028-11-15', Lsv2: '2028-11-15',
    NP: '2027-05-31', HC: '2027-05-31',
  };
  if (deadlines[series]) {
    if (cloud !== 'Commercial')
      return { stage: '待核验', note: '需按该系列公告单独核验云环境范围；不套用 v3 排除规则。' };
    return { stage: date >= deadlines[series] ? 'Retired' : 'End of Life', date: deadlines[series],
      note: date >= deadlines[series] ? '退役日期已到：不能继续运行或创建此系列，优先核验实际状态。' : '公开已宣布退役；在对应期限前完成过渡，不等于现在停机。' };
  }
  if (/v[45]$/.test(series)) return { stage: 'Extended', note: '受支持的现代化过渡目标；仍需核验具体系列及区域。' };
  if (/v[67]$/.test(series)) return { stage: 'Current', note: '较新代际；具体部署受镜像、区域、配额与容量约束。' };
  return { stage: '待核验', note: '请查该系列生命周期，不从版本号泛化。' };
}

export function vmEffect(series: string | null, cloud: Vm['cloud'], region: string, o: Options): Effect {
  if (o.mode !== 'scenario') return { percent: null, reason: '客户模式不自动套用未公开核验的涨幅；按有效价格依据。', rule: 'CUSTOMER-PRICE' };
  if (o.date < '2027-02-01') return { percent: 0, reason: '评估日在培训情景生效日前。', rule: 'BEFORE-EFFECTIVE' };
  if (cloud === 'Unknown') return { percent: null, reason: '云环境未确认，无法判定适用范围。', rule: 'UNKNOWN-CLOUD' };
  if (!series) return { percent: null, reason: 'SKU 系列未确认，不能判断调价及排除规则。', rule: 'UNKNOWN-SERIES' };
  if (LEGACY.includes(series)) return cloud === 'Commercial'
    ? { percent: o.legacyPercent, reason: `旧代际培训情景 +${o.legacyPercent}%；排除区域 VM 调价，不叠加。`, rule: 'LEGACY-BASE' }
    : { percent: 0, reason: '邮件旧代际价格情景明确排除此云；不推论其他调价。', rule: 'LEGACY-CLOUD-EXCLUDED' };
  if (cloud !== 'Commercial') return { percent: null, reason: '未独立核验此云的区域价格政策，需适用通知。', rule: 'REGION-CLOUD-REVIEW' };
  if (V7_EXEMPT.includes(series)) return { percent: 0, reason: '指定 v7 系列在区域 VM 调价排除清单内。', rule: 'V7-EXCLUDED' };
  if (!KNOWN_COMMERCIAL_REGIONS.has(region)) return { percent: null, reason: '区域代码不在离线核验目录内，需确认映射及适用通知。', rule: 'UNKNOWN-REGION' };
  return { percent: REGIONS[region] ?? 0, reason: REGIONS[region] ? `区域培训情景 +${REGIONS[region]}%；适用计量项仍需通知核对。` : '不在本次七区域情景中；不代表所有价格永远不变。', rule: 'REGIONAL-VM' };
}

export function storageEffect(product: string | undefined, cloud: Vm['cloud'], region: string, o: Options): Effect {
  if (!product) return { percent: null, reason: '未提供存储产品/计量项。', rule: 'STORAGE-MISSING' };
  if (o.mode === 'customer') return { percent: null, reason: '客户模式需同用量的有效存储成本依据。', rule: 'STORAGE-CUSTOMER' };
  if (o.date < '2027-02-01') return { percent: 0, reason: '培训情景尚未生效。', rule: 'STORAGE-BEFORE' };
  if (cloud !== 'Commercial') return { percent: null, reason: '该云存储价格适用范围未核验。', rule: 'STORAGE-CLOUD' };
  if (!KNOWN_COMMERCIAL_REGIONS.has(region)) return { percent: null, reason: '区域代码需核验，不能推断无存储影响。', rule: 'STORAGE-REGION-UNKNOWN' };
  if (!REGIONS[region]) return { percent: 0, reason: '不在七区域情景。', rule: 'STORAGE-REGION-EXCLUDED' };
  const key = product.trim().toLowerCase();
  if (STORAGE_EXCLUDED.some(x => x.toLowerCase() === key))
    return { percent: 0, reason: '精确产品/计量项在存储排除清单内。', rule: 'STORAGE-EXCLUDED' };
  if (['files', 'files v2', 'azure netapp files'].includes(key))
    return { percent: null, reason: '必须确认具体 SKU：Files 排除 Transaction-Optimized，ANF 排除 Cross Region Replication。', rule: 'STORAGE-AMBIGUOUS' };
  if (STORAGE_INCLUDED.some(x => x.toLowerCase() === key))
    return { percent: REGIONS[region], reason: `存储培训情景 +${REGIONS[region]}%；仅限所识别产品，非所有存储。`, rule: 'STORAGE-INCLUDED' };
  return { percent: null, reason: '产品名或计量项不在精确目录内，请补充/核验。', rule: 'STORAGE-UNKNOWN' };
}

type RateResult = { rate: number | null; source: string; note: string };
function lookupPrice(v: Vm, sku: string, purchase: Vm['purchase'], prices: Price[], o: Options): { price?: Price; conflict: boolean } {
  const matches = prices.filter(p => p.sku.toLowerCase() === sku.toLowerCase() && p.region === v.region && p.cloud === v.cloud &&
    p.os.toLowerCase() === v.os.toLowerCase() && p.currency === v.currency && p.purchase === purchase &&
    p.from <= o.date && (!p.to || o.date < p.to) && (o.mode === 'scenario' || p.kind !== 'demo'));
  return { price: matches.length === 1 ? matches[0] : undefined, conflict: matches.length > 1 };
}

function rateFor(v: Vm, sku: string, prices: Price[], o: Options, target = false): RateResult {
  const found = lookupPrice(v, sku, target ? 'PAYG' : v.purchase, prices, o);
  if (found.conflict) return { rate: null, source: '', note: '存在多个同时有效的同口径价格快照，需解决冲突。' };
  let p = found.price;
  if (!p && !target && v.currentRate !== undefined && yesSource(v, o) && v.rateBasis && v.rateFrom && v.rateFrom <= o.date && (!v.rateTo || o.date < v.rateTo) && v.currency) {
    p = { sku, region: v.region, cloud: v.cloud, os: v.os, currency: v.currency, purchase: v.purchase,
      unit: '1 Hour', rate: v.currentRate, basis: v.rateBasis, from: v.rateFrom, to: v.rateTo,
      includesUpdate: v.priceIncludesUpdate === true, source: v.priceSource!, kind: v.priceKind! };
  }
  if (!p) return { rate: null, source: '', note: '缺少匹配云/区域/SKU/OS/币种/购买方式/有效日的可信小时价格。' };
  const label = `${p.kind === 'demo' ? '教学模拟' : p.kind === 'retail' ? '公开零售参考，非合同净价' : '客户提供价格'}：${p.source}`;
  if (p.basis === 'effective' && p.includesUpdate) return { rate: p.rate, source: label, note: '已生效且含调整，不重复叠加涨幅。' };
  if (o.mode === 'customer') return { rate: null, source: label, note: '客户模式要求 effective、includesUpdate=yes 的评估日有效价格。' };
  if (p.basis === 'effective') return { rate: null, source: label, note: '有效费率是否含调整未确认，拒绝重复或遗漏计价。' };
  const effect = vmEffect(seriesOf(sku), v.cloud, v.region, o);
  if (effect.percent === null) return { rate: null, source: label, note: effect.reason };
  let increased = p.rate * (1 + effect.percent / 100);
  if (!target && v.purchase === 'RI') {
    if (v.costBasis !== 'Amortized')
      return { rate: null, source: label, note: 'RI 基础费率情景只接受 Amortized 口径；Actual 需客户提供已生效、已归一化的期间费率。' };
    if (v.riCoverage === undefined || !v.riEnd || (o.date < v.riEnd && v.riRate === undefined))
      return { rate: null, source: label, note: 'RI 情景需要覆盖比例、到期日及已覆盖小时费率。' };
    const covered = o.date < v.riEnd ? v.riCoverage / 100 : 0;
    increased = (v.riRate ?? 0) * covered + increased * (1 - covered);
  } else if (!target && v.purchase !== 'PAYG') {
    return { rate: null, source: label, note: 'Savings Plan/混合购买需提供已生效净费率与承诺消耗依据，不能用固定折扣推算。' };
  }
  if (v.agreement === 'EA' && effect.percent > 0) {
    if (!v.eaRenewal) return { rate: null, source: label, note: '缺少 EA enrollment 续约日，不能判定价格上限。' };
    if (o.date < v.eaRenewal) {
      if (target) return { rate: null, source: label, note: '目标 SKU 的 EA 价格上限/合同价需单独提供，不能沿用源 SKU 上限。' };
      if (v.eaCapRate === undefined) return { rate: null, source: label, note: 'EA 续约前缺少可适用的 PAYG 小时价格上限。' };
      const payg = Math.min(p.rate * (1 + effect.percent / 100), v.eaCapRate);
      if (!target && v.purchase === 'RI') {
        const coverage = v.riEnd && o.date < v.riEnd ? (v.riCoverage ?? 0) / 100 : 0;
        increased = (v.riRate ?? 0) * coverage + payg * (1 - coverage);
      } else increased = payg;
    }
  } else if (v.agreement === 'Unknown' && effect.percent > 0) {
    return { rate: null, source: label, note: '协议未知，无法判定实际调价处理。' };
  }
  return { rate: increased, source: label, note: '固定用量培训情景；非实际跨期账单预测。' };
}

export function analyze(v: Vm, prices: Price[], o: Options): Analysis {
  const series = seriesOf(v.sku), life = lifecycle(series, v.cloud, o.date);
  const effect = vmEffect(series, v.cloud, v.region, o), se = storageEffect(v.storageProduct, v.cloud, v.region, o);
  const h = v.usageUnit === '1 Hour' ? hours(v) : null;
  const sourceRate = rateFor(v, v.sku, prices, o);
  const notes = ['区域/可用区、订阅配额和实时容量：部署前待核验。'];
  let baseline: number | null = null;
  if (v.currency && v.costBasis && yesSource(v, o)) {
    if (v.currentCost !== undefined) baseline = rounded(v.currentCost);
    else if (v.currentRate !== undefined && h !== null) {
      if (v.purchase === 'PAYG') baseline = rounded(v.currentRate * h);
      else if (v.purchase === 'RI' && v.riCoverage !== undefined && v.riRate !== undefined)
        baseline = rounded(((v.currentRate * (1 - v.riCoverage / 100)) + v.riRate * v.riCoverage / 100) * h);
    }
  }
  const noChange = h !== null && v.currency && v.costBasis && sourceRate.rate !== null ? rounded(h * sourceRate.rate) : null;
  if (h === null) notes.push('缺少 1 Hour 单位的明确实例小时口径；无法量化计算费。');
  if (noChange === null) notes.push(sourceRate.note);
  const commitment = v.purchase === 'SavingsPlan' || v.purchase === 'Mixed' || v.purchase === 'Unknown' ||
    (v.purchase === 'RI' && (!v.riEnd || o.date < v.riEnd));
  if (commitment) notes.push('购买承诺不能随配置自动消失；跨系列 RI 适用性、SP 重新消耗和剩余承诺需单独核验。');
  if (V4_LIFTED.includes(series ?? '')) notes.push('邮件提及此 v4 容量增长限制解除；核验状态为培训材料，不能承诺容量或自动配额审批。');
  if (life.stage === 'Retired') notes.push('源系列评估日已退役：情景成本不代表允许继续运行，优先核验和恢复/迁移。');
  let storageFuture: number | null = null;
  if (yesSource(v, o) && v.currency && v.costBasis) {
    if (v.futureStorageCost !== undefined && v.rateBasis === 'effective' && v.priceIncludesUpdate === true &&
      v.rateFrom && v.rateFrom <= o.date && (!v.rateTo || o.date < v.rateTo))
      storageFuture = rounded(v.futureStorageCost);
    else if (v.storageCost !== undefined && o.mode === 'scenario') {
      if (v.storagePriceIncludesUpdate === true) storageFuture = rounded(v.storageCost);
      else if (se.percent !== null && (se.percent === 0 || v.agreement === 'MCA'))
        storageFuture = rounded(v.storageCost * (1 + se.percent / 100));
    }
  }
  const sourceSpec = CATALOG.find(s => s.name.toLowerCase() === v.sku.toLowerCase());
  const cpu = v.vcpus ?? sourceSpec?.cores, ram = v.memoryGiB ?? sourceSpec?.memory;
  const family = series?.startsWith('D') ? 'D' : series?.startsWith('E') ? 'E' : null;
  const metricsReady = cpu !== undefined && ram !== undefined && v.cpuP95 !== undefined && v.memoryP99 !== undefined &&
    v.networkP95Mbps !== undefined && (v.observationDays ?? 0) >= o.minDays && v.peakCovered === true &&
    v.tempGiB !== undefined && v.dataDisks !== undefined && v.nics !== undefined && v.diskIOPS !== undefined && v.diskMBps !== undefined &&
    v.architecture === 'x64' && v.specialRequirements === 'none' && v.workload !== 'unknown';
  if (!metricsReady) notes.push('性能/峰值/兼容依据不完整：只筛选不降低源 CPU/内存容量的现代化候选，不给确定缩容结论。');
  const cpuTarget = v.workload === 'batch' ? o.batchTarget : o.cpuTarget;
  const memoryTarget = v.workload === 'batch' ? o.batchTarget : o.memoryTarget;
  const requiredCpu = cpu === undefined ? null : metricsReady ? cpu * v.cpuP95! / cpuTarget : cpu;
  const requiredRam = ram === undefined ? null : metricsReady ? ram * v.memoryP99! / memoryTarget : ram;
  let candidates: Candidate[] = [];
  if (family && cpu !== undefined && ram !== undefined && v.specialRequirements !== 'manual' && (!v.architecture || v.architecture === 'x64')) {
    candidates = CATALOG.filter(s => s.family === family && s.cores >= requiredCpu! && s.memory >= requiredRam! &&
      s.name.toLowerCase() !== v.sku.toLowerCase() &&
      (v.tempGiB === undefined || s.temp >= v.tempGiB) &&
      (v.dataDisks === undefined || s.disks >= v.dataDisks) &&
      (v.nics === undefined || s.nics >= v.nics) &&
      (v.diskIOPS === undefined || s.iops >= v.diskIOPS) &&
      (v.diskMBps === undefined || s.throughput >= v.diskMBps) &&
      (v.networkP95Mbps === undefined || s.network * cpuTarget / 100 >= v.networkP95Mbps)
    ).map(s => {
      const blockers = ['区域/可用区、配额与容量待核验', '实际应用性能基线、备份和回退演练待验证'];
      if (!metricsReady) blockers.push('指标/峰值不足，未执行缩容');
      if (v.tempGiB === undefined) blockers.push('临时盘依赖未知');
      if (v.dataDisks === undefined || v.diskIOPS === undefined || v.diskMBps === undefined) blockers.push('磁盘配置和性能约束待补齐');
      if (v.nics === undefined || v.networkP95Mbps === undefined) blockers.push('网卡和网络指标待补齐');
      if (v.architecture !== 'x64' || v.specialRequirements !== 'none') blockers.push('架构/认证/托管计算要求待确认');
      if (s.generation === 5 && v.accelNetworking !== true) blockers.push('此 Intel v5 目标要求加速网络，需准备');
      if (s.generation >= 6) {
        if (v.bootGeneration !== 2) blockers.push('需 Gen2 镜像；不能盲目原地 resize');
        if (v.nvmeReady !== true) blockers.push('NVMe 镜像/驱动尚未就绪');
        if (v.manaReady !== true) blockers.push('MANA 网络驱动尚未就绪');
      }
      if (v.licenseReady !== true) blockers.push('许可与供应商认证待核验');
      const r = rateFor(v, s.name, prices, o, true);
      const cost = h !== null && v.currency && v.costBasis && r.rate !== null ? rounded(h * r.rate) : null;
      const total = cost === null || (commitment && v.residualCommitmentCost === undefined) ? null :
        rounded(cost + (commitment ? v.residualCommitmentCost! : 0));
      if (cost === null) blockers.push(r.note);
      if (commitment && v.residualCommitmentCost === undefined) blockers.push('剩余承诺成本未知，不能输出可兑现差额');
      return { sku: s, cost, totalWithCommitment: total, difference: total !== null && noChange !== null ? rounded(noChange - total) : null,
        blockers, source: r.source, downsizing: s.cores < cpu || s.memory < ram,
        reasons: [`${s.cores} vCPU / ${s.memory} GiB；${s.temp ? `${s.temp} GiB 临时盘` : '无临时盘'}`,
          metricsReady ? `投影约束：CPU ≥ ${requiredCpu!.toFixed(2)} 核、内存 ≥ ${requiredRam!.toFixed(2)} GiB；不假设跨代 CPU 加速。` : `保留不低于源 ${cpu} 核 / ${ram} GiB 的容量。`,
          `远程盘 ${s.disks} 个 / ${s.iops} IOPS / ${s.throughput} MB/s；网络 ${s.network} Mbps（上限非保证）。`,
          s.generation === 5 ? 'v5：Extended，低扰动过渡路径；resize 仍可能需要停机/释放。' : `v${s.generation}：Current，按 Gen2/NVMe/MANA 现代化路径验证。`] };
    });
    candidates.sort((a, b) => {
      if (a.cost !== null && b.cost !== null) return a.cost - b.cost || a.sku.cores - b.sku.cores;
      if (a.cost !== null) return -1;
      if (b.cost !== null) return 1;
      return a.sku.cores - b.sku.cores || a.sku.generation - b.sku.generation;
    });
    const generations = new Set<number>();
    candidates = candidates.filter(c => !generations.has(c.sku.generation) && !!generations.add(c.sku.generation)).slice(0, 3);
    if (!candidates.length) notes.push('有限目录中没有满足约束的候选：不要放宽条件强行推荐，需扩充目录或专项评估。');
  } else notes.push('未给通用替代 SKU：特殊计算、未支持系列、源 CPU/内存缺失或专项认证要求需人工评估。');
  const wave = life.stage === 'Retired' ? '波次 1 · 退役状态核验与恢复/迁移' :
    !metricsReady || v.specialRequirements === 'manual' ? '准备队列 · 补数据/专项评估' :
      life.date ? '波次 1 · 退役期限与业务风险优先' : '波次 2 · 小范围验证与持续优化';
  return { vm: v, series, lifecycle: life, effect, storageEffect: se, baseline, noChange, storageFuture,
    candidates, notes, wave, priceEvidence: sourceRate.source, priceExplanation: sourceRate.note,
    priceNote: `${sourceRate.source || '价格依据不足'}；${sourceRate.note}` };
}

export function summarize(rows: Analysis[]) {
  const groups = new Map<string, { key: string; currency: string; basis: string; known: number; total: number; cost: number; difference: number; comparable: number }>();
  for (const a of rows) {
    const key = `${a.vm.cloud} / ${a.vm.currency || '未知币种'} / ${a.vm.costBasis || '未知口径'}`;
    const g = groups.get(key) ?? { key, currency: a.vm.currency || '', basis: a.vm.costBasis || '', known: 0, total: 0, cost: 0, difference: 0, comparable: 0 };
    g.total++;
    if (a.noChange !== null) { g.known++; g.cost += a.noChange; }
    const c = a.candidates[0];
    if (c?.difference !== null && c?.difference !== undefined) { g.comparable++; g.difference += c.difference; }
    groups.set(key, g);
  }
  return [...groups.values()];
}
