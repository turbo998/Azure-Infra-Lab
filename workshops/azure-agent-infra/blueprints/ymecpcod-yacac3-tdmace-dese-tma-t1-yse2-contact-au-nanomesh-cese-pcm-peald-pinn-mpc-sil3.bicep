// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #330 (Cycle #329)
// Electronic-Grade Y(MeCp)(COD) / Y(acac)3 + TDMACe + DESe + TMA
// 300mm T1/S1 YSe2 Contact, Au Nanomesh Plasmonic Interconnect & CeSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Y/Ce/Se T1 YSe2 Contact + Au nanomesh + CeSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the T1 YSe2/Au-nanomesh/CeSe-PCM PEALD cluster')
@allowed([
  'prod-t1-yse2-aunanomesh-cese-pcm-sil3'
  'staging-yse2-aunanomesh-digital-twin'
])
param environment string = 'prod-t1-yse2-aunanomesh-cese-pcm-sil3'

@description('Target 6N5 Y(MeCp)(COD), Y(acac)3, TDMACe, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target YSe2/CeSe2 van der Waals contact spec')
param targetYse2ContactSpec string = '23.6Ohm_um-pCFET-S0.99-VdWGap0.12nm'

@description('Target Au nanomesh plasmonic interconnect spec')
param targetAuNanomeshPlasmonicSpec string = '194um-Lspp-0.010dB_um-RMS0.07nm-Au111'

@description('Target CeSe PCM spec (switch latency, Ron/Roff and energy)')
param targetCesePcmSpec string = '225ps-RonRoff6.0e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-ymecp-yse2-cese-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-yse2cese-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-yse2-cese-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-YMeCpCOD-Yacac3-TDMACe-DESe-TMA-T1-YSe2-AuNanomesh-CeSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetYse2ContactSpec
    PlasmonicTarget: targetAuNanomeshPlasmonicSpec
    PcmTarget: targetCesePcmSpec
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
          'agent-infra/role': 'ymecpcod-yacac3-tdmace-dese-tma-t1-yse2-contact-au-nanomesh-cese-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-y-ce-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-YCeSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
