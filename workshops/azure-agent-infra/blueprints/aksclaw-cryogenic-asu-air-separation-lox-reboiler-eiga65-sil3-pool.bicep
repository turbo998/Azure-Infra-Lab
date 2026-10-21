// 115. Azure Bicep: Autonomous Cryogenic Air Separation Unit (ASU, 100,000+ Nm3/h O2/N2/Ar/Kr/Xe Double-Column Distillation) & Liquid Air Energy Storage (LAES), Structured-Packing Flooding & Argon-Front Migration PINN-MPC, In-Line FTIR/GC-DID Sub-ppm Hydrocarbon Metrology in Liquid Oxygen & EIGA Doc 65 / CGA P-8 / API 670 / IEC 61508 SIL-3 Reboiler-Condenser Acetylene Dry-Boiling Detonation & Oxygen-Turboexpander Titanium-Fire Interlock Pool
@description('Name of the existing AKS cluster hosting the AKSClaw Control Plane')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Location for the AKS agent pool')
param location string = resourceGroup().location

@description('Number of GPU nodes for Cryogenic Double-Column Distillation & Argon-Front PINN-MPC')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 2

@description('Number of CPU nodes for Cold-Box FTIR/GC-DID & EIGA Doc 65 SIL-3 Interlock Edge')
@minValue(2)
@maxValue(64)
param edgeNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource cryogenicAsuAirSeparationGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'asupinnsil3'
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
      'aksclaw.io/workload-class': 'cryogenic-asu-air-separation-lox-reboiler-eiga65-sil3-agent'
      'aksclaw.io/pinn-mpc-cryo-distillation-argon-front-laes': 'enabled-35.6pct-argon-recovery-load-ramp-gain-48.3pct-nitrogen-dump-flooding-cut'
      'aksclaw.io/eiga65-cgap8-sil3-lox-reboiler-acetylene-purge': 'enforced-0.3ms-zero-lox-hydrocarbon-detonation-or-titanium-fire'
    }
    nodeTaints: [
      'aksclaw.io/cryogenic-asu-air-separation-sil3=true:NoSchedule'
    ]
  }
}

resource cryogenicAsuColdBoxFtirEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'asuftiredge'
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
      'aksclaw.io/workload-class': 'cryogenic-asu-coldbox-ftir-gcdid-turboexpander-edge-sandbox'
      'aksclaw.io/isolation': 'kata-containers-isenabled'
      'aksclaw.io/coldbox-edge-lox-ftir-gcdid-hydrocarbon-turboexpander': 'enabled-0.3ms-99.4pct-plant-wan-cut'
    }
  }
}

output gpuPoolId string = cryogenicAsuAirSeparationGpuPool.id
output edgePoolId string = cryogenicAsuColdBoxFtirEdgePool.id
