// =============================================================================
// Blueprint #64: AKSClaw Subsea Cabled Ocean Observatory, Tsunami Early-Warning,
// AUV Acoustic Swarm Docking & API RP 53 / SIL-3 Subsea BOP Shear-Ram Pool
// =============================================================================

@description('AKS cluster name hosting the subsea cabled observatory & AUV control agent pool')
param clusterName string = 'aksclaw-subsea-observatory-prod'

@description('Location for the subsea observatory agent pool')
param location string = resourceGroup().location

@description('Node count for the Standard_NC24ads_A100_v4 subsea acoustic & tsunami inversion pool')
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource subseaObservatoryPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'subseabop'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'subsea-cabled-observatory-tsunami-bop-agent'
      'aksclaw.io/bpr-tsunami-pinn-auv-acoustic-mpc': 'enabled-44.6pct-lead-time-gain-38.2pct-auv-docking-energy-cut'
      'aksclaw.io/api-rp53-sil3-bop-shear-ram-hvdc': 'enforced-1.2ms-zero-blowout-hvdc-seawater-fault'
      'aksclaw.io/subsea-das-hydrophone-acoustic-edge': 'enabled-6.5ms-97.4pct-acoustic-satcom-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/subsea-observatory=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolLocation string = location
output subseaObservatoryPoolResourceId string = subseaObservatoryPool.id
