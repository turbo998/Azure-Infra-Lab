// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #349 (Cycle #348)
// Electronic-Grade Lu(MeCp)(COD) / Lu(acac)3 + TDMAHf + DESe + TMA
// 300mm AM1/AL1 LuSe2 Contact, Cu Nanomesh Plasmonic Interconnect & HfSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Lu/Hf/Se AM1 LuSe2 Contact + Cu nanomesh + HfSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AM1 LuSe2/Cu-nanomesh/HfSe-PCM PEALD cluster')
@allowed([
  'prod-am1-luse2-cunanomesh-hfse-pcm-sil3'
  'staging-luse2-cunanomesh-digital-twin'
])
param environment string = 'prod-am1-luse2-cunanomesh-hfse-pcm-sil3'

@description('Target 6N5 Lu(MeCp)(COD), Lu(acac)3, TDMAHf, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target LuSe2/HfSe2 van der Waals contact spec')
param targetLuse2ContactSpec string = '17.9Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Cu nanomesh plasmonic interconnect spec')
param targetCuNanomeshPlasmonicSpec string = '232um-Lspp-0.008dB_um-RMS0.07nm-Cu111'

@description('Target HfSe PCM spec (switch latency, Ron/Roff and energy)')
param targetHfsePcmSpec string = '140ps-RonRoff9.9e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-lumecp-luse2-hfse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-luse2hfse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-luse2-hfse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-LuMeCpCOD-Luacac3-TDMAHf-DESe-TMA-AM1-LuSe2-CuNanomesh-HfSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetLuse2ContactSpec
    PlasmonicTarget: targetCuNanomeshPlasmonicSpec
    PcmTarget: targetHfsePcmSpec
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
          'agent-infra/role': 'lumecpcod-luacac3-tdmahf-dese-tma-am1-luse2-contact-cu-nanomesh-hfse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-lu-hf-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-LuHfSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
