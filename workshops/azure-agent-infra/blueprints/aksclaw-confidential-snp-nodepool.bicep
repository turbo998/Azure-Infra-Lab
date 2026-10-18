// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint 8
// AKSClaw Confidential Agent Node Pool (AMD SEV-SNP `Standard_DC64as_v5`) +
// Microsoft Azure Attestation (MAA) + Key Vault Managed HSM SKR Release Policy
// ============================================================================

targetScope = 'resourceGroup'

@description('Azure region supporting AMD SEV-SNP Confidential VMs and Managed HSM')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the AKSClaw multi-tenant control plane')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Subnet resource ID for the Confidential Kata-CC agent node pool')
param agentSubnetId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. AMD SEV-SNP Confidential Agent Pool running Kata-CC (`kata-cc-isolation`)
resource confidentialAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'ccnpd64v5'
  properties: {
    count: 4
    minCount: 2
    maxCount: 24
    enableAutoScaling: true
    vmSize: 'Standard_DC64as_v5' // 64 vCPU / 256 GiB · AMD EPYC SEV-SNP hardware memory encryption
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataCcIsolation' // Confidential Containers (Guest VM inside hardware TEE)
    vnetSubnetID: agentSubnetId
    osDiskSizeGB: 256
    osDiskType: 'Ephemeral'
    nodeLabels: {
      'aksclaw.azure.com/isolation-tier': 'confidential-sev-snp'
      'kubernetes.azure.com/kata-cc-isolation': 'true'
    }
    nodeTaints: [
      'aksclaw.azure.com/confidential=true:NoSchedule'
    ]
  }
}

// 2. Dedicated Microsoft Azure Attestation (MAA) Provider for Hardware Quote Verification
resource maaProvider 'Microsoft.Attestation/attestationProviders@2021-06-01' = {
  name: 'maaaksclaw${uniqueString(resourceGroup().id)}'
  location: location
  properties: {}
}

// 3. Key Vault Premium / Managed HSM Key with Secure Key Release (SKR) Policy
//    The encryption key is ONLY released inside a verified AMD SEV-SNP Guest TEE
output skrReleasePolicyJson object = {
  version: '1.0.0'
  anyOf: [
    {
      authority: maaProvider.properties.attestUri
      allOf: [
        {
          claim: 'x-ms-isolation-tee.x-ms-attestation-type'
          equals: 'sevsnpvm'
        }
        {
          claim: 'x-ms-isolation-tee.x-ms-compliance-status'
          equals: 'azure-compliant-uvm'
        }
        {
          claim: 'x-ms-sevsnpvm-is-debuggable'
          equals: false
        }
      ]
    }
  ]
}
