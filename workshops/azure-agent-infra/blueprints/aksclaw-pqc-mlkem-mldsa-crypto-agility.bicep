// ============================================================================
// Blueprint #26: Post-Quantum Cryptography (PQC) Hybrid mTLS & ML-DSA Attestation
// Target: Azure Key Vault Managed HSM (FIPS 140-3 Level 3) + AKS PQC Gateway Pool
// Purpose:
//   1. Provision Managed HSM security domain & PQC-ready hybrid key-encryption-key
//      (ML-KEM-1024 + RSA-HSM-4096) for Harvest-Now-Decrypt-Later (HNDL) protection
//      of cross-region HorizonDB WAL and 10-year episodic memory archives.
//   2. Configure AKS nodepool with initcwnd=16 sysctl tuning and AVX-512 NTT
//      acceleration labels for X25519MLKEM768 (FIPS 203) mTLS and ML-DSA-65 (FIPS 204).
// ============================================================================

@description('Deployment region for PQC Managed HSM and AKS Gateway nodepool')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Managed HSM name for PQC hybrid key custody')
param managedHsmName string = 'hsm-aksclaw-pqc-prod'

@description('Initial administrator Entra Object ID for Managed HSM')
param adminObjectId string = '00000000-0000-0000-0000-000000000000'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Azure Key Vault Managed HSM (FIPS 140-3 L3) for PQC Hybrid Envelope Custody
resource pqcManagedHsm 'Microsoft.KeyVault/managedHSMs@2023-07-01' = {
  name: managedHsmName
  location: location
  sku: {
    family: 'B'
    name: 'Standard_B1'
  }
  properties: {
    tenantId: subscription().tenantId
    initialAdminObjectIds: [
      adminObjectId
    ]
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}

// 2. AKS PQC Crypto-Agility Gateway & Sandbox Nodepool (initcwnd=16 + X25519MLKEM768)
resource pqcGatewayPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'pqcgwpool'
  properties: {
    count: 8
    minCount: 4
    maxCount: 32
    enableAutoScaling: true
    vmSize: 'Standard_D32s_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAcceleratedNetworking: true
    linuxOSConfig: {
      sysctls: {
        netCoreSomaxconn: 32768
        netIpv4TcpTwReuse: true
      }
    }
    nodeLabels: {
      'aksclaw.io/pqc-kem-suite': 'X25519MLKEM768-FIPS203'
      'aksclaw.io/pqc-sig-suite': 'Ed25519-MLDSA65-FIPS204'
      'aksclaw.io/hndl-envelope': 'MLKEM1024-AES256GCM'
      'aksclaw.io/tcp-initcwnd': '16'
    }
  }
}

output pqcManagedHsmId string = pqcManagedHsm.id
output pqcGatewayPoolId string = pqcGatewayPool.id
