// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #346 (Cycle #345)
// Electronic-Grade Er(MeCp)(COD) / Er(acac)3 + TDMATm + DESe + TMA
// 300mm AJ1/AI1 ErSe2 Contact, Fe Nanomesh Plasmonic Interconnect & TmSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Er/Tm/Se AJ1 ErSe2 Contact + Fe nanomesh + TmSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AJ1 ErSe2/Fe-nanomesh/TmSe-PCM PEALD cluster')
@allowed([
  'prod-aj1-erse2-fenanomesh-tmse-pcm-sil3'
  'staging-erse2-fenanomesh-digital-twin'
])
param environment string = 'prod-aj1-erse2-fenanomesh-tmse-pcm-sil3'

@description('Target 6N5 Er(MeCp)(COD), Er(acac)3, TDMATm, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target ErSe2/TmSe2 van der Waals contact spec')
param targetErse2ContactSpec string = '18.8Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Fe nanomesh plasmonic interconnect spec')
param targetFeNanomeshPlasmonicSpec string = '226um-Lspp-0.008dB_um-RMS0.07nm-Fe110'

@description('Target TmSe PCM spec (switch latency, Ron/Roff and energy)')
param targetTmsePcmSpec string = '152ps-RonRoff9.3e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-ermecp-erse2-tmse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-erse2tmse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-erse2-tmse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-ErMeCpCOD-Eracac3-TDMATm-DESe-TMA-AJ1-ErSe2-FeNanomesh-TmSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetErse2ContactSpec
    PlasmonicTarget: targetFeNanomeshPlasmonicSpec
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
          'agent-infra/role': 'ermecpcod-eracac3-tdmatm-dese-tma-aj1-erse2-contact-fe-nanomesh-tmse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-er-tm-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-ErTmSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
