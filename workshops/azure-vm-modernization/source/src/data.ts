import type { Sku, Vm, Price } from './model';

export const VERSION = '1.0 · 核验 2026-10-12';
export const SOURCES = [
  ['生命周期阶段', 'https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/lifecycle-overview'],
  ['退役与容量限制', 'https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/retirements-and-capacity-restrictions'],
  ['v5 现代化路径', 'https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v5-modernization-overview'],
  ['v6/v7 平台准备', 'https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/lifecycle/sizes-v6-v7-modernization-overview'],
  ['Advisor 优化依据与限制', 'https://learn.microsoft.com/en-us/azure/advisor/advisor-cost-recommendations'],
  ['零售价格 API 与商业云范围', 'https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices'],
];
export const REGIONS: Record<string, number> = {
  westeurope: 9, northeurope: 17, francecentral: 11, francesouth: 11,
  norwayeast: 9, norwaywest: 9, southeastasia: 8,
};
export const KNOWN_COMMERCIAL_REGIONS = new Set((
  'eastus eastus2 centralus northcentralus southcentralus westus westus2 westus3 westcentralus ' +
  'canadacentral canadaeast brazilsouth brazilsoutheast chilecentral mexicocentral ' +
  'westeurope northeurope francecentral francesouth norwayeast norwaywest swedencentral swedensouth ' +
  'germanywestcentral germanynorth switzerlandnorth switzerlandwest uksouth ukwest polandcentral italynorth spaincentral austriaeast belgiumcentral ' +
  'eastasia southeastasia japaneast japanwest koreacentral koreasouth centralindia southindia westindia jioindiacentral jioindiawest ' +
  'australiaeast australiasoutheast australiacentral australiacentral2 newzealandnorth ' +
  'southafricanorth southafricawest uaenorth uaecentral qatarcentral israelcentral saudiarabiaeast ' +
  'indonesiacentral malaysiasouth malaysiawest taiwannorth taiwannorthwest'
).split(' '));
export function normalizeRegion(s: string): string {
  const aliases: Record<string,string> = { euwest:'westeurope', eunorth:'northeurope', apsoutheast:'southeastasia', apeast:'eastasia', useast:'eastus', useast2:'eastus2', uswest:'westus', uswest2:'westus2' };
  const key = s.replace(/\s/g,'').toLowerCase();
  return aliases[key] ?? key;
}
export const LEGACY = ['Bv1', 'D', 'Ds', 'F', 'Fs', 'G', 'Gs', 'Ls', 'NP', 'HC', 'Av2', 'Amv2', 'Dv2', 'Dsv2', 'Fsv2', 'Lsv2'];
export const V7_EXEMPT = ['Dsv7', 'Ddsv7', 'Dlsv7', 'Dldsv7', 'Esv7', 'Edsv7'];
export const V4_LIFTED = ['Dv4', 'Dsv4', 'Ddv4', 'Ddsv4', 'Dav4', 'Dasv4', 'Ev4', 'Esv4', 'Edv4', 'Edsv4', 'Eav4', 'Easv4'];
export const STORAGE_INCLUDED = [
  'Standard HDD Managed Disks', 'Standard SSD Managed Disks', 'Premium SSD Managed Disks (v1)',
  'Azure Premium SSD v2', 'Ultra Disks', 'Azure Elastic SAN', 'Premium Page Blob', 'Standard Page Blob v2',
  'Blob Storage', 'General Block Blob v2', 'General Block Blob v2 Hierarchical Namespace',
  'ADLS Gen2 Flat Namespace', 'ADLS Gen2 Hierarchical Namespace', 'Storage Reserved Capacity',
  'Premium Block Blob', 'Premium Block Blob v2 Hierarchical Namespace', 'Premium ADLS Gen2 Flat Namespace',
  'Premium ADLS Gen2 Hierarchical Namespace', 'Files', 'Files v2', 'Premium Files (v1)',
  'Azure Files Provisioned v2', 'File Sync', 'Files Reserved Capacity', 'Premium Files Reserved Capacity', 'Azure NetApp Files',
];
export const STORAGE_EXCLUDED = [
  'Azure Container Storage', 'Azure Managed Lustre', 'Blob Features', 'Change Feed', 'General Block Blob',
  'Import/Export', 'Transaction Optimized SKU (Azure Files)', 'Files Transaction-Optimized',
  'Files v2 Transaction-Optimized', 'Queues', 'Queues v2', 'Standard Page Blob',
  'Azure NetApp Files - Cross Region Replication SKU', 'Storage Actions', 'Storage Bandwidth', 'Storage Discovery', 'Tables',
];

export const CATALOG: Sku[] = [];
const cores = [2, 4, 8, 16, 32, 48, 64];
for (const family of ['D', 'E'] as const) {
  for (const generation of [5, 6, 7]) {
    for (const local of generation === 5 ? [false, true] : [false]) {
      cores.forEach((c, i) => {
        const suffix = local ? 'ds' : 's';
        const series = `${family.toLowerCase()}${suffix}v${generation}-series`;
        CATALOG.push({
          name: `Standard_${family}${c}${suffix}_v${generation}`, family, generation, cores: c,
          memory: c * (family === 'D' ? 4 : 8), temp: local ? c * 37.5 : 0,
          disks: (generation === 5 ? [4, 8, 16, 32, 32, 32, 32] : generation === 6 ? [8, 12, 24, 48, 64, 64, 64] : [10, 12, 26, 48, 64, 64, 64])[i],
          iops: (generation === 7 ? [4000, 8000, 16000, 32000, 64000, 96000, 128000] : generation === 6 ? [3750, 6400, 12800, 25600, 51200, 76800, 102400] : [3750, 6400, 12800, 25600, 51200, 76800, 80000])[i],
          throughput: (generation === 5 ? [85, 145, 290, 600, 865, 1315, 1735] : generation === 6 ? [106, 212, 424, 848, 1696, 2544, 3392] : family === 'E' ? [115, 230, 460, 940, 1885, 2830, 3775] : [115, 230, 460, 920, 1840, 2760, 3680])[i],
          network: (generation === 7 ? [16000, 25000, 25000, 25000, 25000, 35000, 45000] : [12500, 12500, 12500, 12500, 16000, 24000, 30000])[i],
          nics: (generation === 7 ? [3, 4, 4, 8, 8, 8, 15] : [2, 2, 4, 8, 8, 8, 8])[i],
          source: `https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/${family === 'D' ? 'general-purpose' : 'memory-optimized'}/${series}`,
        });
      });
    }
  }
}

const common = {
  cloud: 'Commercial', os: 'Linux', currency: 'USD', costBasis: 'Amortized',
  hoursPerVM: 720, usageUnit: '1 Hour', periodStart: '2026-09-01', periodEnd: '2026-10-01',
  observationDays: 30, peakCovered: true, workload: 'user-facing', architecture: 'x64',
  tempGiB: 0, dataDisks: 2, nics: 1, diskIOPS: 1200, diskMBps: 40,
  bootGeneration: 2, accelNetworking: true, nvmeReady: true, manaReady: true,
  specialRequirements: 'none', licenseReady: true, agreement: 'MCA', purchase: 'PAYG',
  rateBasis: 'baseline', rateFrom: '2026-01-01', priceIncludesUpdate: false,
  priceSource: '教学模拟价格，非 Azure 报价', priceKind: 'demo',
} satisfies Partial<Vm>;
export const DEMO_VMS: Vm[] = [
  { ...common, id: 'demo-web', name: '案例 A · 电商前端', sku: 'Standard_D8s_v3', region: 'southeastasia', count: 4, vcpus: 8, memoryGiB: 32, cpuP95: 18, memoryP99: 24, networkP95Mbps: 160, currentRate: 0.42, storageProduct: 'Premium SSD Managed Disks (v1)', storageCost: 240 },
  { ...common, id: 'demo-db', name: '案例 B · 状态型数据库', sku: 'Standard_E8s_v3', region: 'westeurope', count: 2, vcpus: 8, memoryGiB: 64, cpuP95: 42, memoryP99: 73, networkP95Mbps: 400, tempGiB: 120, currentRate: 0.55, purchase: 'RI', riCoverage: 70, riEnd: '2027-09-01', riRate: 0.31, residualCommitmentCost: undefined },
  { ...common, id: 'demo-legacy', name: '案例 C · 旧代际应用', sku: 'Standard_DS3_v2', region: 'northeurope', count: 3, vcpus: 4, memoryGiB: 14, cpuP95: 35, memoryP99: 46, networkP95Mbps: 180, currentRate: 0.28, agreement: 'EA', eaRenewal: '2028-01-01', eaCapRate: 0.3 },
  { ...common, id: 'demo-china', name: '案例 D · 中国区隔离', sku: 'Standard_D4s_v3', region: 'chinaeast2', cloud: 'China', count: 1, vcpus: 4, memoryGiB: 16, cpuP95: 25, memoryP99: 40, networkP95Mbps: 120, currentRate: undefined, priceKind: undefined, priceSource: undefined },
  { ...common, id: 'demo-hpc', name: '案例 E · HPC 专项', sku: 'Standard_HC44rs', region: 'eastus', count: 1, vcpus: 44, memoryGiB: 352, cpuP95: 80, memoryP99: 70, networkP95Mbps: 6000, currentRate: 1.8, specialRequirements: 'manual', workload: 'batch' },
  { ...common, id: 'demo-missing', name: '案例 F · 仅清单/缺少指标', sku: 'Standard_D8s_v3', region: 'southeastasia', count: 1, vcpus: 8, memoryGiB: 32, cpuP95: 8, memoryP99: undefined, networkP95Mbps: undefined, peakCovered: undefined, currentRate: undefined, priceSource: undefined, priceKind: undefined },
];
export const DEMO_PRICES: Price[] = CATALOG.flatMap(sku =>
  ['southeastasia', 'westeurope', 'northeurope'].map(region => ({
    sku: sku.name, region, cloud: 'Commercial' as const, os: 'Linux', currency: 'USD',
    purchase: 'PAYG' as const, unit: '1 Hour' as const,
    rate: Number((sku.cores * (sku.family === 'D' ? 0.035 : 0.05) + (sku.temp ? 0.015 * sku.cores : 0) + (sku.generation - 5) * 0.005 * sku.cores).toFixed(4)),
    from: '2026-01-01', basis: 'baseline' as const, includesUpdate: false,
    source: '教学模拟价格，非 Azure 报价', kind: 'demo' as const,
  })),
);
