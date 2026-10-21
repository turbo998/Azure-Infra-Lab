// 114. Azure Bicep: Autonomous Ultra-Pure Electronic-Grade Polysilicon (11N–12N) Modified Siemens CVD Bell-Jar Reactor (1,050–1,150°C) & Fluidized-Bed Reactor (FBR), Trichlorosilane (SiHCl3/H2) Radiative-Convective Boundary-Layer & Popcorn-Dust Nucleation PINN-MPC, In-Line CRDS/ICP-MS Sub-ppt Dopant Metrology & NFPA 69 / SEMI S2 / API RP 521 / IEC 61508 SIL-3 Chlorosilane Auto-Ignition & Water-Jacket Rupture Interlock Pool
@description('Name of the existing AKS cluster hosting the AKSClaw Control Plane')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Location for the AKS agent pool')
param location string = resourceGroup().location

@description('Number of GPU nodes for Trichlorosilane/Silane CVD & FBR Boundary-Layer PINN-MPC')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 2

@description('Number of CPU nodes for Reactor-Bay CRDS/ICP-MS & NFPA 69 / SEMI S2 SIL-3 Interlock Edge')
@minValue(2)
@maxValue(64)
param edgeNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource polysiliconSiemensCvdFbrGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'psipinnsil3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'polysilicon-siemens-cvd-fbr-trichlorosilane-semis2-sil3-agent'
      'aksclaw.io/pinn-mpc-tcs-cvd-fbr-boundary-layer-popcorn': 'enabled-36.3pct-11n12n-energy-cut-49.0pct-popcorn-rod-collapse-cut'
      'aksclaw.io/nfpa69-semis2-sil3-chlorosilane-water-jacket-quench': 'enforced-0.4ms-zero-sihcl3-h2-explosion-or-water-jacket-steam-blast'
    }
    nodeTaints: [
      'aksclaw.io/polysilicon-siemens-cvd-fbr-sil3=true:NoSchedule'
    ]
  }
}

resource polysiliconReactorBayCrdsEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'psicrdsedge'
  properties: {
    count: edgeNodeCount
    vmSize: 'Standard_D32as_v7'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    proximityPlacementGroup: {
      id: resourceId('Microsoft.Compute/proximityPlacementGroups', '${aksClusterName}-ppg')
    }
    nodeLabels: {
      'aksclaw.io/workload-class': 'polysilicon-reactor-bay-crds-icpms-pyrometer-edge-sandbox'
      'aksclaw.io/isolation': 'kata-containers-isenabled'
      'aksclaw.io/reactor-bay-edge-crds-subppt-dopant-two-color-pyrometer': 'enabled-0.3ms-99.4pct-fab-wan-cut'
    }
  }
}

output gpuPoolId string = polysiliconSiemensCvdFbrGpuPool.id
output edgePoolId string = polysiliconReactorBayCrdsEdgePool.id
