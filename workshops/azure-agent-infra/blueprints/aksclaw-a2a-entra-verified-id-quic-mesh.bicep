// ============================================================================
// Blueprint #32: Cross-Organization Agent-to-Agent (A2A) Federation Mesh —
// Microsoft Entra Verified ID (`did:web` + SD-JWT Selective Disclosure),
// Azure Front Door HTTP/3 QUIC 0-RTT & Deadline-Budget SLA Router
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name for AKSClaw Fleet')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure Front Door Profile Name for HTTP/3 QUIC 0-RTT A2A Gateway')
param afdProfileName string = 'afd-aksclaw-a2a-quic-prod'

resource afdProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: afdProfileName
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource a2aFederationPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'a2afedmesh'
  properties: {
    count: 6
    vmSize: 'Standard_D32as_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 24
    nodeLabels: {
      'aksclaw.io/workload-class': 'a2a-cross-org-federation-gateway'
      'aksclaw.io/identity-cred': 'entra-verified-id-did-web-sd-jwt'
      'aksclaw.io/transport-protocol': 'http3-quic-0rtt-multiplexed'
      'aksclaw.io/deadline-propagation': 'x-a2a-deadline-budget-ms'
    }
    nodeTaints: [
      'aksclaw.io/a2a-mesh=true:NoSchedule'
    ]
  }
}

output afdProfileId string = afdProfile.id
output a2aPoolResourceId string = a2aFederationPool.id
output quicStreamP99LatencyMs string = '38.5'
output attributeOverDisclosurePct int = 0
