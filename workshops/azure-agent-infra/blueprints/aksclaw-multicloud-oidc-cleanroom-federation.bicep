// ============================================================================
// Blueprint #23: Sovereign Multi-Cloud OIDC Workload Federation &
// AMD SEV-SNP Confidential Clean-Room Collaborative Agent Pool
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('External Cloud OIDC Issuer URL (e.g., AWS EKS / GCP Workload Identity Pool)')
param externalOidcIssuer string = 'https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE0123456789ABCDEF'

@description('External Subject Identifier for Cross-Cloud Federated Agent')
param externalOidcSubject string = 'system:serviceaccount:agent-federation:cross-cloud-broker'

// 1. User-Assigned Managed Identity with Federated Identity Credential (Zero Static AK/SK)
resource federatedCleanroomIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-aksclaw-multicloud-cleanroom-broker'
  location: location
}

resource crossCloudOidcFederation 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  parent: federatedCleanroomIdentity
  name: 'fed-aws-gcp-oidc-cleanroom'
  properties: {
    issuer: externalOidcIssuer
    subject: externalOidcSubject
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

// 2. Microsoft Azure Attestation (MAA) Provider for Dual-Party Clean-Room SKR Policy
resource cleanroomAttestation 'Microsoft.Attestation/attestationProviders@2021-06-01' = {
  name: 'maaaksclawcleanroom01'
  location: location
  properties: {}
}

// 3. Cross-Cloud Kernel WireGuard Mesh NSG (UDP 51820 Direct Peering)
resource wireguardMeshNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-aksclaw-wireguard-multicloud-mesh'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Kernel-WireGuard-UDP-51820'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '51820'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
        }
      }
    ]
  }
}

// 4. AKS AMD SEV-SNP Confidential Clean-Room Nodepool (Standard_DC32as_v5)
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource cleanroomNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'snpcleanrm'
  properties: {
    count: 32
    vmSize: 'Standard_DC32as_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    availabilityZones: [ '1', '2', '3' ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'confidential-cleanroom-federation'
      'aksclaw.io/wireguard-kernel-mesh': 'enabled'
      'aksclaw.io/sev-snp-bilateral-skr': 'enabled'
    }
  }
}

output federatedIdentityClientId string = federatedCleanroomIdentity.properties.clientId
output attestationUri string = cleanroomAttestation.properties.attestUri
output cleanroomNodePoolId string = cleanroomNodePool.id
