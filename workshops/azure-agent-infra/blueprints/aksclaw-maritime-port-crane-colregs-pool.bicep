// blueprints/aksclaw-maritime-port-crane-colregs-pool.bicep
// Blueprint #49: Autonomous Maritime Port, STS/ARMG Container Terminal Stowage cuOpt Solver,
// IMO Hydrostatic Stability Gate & COLREGs Vessel Traffic Safety Pool (Chapter 53)

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name')
param aksClusterName string = 'aks-aksclaw-maritime-port'

@description('Event Hubs Namespace for AIS / VTS NMEA-2000 & Quay Crane Telemetry')
param eventHubNamespaceName string = 'ehns-ais-vts-nmea2000'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource aisVtsHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'ais-vts-sts-crane-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource maritimePortPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'portcuopt'
  properties: {
    count: 4
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
      'aksclaw.io/workload-class': 'maritime-port-stowage-colregs-agent'
      'aksclaw.io/sts-armg-cuopt-stowage': 'enabled-8.6s-24kteu'
      'aksclaw.io/imo-iscode-gm-stability': 'enforced-gm-0.8m-3.2ms'
      'aksclaw.io/imo-colregs-cpa-tcpa': 'enforced-velocity-obstacle-1.9ms'
    }
    nodeTaints: [
      'aksclaw.io/maritime-port=true:NoSchedule'
    ]
  }
}
