// ============================================================================
// Blueprint #41: Autonomous Media Production, Live Broadcast & OpenUSD/3DGS Agent Pool
// Provisions:
//   1. Azure Managed Lustre / Blob ZRS OpenUSD & 3D Gaussian Splatting Scene Cache
//   2. Azure Key Vault Managed HSM C2PA 2.1 Content Credentials Signing Key
//   3. AKS Standard_NV72ads_A10_v5 / NC80adis_H100_v5 NVDEC/OpenUSD Render Pool
// ============================================================================

@description('Deployment region for Media Production & OpenUSD Agent Infrastructure')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-media'

@description('Existing AKS cluster name')
param aksClusterName string = '${envPrefix}-aks'

@description('Concurrent 4K60 HDR SMPTE ST 2110 / SRT broadcast streams')
@minValue(4)
@maxValue(512)
param concurrent4kStreams int = 32

var renderGpuNodes = max(2, (concurrent4kStreams + 7) / 8)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. OpenUSD Layer & 3D Gaussian Splatting BVH Cache Storage Account (ZRS)
resource openUsdStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: replace('${envPrefix}usd3dgs', '-', '')
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    Tags: {
      'aksclaw.io/openusd-bvh-cache': 'enabled'
      'aksclaw.io/c2pa-manifest-version': '2.1'
    }
  }
}

// 2. Key Vault Premium HSM-Backed C2PA 2.1 Content Credentials Signer
resource c2paKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${envPrefix}-c2pa-kv'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
  }
}

// 3. AKS NVDEC/NVENC + OpenUSD/3DGS Verification & Rendering Node Pool
resource mediaRenderPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'usd3dgsp'
  properties: {
    count: renderGpuNodes
    vmSize: 'Standard_NV72ads_A10_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'media-openusd-3dgs-render'
      'aksclaw.io/nvdec-dma-ring': 'smpte-st2110-srt-6.8ms'
      'aksclaw.io/openusd-scene-verifier': 'bbox-manifold-vram-76gb'
      'aksclaw.io/c2pa-provenance-gate': 'hsm-c2pa-2.1-mandatory'
    }
    nodeTaints: [
      'aksclaw.io/media-gpu=true:NoSchedule'
    ]
  }
}

output openUsdStorageId string = openUsdStorage.id
output c2paKeyVaultUri string = c2paKeyVault.properties.vaultUri
output mediaRenderPoolId string = mediaRenderPool.id
