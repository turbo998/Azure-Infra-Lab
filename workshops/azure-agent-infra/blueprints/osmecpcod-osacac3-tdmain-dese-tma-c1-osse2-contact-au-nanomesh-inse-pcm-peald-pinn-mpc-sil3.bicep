// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #313 (Cycle #312)
// Electronic-Grade Os(MeCp)(COD) / Os(acac)3 + TDMAIn + DESe + TMA
// 300mm C1/B1 OsSe2 Contact, Au Nanomesh Plasmonic Interconnect & InSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Os/In/Se C1 OsSe2 Contact + Au nanomesh + InSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the C1 OsSe2/Au-nanomesh/InSe-PCM PEALD cluster')
@allowed([
  'prod-c1-osse2-aunanomesh-inse-pcm-sil3'
  'staging-osse2-aunanomesh-digital-twin'
])
param environment string = 'prod-c1-osse2-aunanomesh-inse-pcm-sil3'

@description('Target 6N5 Os(MeCp)(COD), Os(acac)3, TDMAIn, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target OsSe2/InSe2 van der Waals contact spec')
param targetOsse2ContactSpec string = '28.5Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Au nanomesh plasmonic interconnect spec')
param targetAuNanomeshPlasmonicSpec string = '154um-Lspp-0.026dB_um-RMS0.08nm-Au111'

@description('Target InSe PCM spec (switch latency, Ron/Roff and energy)')
param targetInsePcmSpec string = '410ps-RonRoff2.6e8-0.09pJ_bit-6Bit'

var clusterName = 'aks-osmecp-osse2-inse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-osse2inse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-osse2-inse-sil3-${uniqueString(resourceGroup().id)}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Workload: 'Electronic-Grade-6N5-OsMeCpCOD-Osacac3-TDMAIn-DESe-TMA-C1-OsSe2-AuNanomesh-InSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetOsse2ContactSpec
    PlasmonicTarget: targetAuNanomeshPlasmonicSpec
    PcmTarget: targetInsePcmSpec
    Environment: environment
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcpool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: true
        minCount: 2
        maxCount: 8
        nodeLabels: {
          'agent-infra/role': 'osmecpcod-osacac3-tdmain-dese-tma-c1-osse2-contact-au-nanomesh-inse-pcm-pinn-mpc'
          'accelerators/gpu': 'nvidia-a100-80gb'
        }
      }
      {
        name: 'sil3safepool'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-os-in-se-tma-interlock'
          'safety/tier': 'iec-61511-sil3-0.10ms'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output keyVaultUri string = keyVault.properties.vaultUri
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-OsInSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
