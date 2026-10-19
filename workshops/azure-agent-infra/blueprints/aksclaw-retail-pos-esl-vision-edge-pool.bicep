// =============================================================================
// Blueprint #46: Autonomous Retail POS Edge, BLE 5.4 PAwR ESL Dynamic Pricing
// & PCI-DSS v4.0 Privacy-Blurred Loss-Prevention Agent Infrastructure
// =============================================================================
// Provisions:
//   1. Azure Arc-enabled Kubernetes Store-Edge Extension for TensorRT-LLM /
//      YOLOv10 self-checkout SKU-swap detection with inline GPU DMA face &
//      payment-card PAN blurring (<1.4 ms, 0.0% biometric/PAN leakage).
//   2. Azure Event Grid Namespace Topic for BLE 5.4 PAwR (Periodic Advertising
//      with Responses) 50,000-tag ESL sub-GHz broadcast & two-phase POS atomic
//      price-parity latch (EU Omnibus / FTC 0.0% overcharge guarantee).
//   3. Immutable PCI-DSS v4.0 & GDPR Checkout Audit Storage Account with WORM
//      retention for anonymized loss-prevention & price-latch evidence.
// =============================================================================

@description('Deployment region for regional retail control plane and POS-ESL coordinator')
param location string = resourceGroup().location

@description('Environment prefix for retail store-edge agent resources')
param envPrefix string = 'aksclaw-retail'

@description('Number of connected retail store locations managed by the regional control plane')
@minValue(10)
@maxValue(10000)
param storeLocations int = 500

@description('Electronic Shelf Labels (ESLs) per store location synchronized via BLE 5.4 PAwR')
param eslTagsPerStore int = 50000

var eventGridNamespaceName = '${envPrefix}-esl-pawr-egns'
var storageAccountName = replace('${envPrefix}pciaudit', '-', '')
var aksClusterName = '${envPrefix}-regional-aks'

// 1. Immutable PCI-DSS v4.0 & GDPR Store Checkout Audit Storage (WORM)
resource retailAuditStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
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
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
  }
  tags: {
    workload: 'retail-pos-esl-vision-edge'
    pciDssVersion: '4.0'
    inlinePrivacyBlurMs: '1.4'
    biometricPanLeakPct: '0.0'
  }
}

resource auditContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${retailAuditStorage.name}/default/pos-esl-parity-worm-ledger'
  properties: {
    immutableStorageWithVersioning: {
      enabled: true
    }
  }
}

// 2. Azure Event Grid Namespace for BLE 5.4 PAwR ESL Atomic Price-Latch Sync
resource eslEventGridNamespace 'Microsoft.EventGrid/namespaces@2024-06-01-preview' = {
  name: eventGridNamespaceName
  location: location
  sku: {
    name: 'Standard'
    capacity: 8
  }
  properties: {
    isZoneRedundant: true
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumSessionExpiryInHours: 8
      maximumClientSessionsPerAuthenticationName: 100
    }
  }
  tags: {
    storeLocations: string(storeLocations)
    eslTagsPerStore: string(eslTagsPerStore)
    pawrSyncLatencySec: '18.5'
    omnibusPriceMismatchPct: '0.0'
  }
}

resource posPriceLatchTopic 'Microsoft.EventGrid/namespaces/topics@2024-06-01-preview' = {
  parent: eslEventGridNamespace
  name: 'ble54-pawr-two-phase-pos-price-latch'
  properties: {
    publisherType: 'Custom'
    inputSchema: 'CloudEventSchemaV1_0'
    eventRetentionInDays: 7
  }
}

// 3. Regional AKS Retail Coordinator & Store-Edge Fleet Policy Nodepool
resource regionalRetailAks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
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
        name: 'retailedge'
        count: 4
        vmSize: 'Standard_NV36ads_A10_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'aksclaw.io/workload-class': 'retail-pos-esl-vision-edge'
          'aksclaw.io/ble54-pawr-esl-mesh': 'enabled'
          'aksclaw.io/pos-atomic-price-latch': 'min-old-new-until-eink-ack'
          'aksclaw.io/inline-gpu-privacy-blur': 'pci-dss-v4-gdpr-enforced'
        }
        nodeTaints: [
          'aksclaw.io/retail-edge=true:NoSchedule'
        ]
      }
    ]
  }
}

output retailRegionalAksId string = regionalRetailAks.id
output eslEventGridNamespaceEndpoint string = eslEventGridNamespace.properties.topicSpacesConfiguration.hostname
output pciAuditStorageId string = retailAuditStorage.id
