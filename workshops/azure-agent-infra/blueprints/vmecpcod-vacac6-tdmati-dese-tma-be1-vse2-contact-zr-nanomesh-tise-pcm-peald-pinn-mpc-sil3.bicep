// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #367 (Cycle #366)
// Electronic-Grade V(MeCp)(COD) / V(acac)6 + TDMATi + DESe + TMA
// 300mm BE1/BD1 VSe2 Contact, Zr Nanomesh Plasmonic Interconnect & TiSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 V/Ti/Se BE1 VSe2 Contact + Zr nanomesh + TiSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the BE1 VSe2/Zr-nanomesh/TiSe-PCM PEALD cluster')
@allowed([
  'prod-be1-vse2-zrnanomesh-tise-pcm-sil3'
  'staging-vse2-zrnanomesh-digital-twin'
])
param environment string = 'prod-be1-vse2-zrnanomesh-tise-pcm-sil3'

@description('Target 6N5 V(MeCp)(COD), V(acac)6, TDMATi, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target VSe2/TiSe2 van der Waals contact spec')
param targetVse2ContactSpec string = '14.1Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Zr nanomesh plasmonic interconnect spec')
param targetZrNanomeshPlasmonicSpec string = '268um-Lspp-0.005dB_um-RMS0.07nm-Zr110'

@description('Target TiSe PCM spec (switch latency, Ron/Roff and energy)')
param targetTisePcmSpec string = '94ps-RonRoff1.22e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-vmecp-vse2-tise-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-vse2tise-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-vse2-tise-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-VMeCpCOD-Vacac6-TDMATi-DESe-TMA-BE1-VSe2-ZrNanomesh-TiSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetVse2ContactSpec
    PlasmonicTarget: targetZrNanomeshPlasmonicSpec
    PcmTarget: targetTisePcmSpec
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
          'agent-infra/role': 'vmecpcod-vacac6-tdmati-dese-tma-be1-vse2-contact-zr-nanomesh-tise-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-v-ti-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-VTiSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
