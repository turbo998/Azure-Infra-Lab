// ============================================================================
// Blueprint #257: Electronic-Grade 6N Trifluoroiodomethane (CF3I) & 5N5
// Heptafluoroiodopropane (C3F7I) + 5N5 Pentafluoroiodoethane (C2F5I)
// Ultra-Low-GWP (GWP < 1) HAR 3D NAND & DRAM RIE Etch PINN-MPC & SIL-3
// Target Runtime: AKS + Kata (AKSCLAW) + Azure Arc Edge (10 kHz QCL-TDLAS /
// UV-Vis 520 nm I2 / FTIR + GC-ECD/MS + ICP-MS + 206.2 nm I* / 703.7 nm F* OES
// + IEC 61511 / SEMI S2 / NFPA 704 / OSHA SIL-3 Photolytic I2 / HI / COF2 Guard)
// ============================================================================

@description('Deployment Azure region for CF3I / C3F7I / C2F5I Ultra-Low-GWP HAR RIE Etch Control Plane')
param location string = resourceGroup().location

@description('Environment tier for Electronic-Grade 6N CF3I & 5N5 C3F7I/C2F5I Production & Etch Fab')
@allowed([
  'prod-6n-cf3i-c3f7i-c2f5i-har-rie-sil3'
  'staging-cf3i-c3f7i-c2f5i-pinn-digital-twin'
])
param environmentTier string = 'prod-6n-cf3i-c3f7i-c2f5i-har-rie-sil3'

@description('AKS Kubernetes version for Kata Confidential MicroVM NodePool')
param kubernetesVersion string = '1.31.2'

@description('Minimum purity target for 6N CF3I (fraction, >= 0.999999 = 6N)')
param minCf3iPurity6N string = '0.999999'

@description('Maximum photolytic free iodine I2 impurity limit in 6N CF3I / 5N5 C3F7I (ppbv)')
param maxPhotolyticI2ImpurityPpbv int = 15

@description('Maximum hydrogen iodide HI & hydrogen fluoride HF acid limit (ppbv)')
param maxAcidImpurityHiHfPpbv int = 20

@description('Maximum HAR > 100:1 3D NAND channel hole critical dimension bowing ratio (%)')
param maxHarChannelBowingPct string = '1.8'

@description('Maximum SIL-3 Emergency Exhaust & Amber-Shielded VMB Isolation Valve Trip Latency (ms)')
param maxSil3TripLatencyMs string = '0.13'

var clusterName = 'aks-cf3i-c3f7i-c2f5i-har-rie-${uniqueString(resourceGroup().id)}'
var vnetName = 'vnet-cf3i-c3f7i-c2f5i-har-rie-isolated'
var keyVaultName = 'kv-cf3i-${uniqueString(resourceGroup().id)}'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.256.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-kata-pinn-mpc'
        properties: {
          addressPrefix: '10.256.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-arc-edge-qcl-uvvis-oes-sil3'
        properties: {
          addressPrefix: '10.256.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'electronic-6n-cf3i-5n5-c3f7i-c2f5i-har-rie-etch'
    safetyStandard: 'SEMI-S2-NFPA-704-OSHA-SIL3'
    minCf3iPurity: minCf3iPurity6N
    maxPhotolyticI2Ppbv: string(maxPhotolyticI2ImpurityPpbv)
    maxAcidImpurityHiHfPpbv: string(maxAcidImpurityHiHfPpbv)
    maxHarChannelBowingPct: maxHarChannelBowingPct
    maxSil3TripLatencyMs: maxSil3TripLatencyMs
    environmentTier: environmentTier
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'katapinnpool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.infra/isolation': 'kata-mshv-vm'
          'agent.infra/domain': 'electronic-6n-cf3i-c3f7i-c2f5i-har-rie-pinn-mpc'
          'agent.infra/sil-rating': 'SIL-3-SEMI-S2-NFPA-704'
          'agent.infra/spectral-channels': 'qcl-tdlas-1075-1185-741cm1-uvvis-520nm-oes-206p2-703p7nm'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
       networkDataplane: 'cilium'
      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.10'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterName string = aksCluster.name
output pinnSafetyProfile string = 'SEMI-S2-SIL3-${maxSil3TripLatencyMs}ms-CF3I-${minCf3iPurity6N}-I2-${maxPhotolyticI2ImpurityPpbv}ppbv-Bow-${maxHarChannelBowingPct}pct'
