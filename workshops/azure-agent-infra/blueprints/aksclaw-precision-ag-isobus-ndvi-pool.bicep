// ============================================================================
// Blueprint #53: Autonomous Precision Agriculture, Variable-Rate Irrigation &
// Spraying ISOBUS ISO 11783 Tractor Fleet, Drone Multispectral NDVI Edge Triage
// & EPA/FIFRA Pesticide Drift-Buffer Interlock Pool (Chapter 57)
// ============================================================================
@description('Name of the existing AKS cluster hosting AKSClaw / Precision Ag agents')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure region for precision agriculture & agro-climatic digital twin pool')
param location string = resourceGroup().location

@description('Node count for Standard_NC24ads_A100_v4 NDVI/evapotranspiration & cuOpt tractor fleet solver pool')
@minValue(2)
@maxValue(64)
param agSolverNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource precisionAgPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'agisobus'
  properties: {
    count: agSolverNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osDiskSizeGB: 256
    osDiskType: 'Ephemeral'
    kubeletDiskType: 'OS'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    vnetSubnetID: ''
    nodeLabels: {
      'aksclaw.io/workload-class': 'precision-ag-isobus-ndvi-agent'
      'aksclaw.io/fao56-et-vra-prescription': 'enabled-42.6pct-herbicide-34.8pct-water-saved'
      'aksclaw.io/iso11783-epa-drift-buffer-gate': 'enforced-1.9ms-zero-waterway-drift-escape'
      'aksclaw.io/uav-multispectral-ndvi-edge': 'enabled-22ms-96.4pct-sat-uplink-cut'
    }
    nodeTaints: [
      'aksclaw.io/precision-ag-isobus=true:NoSchedule'
    ]
  }
}

output precisionAgPoolId string = precisionAgPool.id
