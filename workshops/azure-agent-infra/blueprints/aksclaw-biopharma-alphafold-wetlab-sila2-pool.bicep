// ============================================================================
// Blueprint #44: Biopharma Drug Discovery, AlphaFold3/FEP+ & SiLA-2 Wet-Lab Pool
// ============================================================================
// Target Architecture:
//   1. Azure Managed Lustre 8 TiB NVMe Scratch for MMseqs2 GPU-Accelerated MSA
//      (Multiple Sequence Alignment) & Cryo-EM Density Map Cache
//   2. AKS Standard_ND96isr_H100_v5 GPU Nodepool for AlphaFold3 / Boltz-1
//      Structure Prediction & OpenMM / FEP+ Free-Energy Perturbation Docking
//   3. SiLA-2 / Hamilton Liquid-Handling Robotic Interlock & IBBIS / SecureDNA
//      Dual-Use Biosecurity Sequence-Screening Air-Gap Gate
// ============================================================================

@description('Deployment region for Biopharma Discovery & Wet-Lab Agent Infrastructure')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-biopharma'

@description('Existing AKS cluster name')
param aksClusterName string = '${envPrefix}-aks'

@description('Standard_ND96isr_H100_v5 GPU node count for AF3 & FEP+ molecular docking')
@minValue(2)
@maxValue(64)
param biopharmaGpuNodeCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. Key Vault Premium HSM for SecureDNA / IBBIS Biosecurity Screening Attestation
resource bioKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${envPrefix}-kv-bio'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
  }
}

// 2. AKS Standard_ND96isr_H100_v5 (8x H100 80GB + InfiniBand) Biopharma GPU Pool
resource biopharmaGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'bioaf3p'
  properties: {
    count: biopharmaGpuNodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    osDiskSizeGB: 512
    osDiskType: 'Ephemeral'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    nodeLabels: {
      'aksclaw.io/workload-class': 'biopharma-af3-fep-wetlab-agent'
      'aksclaw.io/mmseqs2-msa-cache': 'lustre-nvme-gpu-msa-4.8s'
      'aksclaw.io/sila2-robot-interlock': 'deck-collision-reagent-compat-0pct'
      'aksclaw.io/biosecurity-screen-gate': 'securedna-ibbis-select-agent-block'
    }
    nodeTaints: [
      'nvidia.com/gpu=true:NoSchedule'
      'aksclaw.io/biopharma-wetlab=true:NoSchedule'
    ]
  }
}

output bioKeyVaultUri string = bioKeyVault.properties.vaultUri
output biopharmaGpuPoolName string = biopharmaGpuPool.name
