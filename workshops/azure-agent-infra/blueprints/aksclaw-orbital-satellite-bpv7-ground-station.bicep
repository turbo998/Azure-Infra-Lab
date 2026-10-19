// ============================================================================
// Blueprint #38: Sovereign Space & LEO Satellite Edge Agent Infrastructure
// Azure Orbital Ground Station Contact Profile + Event Hubs Ka/X-Band Telemetry
// + Storage ZRS RFC 9171 BPv7 Custody Store + AKS Ground-Segment Mission Control Pool
// ============================================================================

@description('Deployment region for Azure Orbital Ground Station and Mission Control AKS')
param location string = resourceGroup().location

@description('Existing AKS cluster name for Ground-Segment Mission Control')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Storage account name for RFC 9171 BPv7 DTN Custody Bundles & GeoJSON Chips')
param dtnStorageAccountName string = 'staksclaworbitalbpv7zrs'

@description('Event Hubs namespace for Ka/X-Band Downlink Telemetry & ISL Alert Stream')
param eventHubNamespaceName string = 'eh-aksclaw-orbital-downlink'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. Azure Storage ZRS for RFC 9171 Bundle Protocol v7 (BPv7) Custody Transfer Store
resource dtnBundleStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: dtnStorageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    isHnsEnabled: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource bpv7CustodyContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${dtnBundleStorage.name}/default/bpv7-custody-bundles'
  properties: {
    publicAccess: 'None'
    metadata: {
      protocol: 'rfc9171-bpv7-ltp-custody-transfer'
      onOrbitTriageFilterRatioPct: '94.2'
      seuProtection: 'tmr-edac-crc32c-attitude-interlock'
    }
  }
}

// 2. Azure Event Hubs Namespace for Ka/X-Band Ground Station Downlink & ISL Relay
resource orbitalEventHubNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
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

resource orbitalTelemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: orbitalEventHubNs
  name: 'leo-isl-bpv7-mission-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

// 3. AKS Ground-Segment Mission Control & Digital-Twin Orbit Propagator Pool
resource orbitalMissionPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'orbitalctrl'
  properties: {
    count: 6
    vmSize: 'Standard_D32s_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 4
    maxCount: 24
    nodeLabels: {
      'aksclaw.io/workload-class': 'space-orbital-satellite-edge'
      'aksclaw.io/dtn-bundle-protocol': 'rfc9171-bpv7-ltp-custody'
      'aksclaw.io/on-orbit-triage': 'rad-tolerant-int4-vlm-chip-filter'
      'aksclaw.io/seu-interlock': 'tmr-edac-crc32c-thruster-guard'
    }
    nodeTaints: [
      'aksclaw.io/orbital-mission=true:NoSchedule'
    ]
  }
}

output orbitalMissionPoolId string = orbitalMissionPool.id
output bpv7CustodyContainerId string = bpv7CustodyContainer.id
output orbitalTelemetryHubId string = orbitalTelemetryHub.id
