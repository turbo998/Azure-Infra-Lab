export type Cloud = 'Commercial' | 'China' | 'Government' | 'Sovereign' | 'Unknown';
export type Purchase = 'PAYG' | 'RI' | 'SavingsPlan' | 'Mixed' | 'Unknown';
export type PriceKind = 'customer' | 'retail' | 'demo';
export type RawRow = Record<string, string>;
export type Issue = { row: number; field: string; message: string };
export type Vm = {
  id: string; name: string; sku: string; region: string; cloud: Cloud; os: string;
  count: number; hoursTotal?: number; hoursPerVM?: number; usageUnit?: string;
  periodStart?: string; periodEnd?: string; subscription?: string;
  vcpus?: number; memoryGiB?: number; cpuP95?: number; memoryP99?: number;
  networkP95Mbps?: number; observationDays?: number; peakCovered?: boolean;
  tempGiB?: number; dataDisks?: number; nics?: number; diskIOPS?: number; diskMBps?: number;
  architecture?: string; bootGeneration?: number; accelNetworking?: boolean;
  nvmeReady?: boolean; manaReady?: boolean; specialRequirements?: string; licenseReady?: boolean;
  workload: 'user-facing' | 'batch' | 'unknown';
  agreement: 'EA' | 'MCA' | 'Unknown'; purchase: Purchase;
  riCoverage?: number; riEnd?: string; riRate?: number; eaRenewal?: string; eaCapRate?: number;
  currentRate?: number; currentCost?: number; currency?: string; costBasis?: 'Actual' | 'Amortized';
  rateBasis?: 'baseline' | 'effective'; rateFrom?: string; rateTo?: string;
  priceIncludesUpdate?: boolean; priceSource?: string; priceKind?: PriceKind;
  residualCommitmentCost?: number; storageProduct?: string; storageCost?: number;
  futureStorageCost?: number; storagePriceIncludesUpdate?: boolean;
};
export type Field = { key: keyof Vm; label: string; group: string; aliases?: string[]; required?: boolean; hint?: string };
export type Sku = {
  name: string; family: 'D' | 'E'; generation: number; cores: number; memory: number;
  temp: number; disks: number; iops: number; throughput: number; network: number; nics: number;
  source: string;
};
export type Price = {
  sku: string; region: string; cloud: Cloud; os: string; currency: string; purchase: Purchase;
  unit: '1 Hour'; rate: number; from: string; to?: string; basis: 'baseline' | 'effective';
  includesUpdate: boolean; source: string; kind: PriceKind;
};
export type Options = {
  mode: 'scenario' | 'customer'; date: string; legacyPercent: number;
  cpuTarget: number; memoryTarget: number; batchTarget: number; minDays: number;
  title: string; redact: boolean;
};
export type Effect = { percent: number | null; reason: string; rule: string };
export type Lifecycle = { stage: string; date?: string; note: string };
export type Candidate = {
  sku: Sku; cost: number | null; totalWithCommitment: number | null; difference: number | null;
  blockers: string[]; reasons: string[]; downsizing: boolean; source: string;
};
export type Analysis = {
  vm: Vm; series: string | null; lifecycle: Lifecycle; effect: Effect; storageEffect: Effect;
  baseline: number | null; noChange: number | null; storageFuture: number | null;
  priceNote: string; priceEvidence: string; priceExplanation: string;
  candidates: Candidate[]; notes: string[]; wave: string;
};
export const DEFAULT_OPTIONS: Options = {
  mode: 'scenario', date: '2027-02-01', legacyPercent: 25,
  cpuTarget: 40, memoryTarget: 60, batchTarget: 80, minDays: 30,
  title: 'Azure VM 现代化评估', redact: true,
};

const f = (key: keyof Vm, label: string, group: string, extras: Partial<Field> = {}): Field =>
  ({ key, label, group, ...extras });
export const FIELDS: Field[] = [
  f('id', '资源唯一标识', '必填', { required: true, aliases: ['ResourceId', 'Resource ID', 'VM_ID'] }),
  f('sku', 'ARM SKU', '必填', { required: true, aliases: ['VmSize', 'VM Size', 'armSkuName'], hint: '必须为 Standard_…，不从计量项名称猜测。' }),
  f('region', '部署区域', '必填', { required: true, aliases: ['ResourceLocation', 'armRegionName', 'Location'] }),
  f('count', '实例数', '必填', { required: true, aliases: ['InstanceCount', 'VMCount'], hint: '逐台记录填 1；账单 Quantity 不是实例数。' }),
  f('name', 'VM/组名称', '部署', { aliases: ['ResourceName', 'VMName'] }),
  f('subscription', '订阅标识', '部署', { aliases: ['SubscriptionId'] }),
  f('cloud', '云环境', '部署', { hint: 'Commercial / China / Government / Sovereign / Unknown' }),
  f('os', '操作系统', '部署', { hint: 'Linux / Windows；其他名称不自动匹配价格。' }),
  f('hoursTotal', '实例小时总量', '用量', { aliases: ['UsageHoursTotal'], hint: '所有实例的总小时，不能再乘实例数。' }),
  f('hoursPerVM', '每实例运行小时', '用量', { aliases: ['HoursPerInstance'], hint: '与实例小时总量互斥。' }),
  f('usageUnit', '用量单位', '用量', { aliases: ['UnitOfMeasure'], hint: '1 Hour；不接受每核小时等其他单位。' }),
  f('periodStart', '源期间开始', '用量', { hint: 'YYYY-MM-DD，包含当日。' }),
  f('periodEnd', '源期间结束', '用量', { hint: 'YYYY-MM-DD，不包含当日。' }),
  f('vcpus', '源 vCPU 数', '性能'),
  f('memoryGiB', '源内存 GiB', '性能'),
  f('cpuP95', 'CPU P95 %', '性能', { aliases: ['CPU_P95'], hint: '填 0–100；不是平均 CPU。' }),
  f('memoryP99', '内存 P99 %', '性能', { aliases: ['Memory_P99'], hint: '填 0–100；缺少内存时不做确定性缩容。' }),
  f('networkP95Mbps', '网络 P95 Mbps', '性能', { hint: '发送网络带宽，不是百分比或 MB/s。' }),
  f('observationDays', '观察窗口天数', '性能'),
  f('peakCovered', '已覆盖业务峰值', '性能', { hint: 'yes / no / 留空未知' }),
  f('workload', '工作负载类型', '性能', { hint: 'user-facing / batch / unknown' }),
  f('tempGiB', '所需临时盘 GiB', '兼容', { hint: '明确不依赖临时盘填 0；留空未知。' }),
  f('dataDisks', '所需数据盘数', '兼容'),
  f('nics', '所需网卡数', '兼容'),
  f('diskIOPS', '所需远程盘 IOPS', '兼容'),
  f('diskMBps', '所需远程盘 MB/s', '兼容'),
  f('architecture', 'CPU 架构', '兼容', { hint: 'x64；Arm 等需专项评估。' }),
  f('bootGeneration', '启动代次', '兼容', { hint: '1 / 2' }),
  f('accelNetworking', '加速网络就绪', '兼容'),
  f('nvmeReady', 'NVMe 镜像就绪', '兼容'),
  f('manaReady', 'MANA 驱动就绪', '兼容'),
  f('specialRequirements', '专用要求', '兼容', { hint: 'none / manual；认证、托管计算、特殊许可填 manual。' }),
  f('licenseReady', '许可核验完成', '兼容'),
  f('agreement', '协议类型', '商务', { hint: 'EA / MCA / Unknown' }),
  f('purchase', '购买方式', '商务', { hint: 'PAYG / RI / SavingsPlan / Mixed / Unknown' }),
  f('riCoverage', 'RI 覆盖比例 %', '商务'),
  f('riEnd', 'RI 到期日', '商务'),
  f('riRate', 'RI 已覆盖小时费率', '商务'),
  f('eaRenewal', 'EA enrollment 续约日', '商务'),
  f('eaCapRate', 'EA PAYG 小时价格上限', '商务'),
  f('residualCommitmentCost', '迁移后剩余承诺成本', '商务', { hint: '与本次固定用量比较期间一致；不是承诺年费。' }),
  f('currentRate', '源 PAYG/有效小时费率', '价格', { hint: 'RI 基准模式此列填 PAYG 基础费率。' }),
  f('currentCost', '源计算成本', '价格', { aliases: ['CostInBillingCurrency'], hint: '仅 VM 计算；不能含磁盘、税费、许可等。' }),
  f('currency', '币种', '价格', { aliases: ['BillingCurrencyCode', 'CurrencyCode'] }),
  f('costBasis', '成本口径', '价格', { hint: 'Actual / Amortized' }),
  f('rateBasis', '费率基准', '价格', { hint: 'baseline 为情景前基准；effective 为已生效费率。' }),
  f('rateFrom', '费率生效日', '价格'),
  f('rateTo', '费率失效日', '价格', { hint: '不包含当日。' }),
  f('priceIncludesUpdate', '价格已含此次调整', '价格'),
  f('priceSource', '价格依据', '价格'),
  f('priceKind', '价格来源类型', '价格', { hint: 'customer / retail / demo' }),
  f('storageProduct', '关联存储产品/计量项', '存储'),
  f('storageCost', '源关联存储成本', '存储'),
  f('futureStorageCost', '客户有效关联存储成本', '存储', { hint: '评估日对应相同用量的客户依据值。' }),
  f('storagePriceIncludesUpdate', '存储成本已含调整', '存储'),
];

export const PRICE_HEADERS = ['sku', 'region', 'cloud', 'os', 'currency', 'purchase', 'unit', 'rate', 'from', 'to', 'basis', 'includesUpdate', 'source', 'kind'];
