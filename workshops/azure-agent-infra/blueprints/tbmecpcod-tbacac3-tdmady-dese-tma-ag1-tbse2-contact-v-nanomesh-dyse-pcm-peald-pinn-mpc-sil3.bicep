// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #343 (Cycle #342)
// Electronic-Grade Tb(MeCp)(COD) / Tb(acac)3 + TDMADy + DESe + TMA
// 300mm AG1/AF1 TbSe2 Contact, V Nanomesh Plasmonic Interconnect & DySe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Tb/Dy/Se AG1 TbSe2 Contact + V nanomesh + DySe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AG1 TbSe2/V-nanomesh/DySe-PCM PEALD cluster')
@allowed([
  'prod-ag1-tbse2-vnanomesh-dyse-pcm-sil3'
  'staging-tbse2-vnanomesh-digital-twin'
])
param environment string = 'prod-ag1-tbse2-vnanomesh-dyse-pcm-sil3'

@description('Target 6N5 Tb(MeCp)(COD), Tb(acac)3, TDMADy, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target TbSe2/DySe2 van der Waals contact spec')
param targetTbse2ContactSpec string = '19.7Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target V nanomesh plasmonic interconnect spec')
param targetVNanomeshPlasmonicSpec string = '220um-Lspp-0.008dB_um-RMS0.07nm-V110'

@description('Target DySe PCM spec (switch latency, Ron/Roff and energy)')
param targetDysePcmSpec string = '164ps-RonRoff8.7e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-tbmecp-tbse2-dyse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-tbse2dyse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-tbse2-dyse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-TbMeCpCOD-Tbacac3-TDMADy-DESe-TMA-AG1-TbSe2-VNanomesh-DySe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetTbse2ContactSpec
    PlasmonicTarget: targetVNanomeshPlasmonicSpec
    PcmTarget: targetDysePcmSpec
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
          'agent-infra/role': 'tbmecpcod-tbacac3-tdmady-dese-tma-ag1-tbse2-contact-v-nanomesh-dyse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-tb-dy-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-TbDySe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
