// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #348 (Cycle #347)
// Electronic-Grade Yb(MeCp)(COD) / Yb(acac)3 + TDMALu + DESe + TMA
// 300mm AL1/AK1 YbSe2 Contact, Ni Nanomesh Plasmonic Interconnect & LuSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Yb/Lu/Se AL1 YbSe2 Contact + Ni nanomesh + LuSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AL1 YbSe2/Ni-nanomesh/LuSe-PCM PEALD cluster')
@allowed([
  'prod-al1-ybse2-ninanomesh-luse-pcm-sil3'
  'staging-ybse2-ninanomesh-digital-twin'
])
param environment string = 'prod-al1-ybse2-ninanomesh-luse-pcm-sil3'

@description('Target 6N5 Yb(MeCp)(COD), Yb(acac)3, TDMALu, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target YbSe2/LuSe2 van der Waals contact spec')
param targetYbse2ContactSpec string = '18.2Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Ni nanomesh plasmonic interconnect spec')
param targetNiNanomeshPlasmonicSpec string = '230um-Lspp-0.008dB_um-RMS0.07nm-Ni110'

@description('Target LuSe PCM spec (switch latency, Ron/Roff and energy)')
param targetLusePcmSpec string = '144ps-RonRoff9.7e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-ybmecp-ybse2-luse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ybse2luse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ybse2-luse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-YbMeCpCOD-Ybacac3-TDMALu-DESe-TMA-AL1-YbSe2-NiNanomesh-LuSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetYbse2ContactSpec
    PlasmonicTarget: targetNiNanomeshPlasmonicSpec
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
          'agent-infra/role': 'ybmecpcod-ybacac3-tdmalu-dese-tma-al1-ybse2-contact-ni-nanomesh-luse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-yb-lu-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-YbLuSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
