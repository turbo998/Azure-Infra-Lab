// ============================================================================
// Blueprint #22: Agentic Data Lakehouse & Text-to-SQL / DuckDB Sandbox Pool
// Azure Data Lake Storage Gen2 (OneLake ABFS Hierarchical Namespace) +
// Entra OBO User Delegation SAS Proxy + Memory-Optimized DuckDB Sandbox Pool
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('ADLS Gen2 / OneLake Gateway storage account name')
param lakehouseStorageName string = 'staksclawonelakehns01'

// 1. Host-Side ABFS Credential & Column-Masking Proxy Identity
resource abfsProxyIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-aksclaw-abfs-column-masking-proxy'
  location: location
}

// 2. Azure Data Lake Storage Gen2 (Hierarchical Namespace + ZRS for Delta Parquet)
resource lakehouseStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: lakehouseStorageName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    isSftpEnabled: false
    isNfsV3Enabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
  }
}

// 3. Storage Blob Delegator Role for Host-Side ABFS OBO SAS Minting Proxy
var storageBlobDelegatorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db58b8e5-c6ad-4a2a-8342-4190687cbf4a')
resource abfsDelegatorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(lakehouseStorage.id, abfsProxyIdentity.id, storageBlobDelegatorRoleId)
  scope: lakehouseStorage
  properties: {
    roleDefinitionId: storageBlobDelegatorRoleId
    principalId: abfsProxyIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// 4. AKS Memory-Optimized Ephemeral DuckDB/Polars Analytical Sandbox Pool (Standard_E32ds_v6)
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource lakehouseSandboxPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'swelakehouse'
  properties: {
    count: 32
    vmSize: 'Standard_E32ds_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    availabilityZones: [ '1', '2', '3' ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'lakehouse-duckdb-analytics'
      'aksclaw.io/abfs-column-masking-proxy': 'enabled'
      'aksclaw.io/sqlglot-ast-cost-guard': 'enabled'
    }
  }
}

output lakehouseStorageId string = lakehouseStorage.id
output abfsProxyClientId string = abfsProxyIdentity.properties.clientId
output lakehouseSandboxPoolId string = lakehouseSandboxPool.id
