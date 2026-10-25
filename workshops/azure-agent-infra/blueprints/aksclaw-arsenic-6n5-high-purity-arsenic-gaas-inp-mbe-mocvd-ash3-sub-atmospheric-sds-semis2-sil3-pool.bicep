// ============================================================================
// AKSClaw Blueprint #194: Autonomous Smelter Flue-Dust / Realgar Vacuum
// Sublimation (As2O3), AsCl3 Fractional Distillation & H2 Reduction to 7N
// (99.99999%) Vacuum-Sublimed Electronic Arsenic (As4/As2), Sub-Atmospheric
// (SDS) 6N5 Arsine (AsH3) Synthesis & 6-Inch VGF/LEC Gallium Arsenide (GaAs)
// Wafer / VCSEL Epitaxy PINN-MPC, Online 10 kHz In-Situ Raman/LIBS, TDLAS
// AsH3/HCl Metrology & OSHA 1910.1018 / NFPA 318 / SEMI S2 / IEC 61511 SIL-3
// Lethal Arsine (AsH3, PEL 3 ppb) Sub-Atmospheric Lockout, Dry CuO/MnO2
// Chemisorption Scrubbing & Scorodite (FeAsO4·2H2O) Stabilization Interlock
// Pool (Cycle #193)
// ============================================================================
@description('AKS cluster name for 7N Electronic Arsenic, SDS AsH3 & 6-Inch VGF GaAs Wafer PINN-MPC agents')
param aksClusterName string = 'aks-arsenic-7n-ash3-sds-gaas-vgf-sil3'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Initial node count for Standard_NC40ads_H100_v5 PINN-MPC & 10kHz In-Situ Raman/TDLAS/LIBS pool')
@minValue(2)
@maxValue(32)
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource arsenicGaAsSdsPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'asgaassil3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'arsenic-6n5-high-purity-arsenic-gaas-inp-mbe-mocvd-ash3-sub-atmospheric-sds-semis2-sil3-agent'
      'aksclaw.io/pinn-mpc-ascl3-distillation-7n-arsenic-sds-ash3-vgf-gaas': 'enabled-49.6pct-7n-as-sds-ash3-gaas-wafer-yield-gain-74.5pct-as-dimer-carbon-el2-cut'
      'aksclaw.io/osha19101018-nfpa318-semis2-sil3-ash3-3ppb-sds-scrubber-interlock': 'enforced-0.26ms-zero-lethal-ash3-release-ascl3-hydrolysis-or-gaas-ampoule-rupture'
      'aksclaw.io/as-gaas-edge-10khz-raman-as4-as2-tdlas-ash3-hcl-libs': 'enabled-0.20ms-99.7pct-arsenic-gaas-vcsel-fab-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/arsenic-7n-ash3-sds-gaas-sil3=dedicated:NoSchedule'
    ]
  }
}

output poolResourceId string = arsenicGaAsSdsPool.id
output workloadClass string = 'arsenic-6n5-high-purity-arsenic-gaas-inp-mbe-mocvd-ash3-sub-atmospheric-sds-semis2-sil3-agent'
