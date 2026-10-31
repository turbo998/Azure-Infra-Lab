// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #338 (Cycle #337)
// Electronic-Grade Lu(MeCp)(COD) / Lu(acac)3 + TDMATm + DESe + TMA
// 300mm AB1/Y1 LuSe2 Contact, W Nanomesh Plasmonic Interconnect & TmSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Lu/Tm/Se AB1 LuSe2 Contact + W nanomesh + TmSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AB1 LuSe2/W-nanomesh/TmSe-PCM PEALD cluster')
@allowed([
  'prod-ab1-luse2-wnanomesh-tmse-pcm-sil3'
  'staging-luse2-wnanomesh-digital-twin'
])
param environment string = 'prod-ab1-luse2-wnanomesh-tmse-pcm-sil3'

@description('Target 6N5 Lu(MeCp)(COD), Lu(acac)3, TDMATm, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target LuSe2/TmSe2 van der Waals contact spec')
param targetLuse2ContactSpec string = '21.2Ohm_um-pCFET-S0.99-VdWGap0.11nm'

@description('Target W nanomesh plasmonic interconnect spec')
param targetWNanomeshPlasmonicSpec string = '210um-Lspp-0.008dB_um-RMS0.07nm-W111'

@description('Target TmSe PCM spec (switch latency, Ron/Roff and energy)')
param targetTmsePcmSpec string = '185ps-RonRoff7.6e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-lumecp-luse2-tmse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-luse2tmse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-luse2-tmse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-LuMeCpCOD-Luacac3-TDMATm-DESe-TMA-AB1-LuSe2-WNanomesh-TmSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetLuse2ContactSpec
    PlasmonicTarget: targetWNanomeshPlasmonicSpec
    PcmTarget: targetTmsePcmSpec
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
          'agent-infra/role': 'lumecpcod-luacac3-tdmatm-dese-tma-ab1-luse2-contact-w-nanomesh-tmse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-lu-tm-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-LuTmSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
