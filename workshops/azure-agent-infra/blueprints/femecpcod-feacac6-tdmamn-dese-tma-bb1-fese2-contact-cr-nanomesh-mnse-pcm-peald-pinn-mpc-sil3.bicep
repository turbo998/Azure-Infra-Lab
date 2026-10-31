// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #364 (Cycle #363)
// Electronic-Grade Fe(MeCp)(COD) / Fe(acac)6 + TDMAMn + DESe + TMA
// 300mm BB1/BA1 FeSe2 Contact, Cr Nanomesh Plasmonic Interconnect & MnSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Fe/Mn/Se BB1 FeSe2 Contact + Cr nanomesh + MnSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the BB1 FeSe2/Cr-nanomesh/MnSe-PCM PEALD cluster')
@allowed([
  'prod-bb1-fese2-crnanomesh-mnse-pcm-sil3'
  'staging-fese2-crnanomesh-digital-twin'
])
param environment string = 'prod-bb1-fese2-crnanomesh-mnse-pcm-sil3'

@description('Target 6N5 Fe(MeCp)(COD), Fe(acac)6, TDMAMn, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target FeSe2/MnSe2 van der Waals contact spec')
param targetFese2ContactSpec string = '14.7Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Cr nanomesh plasmonic interconnect spec')
param targetCrNanomeshPlasmonicSpec string = '262um-Lspp-0.005dB_um-RMS0.07nm-Cr110'

@description('Target MnSe PCM spec (switch latency, Ron/Roff and energy)')
param targetMnsePcmSpec string = '100ps-RonRoff1.19e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-femecp-fese2-mnse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-fese2mnse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-fese2-mnse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-FeMeCpCOD-Feacac6-TDMAMn-DESe-TMA-BB1-FeSe2-CrNanomesh-MnSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetFese2ContactSpec
    PlasmonicTarget: targetCrNanomeshPlasmonicSpec
    PcmTarget: targetMnsePcmSpec
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
          'agent-infra/role': 'femecpcod-feacac6-tdmamn-dese-tma-bb1-fese2-contact-cr-nanomesh-mnse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-fe-mn-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-FeMnSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
