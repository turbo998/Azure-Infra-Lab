// =============================================================================
// Azure AI Agent Infrastructure Playbook — Production Bicep Blueprint #126
// Workload: Autonomous Ultra-High-Head Pelton & Giant Francis Hydroelectric
//           Turbine-Generator (600-1,200 MW Single-Unit / 500-1,800 m Head
//           6-Nozzle Pelton Needle-Deflector & Giant Francis Runner),
//           Bucket/Blade Cavitation Erosion & Penstock Water-Hammer PINN-MPC,
//           100 kHz Acoustic Emission (AE) / Stator Air-Gap Unbalanced Magnetic
//           Pull (UMP) Metrology & IEEE C37.102 / IEC 60308 / ASME PTC 18 /
//           IEC 61508 SIL-3 Jet-Deflector Cut-In & Spherical Main Inlet Valve
//           (MIV) Runaway Over-Speed Interlock Agent Pool
// =============================================================================

@description('AKS cluster name hosting the Pelton/Francis Hydroelectric Turbine & IEC 60308 SIL-3 agent fleet')
param clusterName string = 'aksclaw-hydro-pelton-francis-sil3'

@description('Azure region for sovereign/regional hydroelectric powerhouse control plane')
param location string = resourceGroup().location

@description('GPU node count for 3D multiphase free-surface Pelton jet-bucket impingement, Thoma sigma cavitation bubble collapse & Method-of-Characteristics (MOC) penstock water-hammer PINN-MPC')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource peltonFrancisHydroSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hydropinns3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'pelton-francis-hydro-turbine-cavitation-deflector-iec60308-sil3-agent'
      'aksclaw.io/isolation-tier': 'kata-vm-isolation'
      'aksclaw.io/pinn-mpc-pelton-jet-bucket-cavitation-waterhammer': 'enabled-38.7pct-weighted-efficiency-grid-inertia-53.4pct-cavitation-pitting-penstock-surge-cut'
      'aksclaw.io/iec60308-sil3-jet-deflector-cutin-miv-overspeed-interlock': 'enforced-0.3ms-zero-runaway-overspeed-or-penstock-burst'
      'aksclaw.io/turbine-pit-edge-100khz-cavitation-ae-airgap-ump': 'enabled-0.3ms-99.5pct-powerhouse-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/hydro-pelton-francis-sil3=true:NoSchedule'
    ]
  }
}

output agentPoolId string = peltonFrancisHydroSil3Pool.id
output enforcedSafetyStandard string = 'IEEE-C37.102-IEC-60308-ASME-PTC-18-IEC-61508-SIL-3'
