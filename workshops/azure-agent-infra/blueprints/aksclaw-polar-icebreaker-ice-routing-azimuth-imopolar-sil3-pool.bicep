@description('AKS Cluster Name for Polar Icebreaker Dynamic Ice-Routing, Hull FBG Strain & Azimuth Thruster IMO Polar Code / IACS URI / SIL-3 Agent Pool')
param clusterName string = 'aks-aksclaw-polar-icebreaker'

@description('Azure Region for parent cloud SAR ice-chart assimilation, 3D DEM ice-hull PINN training & Polar Class fleet orchestration')
param location string = resourceGroup().location

@description('VM Size for 3D DEM Ice-Hull Interaction, SAR Multi-Year Ridge Inversion & Azipod Ice-Milling MPC')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for Polar Icebreaker Corridor Simulation Pool')
param minCount int = 2

@description('Maximum node count for Polar Icebreaker Corridor Simulation Pool')
param maxCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource polarIcebreakerPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'polarice'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    nodeLabels: {
      'agent.infra/workload': 'polar-icebreaker-ice-routing-azimuth-imopolar-sil3'
      'agent.infra/isolation': 'kata-mshv-vm'
      'agent.infra/polar-safety': 'imo-polar-code-iacs-uri-pc1-iec61508-sil3'
      'agent.infra/edge-protocol': 'iec61162-450-xband-iceradar-fbg-optical'
    }
    nodeTaints: [
      'agent.infra/polar-icebreaker=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '25%'
    }
  }
}

output poolResourceId string = polarIcebreakerPool.id
output isolationRuntime string = polarIcebreakerPool.properties.workloadRuntime
