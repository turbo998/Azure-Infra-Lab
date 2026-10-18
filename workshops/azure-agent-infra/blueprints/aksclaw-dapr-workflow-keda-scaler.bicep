// =============================================================================
// Blueprint #12: Long-Horizon Stateful Agent Workflow Orchestration —
// Azure Service Bus Premium (Partitioned Transactional Outbox & Dead-Letter
// Queue) + AKS Dapr Workflow State Store & KEDA ScaledObject Configuration
// =============================================================================
targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param prefix string = 'aksclaw-wf'

@description('Service Bus Premium Messaging Units (1, 2, 4, 8, 16)')
@allowed([1, 2, 4, 8, 16])
param messagingUnits int = 2

// 1. Azure Service Bus Premium Namespace (Zone Redundant, Private Link Ready)
resource sbNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: '${prefix}-sb-prem'
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: messagingUnits
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    zoneRedundant: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: '1.2'
    disableLocalAuth: true
  }
}

// 2. Transactional Wakeup & Outbox Queue (Duplicate Detection + Dead-Lettering)
resource wakeupQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: sbNamespace
  name: 'agent-sandbox-wakeup-outbox'
  properties: {
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT1H'
    requiresSession: true
    lockDuration: 'PT2M'
    maxDeliveryCount: 5
    deadLetteringOnMessageExpiration: true
    defaultMessageTimeToLive: 'P7D'
    maxSizeInMegabytes: 81920
  }
}

// 3. Saga Compensation Queue for Failed Multi-Step Tool Calls
resource sagaCompensateQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: sbNamespace
  name: 'agent-saga-compensation-dlq'
  properties: {
    requiresDuplicateDetection: true
    duplicateDetectionHistoryTimeWindow: 'PT4H'
    requiresSession: true
    lockDuration: 'PT2M'
    maxDeliveryCount: 10
    deadLetteringOnMessageExpiration: true
  }
}

// 4. Zombie Sandbox TTL Reaper Event Topic
resource reaperTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: sbNamespace
  name: 'agent-sandbox-lease-reaper'
  properties: {
    supportOrdering: true
    defaultMessageTimeToLive: 'PT10M'
  }
}

output serviceBusNamespaceFqdn string = '${sbNamespace.name}.servicebus.windows.net'
output wakeupQueueName string = wakeupQueue.name
output sagaCompensateQueueName string = sagaCompensateQueue.name
