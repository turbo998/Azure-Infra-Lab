// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #371 (Cycle #370)
// Electronic-Grade W(MeCp)(COD) / W(acac)6 + TDMAMo + DESe + TMA
// 300mm BI1/BH1 WSe2 Contact, Mo Nanomesh Plasmonic Interconnect & MoSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 W/Mo/Se BI1 WSe2 Contact + Mo nanomesh + MoSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the BI1 WSe2/Mo-nanomesh/Mo-PCM PEALD cluster')
@allowed([
  'prod-bi1-wse2-monanomesh-mose-pcm-sil3'
  'staging-wse2-monanomesh-digital-twin'
])
param environment string = 'prod-bi1-wse2-monanomesh-mose-pcm-sil3'

@description('Target 6N5 W(MeCp)(COD), W(acac)6, TDMAMo, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target WSe2/MoSe2 van der Waals contact spec')
param targetWse2ContactSpec string = '13.3Ohm_um-pCFET-S0.99-VdWGap0.09nm'

@description('Target Mo nanomesh plasmonic interconnect spec')
param targetMoNanomeshPlasmonicSpec string = '276um-Lspp-0.005dB_um-RMS0.07nm-Mo100'

@description('Target MoSe PCM spec (switch latency, Ron/Roff and energy)')
param targetMosePcmSpec string = '86ps-RonRoff1.26e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-wmecp-wse2-mose-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-wse2mose-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-wse2-mose-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-WMeCpCOD-Wacac6-TDMAMo-DESe-TMA-BI1-WSe2-MoNanomesh-MoSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetWse2ContactSpec
    PlasmonicTarget: targetMoNanomeshPlasmonicSpec
    PcmTarget: targetMosePcmSpec
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
          'agent-infra/role': 'wmecpcod-wacac6-tdmamo-dese-tma-bi1-wse2-contact-mo-nanomesh-mose-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-w-mo-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-WMoSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
