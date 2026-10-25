// ============================================================================
// Blueprint #187: AKSClaw Autonomous Bismuthinite & Lead-Anode Slime Oxidative
// Converting, Betterton-Kroll Calcium-Magnesium Debismuthizing (CaMg2Bi2),
// 6N Zone-Refined High-Purity Bismuth, Gen-IV Lead-Bismuth Eutectic (LBE,
// 44.5% Pb-55.5% Bi) Coolant Oxygen Control & Bi2Te3 Thermoelectric Crystal
// Growth PINN-MPC & NFPA 86 / OSHA 1910.1025 / IAEA SSG-2 / IEC 61511 SIL-3
// Pool (Chapter 191 · Cycle #186 · 195-Test Milestone!)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the Bismuth Betterton-Kroll, 6N Zone Refining & LBE Coolant AKSClaw cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Bismuth Betterton-Kroll, 6N Zone Refining & LBE Coolant PINN-MPC workloads')
param clusterName string = 'aksclaw-bismuth-lbe-6n-iaea-sil3'

@description('GPU node count for Betterton-Kroll CaMg2Bi2 Drossing, 6N Pfann Zone Refining & LBE YSZ Oxygen-Activity PINN-MPC')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 4

@description('Target 6N zone-refining passes (Pfann segregation k_eff < 0.08)')
param targetZoneRefiningPasses int = 18

@description('Target LBE dissolved oxygen concentration (wt%) for protective Fe3O4/FeCr2O4 oxide film without PbO slagging')
param targetLbeDissolvedOxygenWtPct string = '1.0e-6'

resource aks BismuthCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource bismuthLbeGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'bilbepinn'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    nodeLabels: {
      'aksclaw.io/workload-tier': 'bismuth-betterton-kroll-6n-zone-refining-lbe-coolant-bi2te3-pinn-mpc'
      'aksclaw.io/safety-interlock': 'nfpa86-osha19101025-iaeassg2-iec61511-sil3-ash3-cl2-po210-lbe-dump'
      'aksclaw.io/edge-metrology': '10khz-molten-bath-libs-ysz-po2-emf-and-tdlas-ash3-cl2'
      'aksclaw.io/target-zone-passes': string(targetZoneRefiningPasses)
      'aksclaw.io/target-lbe-o2-wt-pct': targetLbeDissolvedOxygenWtPct
    }
    nodeTaints: [
      'aksclaw.io/bismuth-lbe-6n-sil3=true:NoSchedule'
    ]
  }
}

output poolId string = bismuthLbeGpuPool.id
output isolationRuntime string = bismuthLbeGpuPool.properties.workloadRuntime
output safetyStandard string = 'NFPA-86-OSHA-1910.1025-IAEA-SSG-2-IEC-61511-SIL-3'
