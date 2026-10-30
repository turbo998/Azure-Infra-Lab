// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #320 (Cycle #319)
// Electronic-Grade Ni(MeCp)(COD) / Ni(acac)2 + TDMAIn + DESe + TMA
// 300mm J1/I1 NiSe2 Contact, Rh Nanomesh Plasmonic Interconnect & InSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ni/In/Se J1 NiSe2 Contact + Rh nanomesh + InSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the J1 NiSe2/Rh-nanomesh/InSe-PCM PEALD cluster')
@allowed([
  'prod-j1-nise2-rhnanomesh-inse-pcm-sil3'
  'staging-nise2-rhnanomesh-digital-twin'
])
param environment string = 'prod-j1-nise2-rhnanomesh-inse-pcm-sil3'

@description('Target 6N5 Ni(MeCp)(COD), Ni(acac)2, TDMAIn, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target NiSe2/InSe2 van der Waals contact spec')
param targetNise2ContactSpec string = '26.5Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Rh nanomesh plasmonic interconnect spec')
param targetRhNanomeshPlasmonicSpec string = '174um-Lspp-0.019dB_um-RMS0.08nm-Rh111'

@description('Target InSe PCM spec (switch latency, Ron/Roff and energy)')
param targetInsePcmSpec string = '300ps-RonRoff4.0e8-0.03pJ_bit-6Bit'

var clusterName = 'aks-nimecp-nise2-inse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-nise2inse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-nise2-inse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-NiMeCpCOD-Niacac2-TDMAIn-DESe-TMA-J1-NiSe2-RhNanomesh-InSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetNise2ContactSpec
    PlasmonicTarget: targetRhNanomeshPlasmonicSpec
    PcmTarget: targetInsePcmSpec
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
          'agent-infra/role': 'nimecpcod-niacac2-tdmain-dese-tma-j1-nise2-contact-rh-nanomesh-inse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ni-in-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-NiInSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
