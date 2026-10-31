// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #335 (Cycle #334)
// Electronic-Grade Eu(MeCp)(COD) / Eu(acac)3 + TDMAGd + DESe + TMA
// 300mm Y1/X1 EuSe2 Contact, Ru Nanomesh Plasmonic Interconnect & GdSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Eu/Gd/Se Y1 EuSe2 Contact + Ru nanomesh + GdSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the Y1 EuSe2/Ru-nanomesh/GdSe-PCM PEALD cluster')
@allowed([
  'prod-y1-euse2-runanomesh-gdse-pcm-sil3'
  'staging-euse2-runanomesh-digital-twin'
])
param environment string = 'prod-y1-euse2-runanomesh-gdse-pcm-sil3'

@description('Target 6N5 Eu(MeCp)(COD), Eu(acac)3, TDMAGd, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target EuSe2/GdSe2 van der Waals contact spec')
param targetEuse2ContactSpec string = '22.1Ohm_um-pCFET-S0.99-VdWGap0.11nm'

@description('Target Ru nanomesh plasmonic interconnect spec')
param targetRuNanomeshPlasmonicSpec string = '204um-Lspp-0.008dB_um-RMS0.07nm-Ru111'

@description('Target GdSe PCM spec (switch latency, Ron/Roff and energy)')
param targetGdsePcmSpec string = '200ps-RonRoff7.0e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-eumecp-euse2-gdse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-euse2gdse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-euse2-gdse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-EuMeCpCOD-Euacac3-TDMAGd-DESe-TMA-Y1-EuSe2-RuNanomesh-GdSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetEuse2ContactSpec
    PlasmonicTarget: targetRuNanomeshPlasmonicSpec
    PcmTarget: targetGdsePcmSpec
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
          'agent-infra/role': 'eumecpcod-euacac3-tdmagd-dese-tma-y1-euse2-contact-ru-nanomesh-gdse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-eu-gd-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-EuGdSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
