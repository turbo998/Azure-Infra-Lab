// ============================================================================
// Blueprint #186: Bertrandite & Beryl Acid Leaching, D2EHPA Solvent Extraction,
// (NH4)2BeF4 Thermal Decomposition to BeF2, Magnesiothermic Beryllium Pebble
// Reduction & Vacuum Hot-Pressed Optical/Fusion Beryllium (S-200F / O-30-H)
// PINN-MPC & OSHA 1910.1024 / 10 CFR 850 / NFPA 484 / IEC 61511 SIL-3 Pool
// ============================================================================
// Target: Azure Kubernetes Service (AKS) + AKSClaw / Kata + GPU PINN NodePool
// Node SKU: Standard_NC40ads_H100_v5
// Safety: OSHA 1910.1024 (PEL 0.2 ug/m3, Action Level 0.1 ug/m3) / 10 CFR 850
//         / NFPA 484 / IEC 61511 SIL-3 (0.29 ms hardware interlock)
// ============================================================================

@description('Azure region for the Beryllium Hydrometallurgy, BeF2 Magnesiothermic Reduction & VHP Optical/Fusion Beryllium AKS cluster')
param location string = resourceGroup().location

@description('AKS cluster resource name')
param clusterName string = 'aks-beryllium-bef2-vhp-s200f-sil3'

@description('Kubernetes version for the control plane and GPU node pool')
param kubernetesVersion string = '1.30.6'

@description('GPU VM size for coupled BeF2-Mg reduction, (NH4)2BeF4 decomposition & VHP S-200F PINN-MPC')
param gpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Number of dedicated H100 nodes for multi-line beryllium extraction & vacuum hot pressing lines')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource berylliumBef2VhpSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'bebef2sil3'
  properties: {
    count: gpuNodeCount
    vmSize: gpuVmSize
    orchestratorVersion: kubernetesVersion
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'beryllium-beryl-bef2-mg-reduction-vhp-s200f-pinn-mpc'
      'agent.infra/safety-standard': 'osha-1910-1024-10cfr850-nfpa-484-iec-61511-sil3'
      'agent.infra/metrology-loop': '10khz-aerosol-libs-tdlas-hf-nh3-ultrasonic-vhp-density'
      'agent.infra/interlock-budget-ms': '0.29'
      'agent.infra/isolation': 'kata-containers-gpu-passthrough'
    }
    nodeTaints: [
      'beryllium.sil3/dedicated=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolName string = berylliumBef2VhpSil3Pool.name
output poolNodeSku string = berylliumBef2VhpSil3Pool.properties.vmSize
output safetyInterlockStandard string = 'OSHA 1910.1024 / 10 CFR 850 / NFPA 484 / IEC 61511 SIL-3 (0.29 ms)'
