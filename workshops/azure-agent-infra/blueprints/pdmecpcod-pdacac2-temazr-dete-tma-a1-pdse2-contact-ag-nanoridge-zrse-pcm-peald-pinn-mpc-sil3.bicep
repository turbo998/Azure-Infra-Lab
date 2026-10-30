// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #310 (Cycle #309)
// Electronic-Grade Pd(MeCp)(COD) / Pd(acac)2 + TEMAZr + DETe + TMA
// 300mm A1/A0 PdSe2 Contact, Ag Nanoridge Plasmonic Interconnect & ZrSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Pd/Zr/Te A1 PdSe2 Contact + Ag nanoridge + ZrSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the A1 PdSe2/Ag-nanoridge/ZrSe-PCM PEALD cluster')
@allowed([
  'prod-a1-pdse2-agnanoridge-zrse-pcm-sil3'
  'staging-pdse2-agnanoridge-digital-twin'
])
param environment string = 'prod-a1-pdse2-agnanoridge-zrse-pcm-sil3'

@description('Target 6N5 Pd(MeCp)(COD), Pd(acac)2, TEMAZr, DETe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target PdSe2/WTe2 van der Waals contact spec')
param targetPdse2ContactSpec string = '29.9Ohm_um-pCFET-S0.99-VdWGap0.18nm'

@description('Target Ag nanoridge plasmonic interconnect spec')
param targetAgNanoridgePlasmonicSpec string = '142um-Lspp-0.029dB_um-RMS0.11nm-Ag111'

@description('Target ZrSe PCM spec (switch latency, Ron/Roff and energy)')
param targetZrsePcmSpec string = '480ps-RonRoff2.0e8-0.12pJ_bit-6Bit'

var clusterName = 'aks-pdmecp-pdse2-zrse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-pdse2zrse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-pdse2-zrse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-PdMeCpCOD-Pdacac2-TEMAZr-DETe-TMA-A1-PdSe2-AgNanoridge-ZrSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetPdse2ContactSpec
    PlasmonicTarget: targetAgNanoridgePlasmonicSpec
    PcmTarget: targetZrsePcmSpec
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
          'agent-infra/role': 'pdmecpcod-pdacac2-temazr-dete-tma-a1-pdse2-agnanoridge-zrse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-pd-zr-te-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-PdZrTe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
