// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #347 (Cycle #346)
// Electronic-Grade Tm(MeCp)(COD) / Tm(acac)3 + TDMAYb + DESe + TMA
// 300mm AK1/AJ1 TmSe2 Contact, Co Nanomesh Plasmonic Interconnect & YbSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Tm/Yb/Se AK1 TmSe2 Contact + Co nanomesh + YbSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AK1 TmSe2/Co-nanomesh/YbSe-PCM PEALD cluster')
@allowed([
  'prod-ak1-tmse2-conanomesh-ybse-pcm-sil3'
  'staging-tmse2-conanomesh-digital-twin'
])
param environment string = 'prod-ak1-tmse2-conanomesh-ybse-pcm-sil3'

@description('Target 6N5 Tm(MeCp)(COD), Tm(acac)3, TDMAYb, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target TmSe2/YbSe2 van der Waals contact spec')
param targetTmse2ContactSpec string = '18.5Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Co nanomesh plasmonic interconnect spec')
param targetCoNanomeshPlasmonicSpec string = '228um-Lspp-0.008dB_um-RMS0.07nm-Co110'

@description('Target YbSe PCM spec (switch latency, Ron/Roff and energy)')
param targetYbsePcmSpec string = '148ps-RonRoff9.5e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-tmmecp-tmse2-ybse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-tmse2ybse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-tmse2-ybse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-TmMeCpCOD-Tmacac3-TDMAYb-DESe-TMA-AK1-TmSe2-CoNanomesh-YbSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetTmse2ContactSpec
    PlasmonicTarget: targetCoNanomeshPlasmonicSpec
    PcmTarget: targetYbsePcmSpec
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
          'agent-infra/role': 'tmmecpcod-tmacac3-tdmayb-dese-tma-ak1-tmse2-contact-co-nanomesh-ybse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-tm-yb-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-TmYbSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
