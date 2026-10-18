// ============================================================================
// Blueprint #21: Autonomous SWE-Agent CI/CD & Verification Sandbox Pool
// Azure Blob ZRS Content-Addressable Store (Bazel / sccache / Turborepo CAS)
// + Read-Only Untrusted Agent Identity RBAC Split + Local NVMe BuildKit Pool
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Storage Account name for L2 Bazel/sccache Remote CAS')
param casStorageAccountName string = 'staksclawbazelcaszrs01'

// 1. Untrusted SWE-Agent Sandbox Identity (Strictly Read-Only on Shared CAS)
resource agentSandboxReaderIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-aksclaw-swe-sandbox-cas-reader'
  location: location
}

// 2. Trusted Main-Branch CI Cache Warmer Identity (Write-Authorized on Shared CAS)
resource trustedCacheWarmerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-aksclaw-trusted-cas-warmer'
  location: location
}

// 3. Azure Blob Storage ZRS for L2 Content-Addressable Compilation Cache (CAS)
resource casStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: casStorageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
  }
}

resource casBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: casStorage
  name: 'default'
}

resource casContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: casBlobService
  name: 'bazel-sccache-cas'
  properties: {
    publicAccess: 'None'
  }
}

// 4. Storage Blob Data Reader Role for Untrusted SWE-Agent Sandboxes (0% CAS Poisoning)
var storageBlobDataReaderRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
resource sandboxCasReaderAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(casStorage.id, agentSandboxReaderIdentity.id, storageBlobDataReaderRoleId)
  scope: casStorage
  properties: {
    roleDefinitionId: storageBlobDataReaderRoleId
    principalId: agentSandboxReaderIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// 5. AKS Local-NVMe Rootless BuildKit & SWE Verification Nodepool (Standard_L32s_v3)
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource sweBuildkitPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'swebldnvme'
  properties: {
    count: 25
    vmSize: 'Standard_L32s_v3'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 5
    maxCount: 60
    availabilityZones: [ '1', '2', '3' ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'swe-cicd-verification'
      'aksclaw.io/rootless-buildkit-overlayfs': 'enabled'
      'aksclaw.io/nvme-l1-cas-cache': 'enabled'
    }
  }
}

output casStorageId string = casStorage.id
output sandboxReaderClientId string = agentSandboxReaderIdentity.properties.clientId
output sweBuildkitPoolId string = sweBuildkitPool.id
