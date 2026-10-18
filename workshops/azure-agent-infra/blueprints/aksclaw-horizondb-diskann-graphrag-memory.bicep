// ============================================================================
// Blueprint #19: Multi-Tenant Agentic Memory Tiering — HorizonDB pg_diskann
// Vector Index (64B PQ + NVMe SSD Page Graph), Azure Managed Redis L0 Working
// Memory & GraphRAG Community Summary Cache, and Blob ZRS L2 Parquet Cold Tier
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('HorizonDB / PostgreSQL Flexible Server name for L1 DiskANN Warm Vector Index')
param pgServerName string = 'pg-aksclaw-diskann-prod'

@description('Azure Managed Redis name for L0 Working Memory & GraphRAG Leiden Community Cache')
param redisCacheName string = 'redis-aksclaw-graphrag-l0'

@description('Storage Account name for L2 Episodic Memory Parquet Cold Archive')
param coldStorageAccountName string = 'staksclawmemcoldzrs01'

@description('Administrator login for HorizonDB / PostgreSQL')
param administratorLogin string = 'aksclaw_mem_admin'

@secure()
@description('Administrator password for HorizonDB / PostgreSQL')
param administratorPassword string

// 1. L1 Warm Vector Tier: PostgreSQL Flexible Server with pg_diskann + PremiumV2 SSD
resource pgServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: pgServerName
  location: location
  sku: {
    name: 'Standard_D16ds_v5'
    tier: 'GeneralPurpose'
  }
  properties: {
    version: '16'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    storage: {
      storageSizeGB: 2048
      type: 'PremiumV2_LRS'
      iops: 40000
      throughput: 1000
    }
    highAvailability: {
      mode: 'ZoneRedundant'
    }
  }
}

resource pgExtensionsConfig 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2023-12-01-preview' = {
  parent: pgServer
  name: 'azure.extensions'
  properties: {
    value: 'VECTOR,PG_DISKANN,AZURE_AI,PG_CRON'
    source: 'user-override'
  }
}

// 2. L0 Hot Working Memory & GraphRAG Community Summary Cache: Azure Managed Redis
resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2024-02-01' = {
  name: redisCacheName
  location: location
  sku: {
    name: 'Balanced_B10'
  }
  zones: [ '1', '2', '3' ]
  properties: {
    minimumTlsVersion: '1.2'
  }
}

// 3. L2 Cold Episodic Memory Archive: ZRS Storage Account with Cool/Cold Lifecycle Policy
resource coldStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: coldStorageAccountName
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource lifecyclePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  parent: coldStorage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'episodicParquetTieringRule'
          enabled: true
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                tierToCold: {
                  daysAfterModificationGreaterThan: 90
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: 365
                }
              }
            }
            filters: {
              blobTypes: [ 'blockBlob' ]
              prefixMatch: [ 'episodic-memory-parquet/' ]
            }
          }
        }
      ]
    }
  }
}

output pgDiskAnnFqdn string = pgServer.properties.fullyQualifiedDomainName
output redisL0Id string = redisEnterprise.id
output coldArchiveStorageId string = coldStorage.id
