// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #324 (Cycle #323)
// Electronic-Grade Cr(MeCp)(COD) / Cr(acac)3 + TEMAZr + DESe + TMA
// 300mm N1/M1 CrSe2 Contact, Rh Nanomesh Plasmonic Interconnect & ZrSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Cr/Zr/Se N1 CrSe2 Contact + Rh nanomesh + ZrSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the N1 CrSe2/Rh-nanomesh/ZrSe-PCM PEALD cluster')
@allowed([
  'prod-n1-crse2-rhnanomesh-zrse-pcm-sil3'
  'staging-crse2-rhnanomesh-digital-twin'
])
param environment string = 'prod-n1-crse2-rhnanomesh-zrse-pcm-sil3'

@description('Target 6N5 Cr(MeCp)(COD), Cr(acac)3, TEMAZr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target CrSe2/ZrSe2 van der Waals contact spec')
param targetCrse2ContactSpec string = '25.3Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Rh nanomesh plasmonic interconnect spec')
param targetRhNanomeshPlasmonicSpec string = '182um-Lspp-0.015dB_um-RMS0.08nm-Rh111'

@description('Target ZrSe PCM spec (switch latency, Ron/Roff and energy)')
param targetZrsePcmSpec string = '260ps-RonRoff4.8e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-crmecp-crse2-zrse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-crse2zrse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-crse2-zrse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-CrMeCpCOD-Cracac3-TEMAZr-DESe-TMA-N1-CrSe2-RhNanomesh-ZrSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetCrse2ContactSpec
    PlasmonicTarget: targetRhNanomeshPlasmonicSpec
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
          'agent-infra/role': 'crmecpcod-cracac3-temazr-dese-tma-n1-crse2-contact-rh-nanomesh-zrse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-cr-zr-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-CrZrSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
