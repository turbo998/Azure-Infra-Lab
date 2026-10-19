// ============================================================================
// Blueprint #42: Autonomous Smart Mobility, SDV/V2X Fleet & ADAS Simulation Agent Pool
// Provisions:
//   1. Azure Event Grid Namespace (MQTT v5 over QUIC 0-RTT V2X Telemetry Broker)
//   2. Azure Data Explorer (Kusto) Cluster for CAN-FD / LiDAR Corner-Case Indexing
//   3. Azure Key Vault Premium HSM Key for UNECE R155 / ISO 21434 Uptane Dual-ECU Signing
//   4. AKS Standard_NV36ads_A10_v5 Closed-Loop CARLA / OpenSCENARIO 2.0 RSS Verification Pool
// ============================================================================

@description('Deployment Azure region')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'aksclawsdv'

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('CARLA / OpenSCENARIO closed-loop ADAS verification GPU node count')
@minValue(4)
@maxValue(64)
param carlaGpuNodeCount int = 8

resource v2xEventGridNamespace 'Microsoft.EventGrid/namespaces@2024-06-01-preview' = {
  name: '${envPrefix}-v2x-mqtt-quic-ns'
  location: location
  sku: {
    name: 'Standard'
    capacity: 20
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.3'
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumSessionExpiryInHours: 8
      maximumClientSessionsPerAuthenticationName: 4
    }
  }
}

resource v2xTelemetryTopicSpace 'Microsoft.EventGrid/namespaces/topicSpaces@2024-06-01-preview' = {
  parent: v2xEventGridNamespace
  name: 'sdv-cornercase-ringbuffer'
  properties: {
    topicTemplates: [
      'vehicles/+/canfd/anomaly-delta'
      'vehicles/+/lidar/rss-trigger'
      'vehicles/+/ota/uptane-parked-ack'
    ]
  }
}

resource uptaneKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${envPrefix}-r155-hsm-kv'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    publicNetworkAccess: 'Disabled'
  }
}

resource uptaneDirectorSigningKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: uptaneKeyVault
  name: 'unece-r155-uptane-director-ec-p384'
  properties: {
    kty: 'EC-HSM'
    curveName: 'P-384'
    keyOps: [
      'sign'
      'verify'
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

resource carlaAdasVerifyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'carlarss'
  properties: {
    count: carlaGpuNodeCount
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    nodeLabels: {
      'aksclaw.io/workload-class': 'automotive-sdv-carla-rss-verifier'
      'aksclaw.io/v2x-ingest': 'mqtt-quic-0rtt-64ms-ring-delta'
      'aksclaw.io/adas-safety-gate': 'openscenario2-rss-ttc-1.8s-barrier'
      'aksclaw.io/ota-guardrail': 'unece-r155-iso21434-uptane-parked-interlock'
    }
    nodeTaints: [
      'aksclaw.io/automotive-sdv=true:NoSchedule'
    ]
  }
}

output v2xNamespaceId string = v2xEventGridNamespace.id
output uptaneSigningKeyUri string = uptaneDirectorSigningKey.properties.keyUriWithVersion
output carlaPoolName string = carlaAdasVerifyPool.name
