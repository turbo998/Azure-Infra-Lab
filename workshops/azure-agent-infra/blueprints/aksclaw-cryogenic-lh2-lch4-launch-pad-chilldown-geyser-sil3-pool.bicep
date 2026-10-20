// Blueprint #92: AKSClaw Cryogenic Liquid-Hydrogen (LH2 20 K) & Subcooled Liquid-Methane/LOX Orbital Launch Pad Propellant Densification, Chilldown Geysering & Range Safety SIL-3 Agent Pool
// Chapter 96 — Leidenfrost Film-Boiling Chilldown & Taylor-Bubble Geysering PINN-MPC, Ortho-to-Para H2 Brayton Zero-Boil-Off (ZBO) Densification & NASA-STD-5005 / NFPA 2 / AFSPCMAN 91-710 SIL-3 Quick-Disconnect (QD), Water-Deluge & Flare-Stack Interlock

@description('AKS cluster name for Cryogenic LH2/LCH4 Launch Pad Propellant & Range Safety SIL-3 Agent Pool')
param clusterName string = 'aksclaw-cryo-launch-pad-sil3'

@description('Azure region for sovereign spaceport ground support equipment (GSE) control plane')
param location string = resourceGroup().location

@description('VM SKU for two-phase cryogenic Leidenfrost/geysering PINN-MPC & ZBO densification control')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for HA spaceport launch complex propellant loading loops')
@minValue(2)
@maxValue(32)
param minCount int = 2

@description('Maximum node count for multi-pad heavy-lift orbital launch complexes')
@minValue(2)
@maxValue(64)
param maxCount int = 12

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource cryoLaunchPadSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lh2padsil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableUltraSSD: true
    maxPods: 32
    nodeLabels: {
      'aksclaw.io/workload-tier': 'cryogenic-lh2-lch4-launch-pad-chilldown-geyser-sil3'
      'aksclaw.io/cryo-telemetry': 'raman-h2-plume-lidar-cernox-rtd-coriolis-two-phase'
      'aksclaw.io/chilldown-solver': 'pinn-mpc-leidenfrost-geyser-ortho-para-zbo-densifier'
      'aksclaw.io/safety-interlock': 'nasa-std-5005-nfpa2-afspcman-91-710-sil3-qd-deluge'
      'aksclaw.io/edge-fabric': 'ccsds-igse-time-triggered-ethernet-azure-local-bunker'
    }
    nodeTaints: [
      'aksclaw.io/cryo-launch-pad-sil3=true:NoSchedule'
    ]
    tags: {
      chapter: '96'
      blueprint: '92'
      domain: 'cryogenic-lh2-lch4-launch-pad-chilldown-geyser-sil3'
      safetyStandard: 'NASA-STD-5005-NFPA-2-AFSPCMAN-91-710-SIL-3'
    }
  }
}

output agentPoolId string = cryoLaunchPadSil3Pool.id
output agentPoolName string = cryoLaunchPadSil3Pool.name
output isolationRuntime string = cryoLaunchPadSil3Pool.properties.workloadRuntime
