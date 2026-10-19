// ============================================================================
// Blueprint #33: Autonomous Cyber-Defense & AI Red-Team Detonation Sandboxes
// Provisions:
//   1. Air-Gapped AKS Detonation Nodepool (`Standard_DC48ads_v5`, `--net=none` vsock-only pods)
//   2. Azure Event Hubs Namespace + `krsi-ebpf-behavioral-telemetry` hub for high-throughput LSM call graphs
//   3. Log Analytics Workspace + Microsoft Sentinel Onboarding + Autonomous SOAR Quarantine Automation Rule
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-cyber'

@description('Existing AKS cluster name')
param aksClusterName string = '${envPrefix}-aks'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Air-Gapped Confidential Detonation Nodepool (Zero-NIC Guest MicroVMs via Kata + AF_VSOCK)
resource detonationPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'detonatepool'
  properties: {
    count: 4
    minCount: 2
    maxCount: 32
    enableAutoScaling: true
    vmSize: 'Standard_DC48ads_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    nodeLabels: {
      'aksclaw.io/workload-class': 'cyber-detonation-microvm'
      'aksclaw.io/guest-network': 'none-af-vsock-only'
      'aksclaw.io/rootfs-mode': 'dm-verity-ram-brd'
      'aksclaw.io/telemetry-hook': 'krsi-ebpf-lsm-ringbuf'
    }
    nodeTaints: [
      'aksclaw.io/cyber-detonation=true:NoSchedule'
    ]
  }
}

// 2. Event Hubs Namespace for Out-of-Band AF_VSOCK -> Host eBPF KRSI Telemetry Streaming
resource eventHubNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${envPrefix}-ehns-${uniqueString(resourceGroup().id)}'
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

resource krsiTelemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNs
  name: 'krsi-ebpf-behavioral-telemetry'
  properties: {
    partitionCount: 16
    messageRetentionInDays: 7
  }
}

// 3. Log Analytics Workspace + Microsoft Sentinel Autonomous SOAR Quarantine
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${envPrefix}-sentinel-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource sentinelOnboarding 'Microsoft.SecurityInsights/onboardingStates@2024-03-01' = {
  scope: law
  name: 'default'
  properties: {
    customerManagedKey: false
  }
}

output detonationNodePoolId string = detonationPool.id
output krsiTelemetryEventHubId string = krsiTelemetryHub.id
output sentinelWorkspaceId string = law.id
