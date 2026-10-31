// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #350 (Cycle #349)
// Electronic-Grade Hf(MeCp)(COD) / Hf(acac)4 + TDMATa + DESe + TMA
// 300mm AN1/AM1 HfSe2 Contact, Ag Nanomesh Plasmonic Interconnect & TaSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Hf/Ta/Se AN1 HfSe2 Contact + Ag nanomesh + TaSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AN1 HfSe2/Ag-nanomesh/TaSe-PCM PEALD cluster')
@allowed([
  'prod-an1-hfse2-agnanomesh-tase-pcm-sil3'
  'staging-hfse2-agnanomesh-digital-twin'
])
param environment string = 'prod-an1-hfse2-agnanomesh-tase-pcm-sil3'

@description('Target 6N5 Hf(MeCp)(COD), Hf(acac)4, TDMATa, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target HfSe2/TaSe2 van der Waals contact spec')
param targetHfse2ContactSpec string = '17.6Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Ag nanomesh plasmonic interconnect spec')
param targetAgNanomeshPlasmonicSpec string = '234um-Lspp-0.008dB_um-RMS0.07nm-Ag111'

@description('Target TaSe PCM spec (switch latency, Ron/Roff and energy)')
param targetTasePcmSpec string = '136ps-RonRoff1.01e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-hfmecp-hfse2-tase-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-hfse2tase-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-hfse2-tase-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-HfMeCpCOD-Hfacac4-TDMATa-DESe-TMA-AN1-HfSe2-AgNanomesh-TaSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetHfse2ContactSpec
    PlasmonicTarget: targetAgNanomeshPlasmonicSpec
    PcmTarget: targetTasePcmSpec
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
          'agent-infra/role': 'hfmecpcod-hfacac4-tdmata-dese-tma-an1-hfse2-contact-ag-nanomesh-tase-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-hf-ta-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-HfTaSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
