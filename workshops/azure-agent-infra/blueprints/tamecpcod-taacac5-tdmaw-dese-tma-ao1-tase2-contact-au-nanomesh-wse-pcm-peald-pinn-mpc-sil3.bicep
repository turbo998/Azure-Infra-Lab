// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #351 (Cycle #350)
// Electronic-Grade Ta(MeCp)(COD) / Ta(acac)5 + TDMAW + DESe + TMA
// 300mm AO1/AN1 TaSe2 Contact, Au Nanomesh Plasmonic Interconnect & WSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ta/W/Se AO1 TaSe2 Contact + Au nanomesh + WSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AO1 TaSe2/Au-nanomesh/WSe-PCM PEALD cluster')
@allowed([
  'prod-ao1-tase2-aunanomesh-wse-pcm-sil3'
  'staging-tase2-aunanomesh-digital-twin'
])
param environment string = 'prod-ao1-tase2-aunanomesh-wse-pcm-sil3'

@description('Target 6N5 Ta(MeCp)(COD), Ta(acac)5, TDMAW, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target TaSe2/WSe2 van der Waals contact spec')
param targetTase2ContactSpec string = '17.3Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Au nanomesh plasmonic interconnect spec')
param targetAuNanomeshPlasmonicSpec string = '236um-Lspp-0.008dB_um-RMS0.07nm-Au111'

@description('Target WSe PCM spec (switch latency, Ron/Roff and energy)')
param targetWsePcmSpec string = '132ps-RonRoff1.03e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-tamecp-tase2-wse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-tase2wse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-tase2-wse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-TaMeCpCOD-Taacac5-TDMAW-DESe-TMA-AO1-TaSe2-AuNanomesh-WSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetTase2ContactSpec
    PlasmonicTarget: targetAuNanomeshPlasmonicSpec
    PcmTarget: targetWsePcmSpec
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
          'agent-infra/role': 'tamecpcod-taacac5-tdmaw-dese-tma-ao1-tase2-contact-au-nanomesh-wse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ta-w-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-TaWSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
