// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #323 (Cycle #322)
// Electronic-Grade Mn(MeCp)(COD) / Mn(acac)2 + TDMATi + DESe + TMA
// 300mm M1/L1 MnSe2 Contact, Pt Nanomesh Plasmonic Interconnect & TiSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Mn/Ti/Se M1 MnSe2 Contact + Pt nanomesh + TiSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the M1 MnSe2/Pt-nanomesh/TiSe-PCM PEALD cluster')
@allowed([
  'prod-m1-mnse2-ptnanomesh-tise-pcm-sil3'
  'staging-mnse2-ptnanomesh-digital-twin'
])
param environment string = 'prod-m1-mnse2-ptnanomesh-tise-pcm-sil3'

@description('Target 6N5 Mn(MeCp)(COD), Mn(acac)2, TDMATi, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target MnSe2/TiSe2 van der Waals contact spec')
param targetMnse2ContactSpec string = '25.6Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Pt nanomesh plasmonic interconnect spec')
param targetPtNanomeshPlasmonicSpec string = '180um-Lspp-0.016dB_um-RMS0.08nm-Pt111'

@description('Target TiSe PCM spec (switch latency, Ron/Roff and energy)')
param targetTisePcmSpec string = '270ps-RonRoff4.6e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-mnmecp-mnse2-tise-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-mnse2tise-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-mnse2-tise-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-MnMeCpCOD-Mnacac2-TDMATi-DESe-TMA-M1-MnSe2-PtNanomesh-TiSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetMnse2ContactSpec
    PlasmonicTarget: targetPtNanomeshPlasmonicSpec
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
          'agent-infra/role': 'mnmecpcod-mnacac2-tdmati-dese-tma-m1-mnse2-contact-pt-nanomesh-tise-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-mn-ti-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-MnTiSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
