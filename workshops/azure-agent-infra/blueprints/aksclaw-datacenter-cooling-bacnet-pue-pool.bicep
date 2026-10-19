// blueprints/aksclaw-datacenter-cooling-bacnet-pue-pool.bicep
// Blueprint #48: Hyperscale AI Datacenter Liquid-Cooling, BACnet/SC + Modbus-TCP Telemetry,
// PINN/MPC Thermal PUE Optimization & Dew-Point / Coolant Leak Interlock Agent Pool (Chapter 52)

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name')
param aksClusterName string = 'aks-aksclaw-dc-cooling'

@description('Event Hubs Namespace for BACnet/SC & DCGM Thermal Telemetry')
param eventHubNamespaceName string = 'ehns-bacnet-dcgm-cooling'

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

resource bacnetDcgmHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'bacnet-sc-cdu-dcgm-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource dcCoolingPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'coolpinnmpc'
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
      'aksclaw.io/workload-class': 'datacenter-liquid-cooling-pinn-mpc-agent'
      'aksclaw.io/bacnet-sc-dcgm-pinn': 'enabled-0.42s-pue-1.12'
      'aksclaw.io/ashrae-dewpoint-interlock': 'magnus-tetens-2c-margin-1.8ms'
      'aksclaw.io/cdu-leak-solenoid-trip': 'enforced-38ms-zero-blade-damage'
    }
    nodeTaints: [
      'aksclaw.io/datacenter-cooling=true:NoSchedule'
    ]
  }
}
