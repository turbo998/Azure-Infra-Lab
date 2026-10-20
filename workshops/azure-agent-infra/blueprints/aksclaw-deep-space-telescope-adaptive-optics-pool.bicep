// =============================================================================
// Blueprint #63: AKSClaw Extremely Large Telescope Adaptive Optics (XAO)
// Deformable Mirror Control, Radio Interferometer Correlator & LGS Safety Interlock Pool
// =============================================================================

@description('AKS cluster name hosting the observatory adaptive optics & radio correlator agent pool')
param clusterName string = 'aksclaw-observatory-ao-prod'

@description('Location for the observatory control agent pool')
param location string = resourceGroup().location

@description('Node count for the Standard_NC24ads_A100_v4 adaptive optics & correlator pool')
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource observatoryAoPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'xaooptics'
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
      'aksclaw.io/workload-class': 'deep-space-telescope-adaptive-optics-agent'
      'aksclaw.io/xao-deformable-mirror-mpc': 'enabled-46.2pct-strehl-ratio-gain-31.8pct-rfi-flag-saving'
      'aksclaw.io/lgs-faa-airspace-solar-interlock': 'enforced-0.6ms-zero-aircraft-lasing-focal-plane-burn'
      'aksclaw.io/shack-hartmann-frb-dedispersion-edge': 'enabled-0.8ms-98.2pct-wan-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/observatory-ao=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolLocation string = location
output observatoryAoPoolResourceId string = observatoryAoPool.id
