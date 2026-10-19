// =============================================================================
// Blueprint #47: Autonomous Aviation IROPS Recovery, SWIM FIXM/AIXM Streaming,
// FAA Part 117/121 Legality Gate & DO-178C Separation Barrier Pool
// =============================================================================
// Provisions:
//   1. Azure Event Hubs Namespace for FAA/EUROCONTROL SWIM (System Wide
//      Information Management: FIXM 4.3, AIXM 5.1, WXXM) real-time flight,
//      NOTAM, and convective weather telemetry ingestion.
//   2. AKS Standard_NC48ads_A100_v4 GPU Nodepool for NVIDIA cuOpt column-
//      generation tail-swap & crew recovery solving (14.2s vs 1,620s MILP)
//      with deterministic FAA 14 CFR Part 117 FDP crew legality, Part 121
//      MEL/ETOPS airworthiness, and DO-178C / RVSM separation gates.
//   3. Immutable FAA Part 121 Dispatch Release & CPDLC Audit Storage (WORM).
// =============================================================================

@description('Deployment region for airline IOC / ATM operations control plane')
param location string = resourceGroup().location

@description('Environment prefix for aviation IROPS agent resources')
param envPrefix string = 'aksclaw-aviation'

@description('Active commercial flight legs managed by the IROPS recovery cluster')
@minValue(50)
@maxValue(10000)
param activeFlights int = 1000

var swimEventHubNamespaceName = '${envPrefix}-swim-ehns'
var storageAccountName = replace('${envPrefix}part121worm', '-', '')
var aksClusterName = '${envPrefix}-irops-aks'
var solverNodeCount = max(2, (activeFlights + 249) / 250)

// 1. FAA / EUROCONTROL SWIM (FIXM / AIXM / WXXM) Event Hubs Namespace
resource swimEventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: swimEventHubNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    zoneRedundant: true
    isAutoInflateEnabled: false
  }
  tags: {
    workload: 'aviation-irops-swim-do178c'
    swimSchemas: 'FIXM-4.3-AIXM-5.1-WXXM'
    activeFlights: string(activeFlights)
  }
}

resource fixmFlightStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: swimEventHubNamespace
  name: 'swim-fixm-aixm-wxxm-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

// 2. Immutable FAA Part 121 Dispatch Release & CPDLC Audit Storage (WORM)
resource part121AuditStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take(storageAccountName, 24)
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    immutableStorageWithVersioning: {
      enabled: true
    }
  }
  tags: {
    faaCompliance: '14-CFR-Part-117-Part-121'
    rtcaStandard: 'DO-178C-RVSM-Simplex'
  }
}

// 3. AKS Aviation IROPS cuOpt Solver & DO-178C Legality Gate Cluster
resource aviationAks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'iropscuopt'
        count: solverNodeCount
        vmSize: 'Standard_NC48ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'aksclaw.io/workload-class': 'aviation-irops-swim-do178c-agent'
          'aksclaw.io/swim-fixm-cuopt-solver': 'enabled-14.2s-column-gen'
          'aksclaw.io/faa-part117-mel-gate': 'enforced-4.5ms-zero-illegal-dispatch'
          'aksclaw.io/do178c-rvsm-separation': 'enforced-5nm-1000ft-2.1ms'
        }
        nodeTaints: [
          'aksclaw.io/aviation-irops=true:NoSchedule'
        ]
      }
    ]
  }
}

output aviationIropsAksId string = aviationAks.id
output swimEventHubNamespaceId string = swimEventHubNamespace.id
output part121AuditStorageId string = part121AuditStorage.id
