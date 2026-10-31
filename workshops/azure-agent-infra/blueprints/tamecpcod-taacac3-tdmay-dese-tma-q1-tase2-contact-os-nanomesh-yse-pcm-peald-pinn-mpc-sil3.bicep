// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #327 (Cycle #326)
// Electronic-Grade Ta(MeCp)(COD) / Ta(acac)3 + TDMAY + DESe + TMA
// 300mm Q1/P1 TaSe2 Contact, Os Nanomesh Plasmonic Interconnect & YSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ta/Y/Se Q1 TaSe2 Contact + Os nanomesh + YSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the Q1 TaSe2/Os-nanomesh/YSe-PCM PEALD cluster')
@allowed([
  'prod-q1-tase2-osnanomesh-yse-pcm-sil3'
  'staging-tase2-osnanomesh-digital-twin'
])
param environment string = 'prod-q1-tase2-osnanomesh-yse-pcm-sil3'

@description('Target 6N5 Ta(MeCp)(COD), Ta(acac)3, TDMAY, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target TaSe2/YSe2 van der Waals contact spec')
param targetTase2ContactSpec string = '24.5Ohm_um-pCFET-S0.99-VdWGap0.14nm'

@description('Target Os nanomesh plasmonic interconnect spec')
param targetOsNanomeshPlasmonicSpec string = '188um-Lspp-0.012dB_um-RMS0.08nm-Os0001'

@description('Target YSe PCM spec (switch latency, Ron/Roff and energy)')
param targetYsePcmSpec string = '240ps-RonRoff5.4e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-tamecp-tase2-yse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-tase2yse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-tase2-yse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-TaMeCpCOD-Taacac3-TDMAY-DESe-TMA-Q1-TaSe2-OsNanomesh-YSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetTase2ContactSpec
    PlasmonicTarget: targetOsNanomeshPlasmonicSpec
    PcmTarget: targetYsePcmSpec
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
          'agent-infra/role': 'tamecpcod-taacac3-tdmay-dese-tma-q1-tase2-contact-os-nanomesh-yse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ta-y-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-TaYSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
