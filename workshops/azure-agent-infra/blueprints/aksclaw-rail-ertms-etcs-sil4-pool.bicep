// blueprints/aksclaw-rail-ertms-etcs-sil4-pool.bicep
// Blueprint #50: Autonomous High-Speed Rail, ERTMS/ETCS Level 3 Moving-Block cuOpt Rescheduler,
// CENELEC EN 50128/50129 SIL-4 Braking Curve Gate & Wayside TADS Edge Pool (Chapter 54)

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name')
param aksClusterName string = 'aks-aksclaw-rail-ertms'

@description('Event Hubs Namespace for FRMCS 5G / GSM-R & Wayside TADS Telemetry')
param eventHubNamespaceName string = 'ehns-frmcs-etcs-telemetry'

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

resource frmcsTelemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'frmcs-etcs-wayside-tads-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource railErtmsPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'railetcs'
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
      'aksclaw.io/workload-class': 'rail-ertms-etcs-sil4-agent'
      'aksclaw.io/frmcs-cuopt-traingraph': 'enabled-6.4s-moving-block'
      'aksclaw.io/en50129-sil4-braking-gate': 'enforced-evc-ixl-1.5ms-zero-spad'
      'aksclaw.io/wayside-tads-pantograph-edge': 'enabled-12ms-97.4pct-backhaul-cut'
    }
    nodeTaints: [
      'aksclaw.io/rail-ertms=true:NoSchedule'
    ]
  }
}
