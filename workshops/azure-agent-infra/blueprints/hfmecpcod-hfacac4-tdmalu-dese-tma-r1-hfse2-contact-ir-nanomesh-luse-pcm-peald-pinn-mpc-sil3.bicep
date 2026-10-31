// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #328 (Cycle #327)
// Electronic-Grade Hf(MeCp)(COD) / Hf(acac)4 + TDMALu + DESe + TMA
// 300mm R1/Q1 HfSe2 Contact, Ir Nanomesh Plasmonic Interconnect & LuSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Hf/Lu/Se R1 HfSe2 Contact + Ir nanomesh + LuSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the R1 HfSe2/Ir-nanomesh/LuSe-PCM PEALD cluster')
@allowed([
  'prod-r1-hfse2-irnanomesh-luse-pcm-sil3'
  'staging-hfse2-irnanomesh-digital-twin'
])
param environment string = 'prod-r1-hfse2-irnanomesh-luse-pcm-sil3'

@description('Target 6N5 Hf(MeCp)(COD), Hf(acac)4, TDMALu, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target HfSe2/LuSe2 van der Waals contact spec')
param targetHfse2ContactSpec string = '24.2Ohm_um-pCFET-S0.99-VdWGap0.13nm'

@description('Target Ir nanomesh plasmonic interconnect spec')
param targetIrNanomeshPlasmonicSpec string = '190um-Lspp-0.011dB_um-RMS0.08nm-Ir111'

@description('Target LuSe PCM spec (switch latency, Ron/Roff and energy)')
param targetLusePcmSpec string = '235ps-RonRoff5.6e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-hfmecp-hfse2-luse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-hfse2luse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-hfse2-luse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-HfMeCpCOD-Hfacac4-TDMALu-DESe-TMA-R1-HfSe2-IrNanomesh-LuSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetHfse2ContactSpec
    PlasmonicTarget: targetIrNanomeshPlasmonicSpec
    PcmTarget: targetLusePcmSpec
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
          'agent-infra/role': 'hfmecpcod-hfacac4-tdmalu-dese-tma-r1-hfse2-contact-ir-nanomesh-luse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-hf-lu-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-HfLuSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
