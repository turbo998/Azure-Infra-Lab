// =============================================================================
// Blueprint #15: Multi-Agent Swarm Fan-Out Governance — Azure Managed Redis
// Enterprise (`Balanced_B10` Zone-Redundant) for Hierarchical Budget Envelopes,
// AST/Directory Read-Write Lease Locking & KEDA Intent-Ahead Pre-Warm Streams
// =============================================================================
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param prefix string = 'aksclaw-swarm'

// 1. Azure Managed Redis Enterprise (Balanced_B10 Zone-Redundant)
resource redisGovernor 'Microsoft.Cache/redisEnterprise@2024-02-01' = {
  name: '${prefix}-redis-gov'
  location: location
  sku: {
    name: 'Balanced_B10'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
}

// 2. Redis Database with Active-Geo / Lua Atomic Budget & Wait-For Graph Lease Modules
resource redisDb 'Microsoft.Cache/redisEnterprise/databases@2024-02-01' = {
  parent: redisGovernor
  name: 'default'
  properties: {
    clientProtocol: 'Encrypted'
    port: 10000
    clusteringPolicy: 'EnterpriseCluster'
    evictionPolicy: 'NoEviction'
    persistence: {
      aofEnabled: true
      aofFrequency: '1s'
    }
  }
}

output redisGovernorId string = redisGovernor.id
output redisEndpointPort int = redisDb.properties.port
