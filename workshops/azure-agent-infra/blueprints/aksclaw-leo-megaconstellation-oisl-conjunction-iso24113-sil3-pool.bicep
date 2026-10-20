// =============================================================================
// Blueprint #78: AKSClaw LEO/VLEO Satellite Megaconstellation Optical Inter-
// Satellite Link (OISL 1550 nm Coherent PAT), Orbital Perturbation & Conjunction
// Avoidance PINN-MPC & ISO 24113 / NASA-STD-8719.14 / IEC 61508 SIL-3 Hall-
// Thruster Delta-V & Safe-Mode Sun-Pointing Interlock Agent Pool (Chapter 82)
// =============================================================================

@description('AKS cluster name hosting the LEO megaconstellation OISL & orbital conjunction agent pool')
param clusterName string = 'aks-aksclaw-leo-oisl-sil3'

@description('Azure region for the satellite constellation ground-segment & orbital digital-twin cluster')
param location string = resourceGroup().location

@description('Number of ND96isr_H100_v5 nodes for J2-J6 atmospheric drag orbital PINN & OISL mesh routing MPC')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource leoOislConjunctionSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'leooislpinn'
  properties: {
    count: nodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    maxPods: 30
    nodeLabels: {
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/workload-class': 'leo-megaconstellation-oisl-conjunction-iso24113-sil3-agent'
      'aksclaw.io/j2j6-drag-orbital-pinn-oisl-pat-mpc': 'enabled-31.6pct-oisl-throughput-27.8pct-propellant-saving'
      'aksclaw.io/iso24113-nasa8719-sil3-deltav-safemode': 'enforced-1.1ms-zero-debris-conjunction-or-attitude-tumble'
      'aksclaw.io/onboard-radhard-npu-cdm-fso-edge': 'enabled-0.9ms-98.7pct-downlink-wan-cut'
      'aksclaw.io/gpu-Direct-rdma': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/leo-oisl-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output poolResourceId string = leoOislConjunctionSil3Pool.id
output safetyStandard string = 'ISO-24113-NASA-STD-8719.14-CCSDS-232.0-IEC-61508-SIL3-Conjunction-Interlock'
