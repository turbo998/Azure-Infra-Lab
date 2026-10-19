// ============================================================================
// Blueprint #25: Online RLHF/RFT GRPO Trajectory Rollout & Hermetic Verifier Pool
// Target: AKS Rollout Sandbox Pool (Standard_D96as_v7) + Immutable Verifier Fixture Store
// Purpose:
//   1. Provision Azure Blob Storage ZRS with WORM immutability for hidden verifier test
//      fixtures (anti-reward-hacking oracle store) and compressed Parquet replay buffers.
//   2. Provision high-density AKS rollout nodepool (Standard_D96as_v7) with 1-to-16
//      tree-structured uffd/CoW snapshot forking and split-namespace verifier isolation.
// ============================================================================

@description('Deployment region for Online RFT & Verifier Sandbox resources')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting RFT rollout sandboxes')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Storage account name for hermetic verifier fixtures and Parquet trajectory buffer')
param rftStorageAccountName string = 'staksclawrftverifier'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. ZRS Storage Account for Hermetic Verifier Oracles & Arrow/Parquet Trajectory Buffer
resource rftStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: rftStorageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: rftStorage
  name: 'default'
}

// Hidden verifier test suite container (strictly inaccessible to rollout agent UID)
resource verifierOracleContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'hermetic-verifier-oracles'
  properties: {
    publicAccess: 'None'
    immutableStorageWithVersioning: {
      enabled: true
    }
  }
}

// Prefix-compacted Parquet trajectory replay buffer container
resource trajectoryReplayContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'grpo-parquet-trajectories'
  properties: {
    publicAccess: 'None'
  }
}

// 2. AKS High-Density GRPO Rollout & Hermetic Verifier Pool (Standard_D96as_v7)
resource rftRolloutPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'rftrollout'
  properties: {
    count: 50
    minCount: 8
    maxCount: 250
    enableAutoScaling: true
    vmSize: 'Standard_D96as_v7'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    enableAcceleratedNetworking: true
    kubeletDiskType: 'Temporary'
    nodeLabels: {
      'aksclaw.io/workload-class': 'online-rft-grpo-rollout'
      'aksclaw.io/tree-cow-snapshot-fork': 'enabled'
      'aksclaw.io/hermetic-verifier-namespace': 'enforced'
    }
    nodeTaints: [
      'aksclaw.io/rft-rollout=true:NoSchedule'
    ]
  }
}

output verifierOracleContainerResourceId string = verifierOracleContainer.id
output rftRolloutPoolId string = rftRolloutPool.id
