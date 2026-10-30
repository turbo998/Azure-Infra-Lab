// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #314 (Cycle #313)
// Electronic-Grade Re(MeCp)(COD) / Re(acac)3 + TDMASn + DESe + TMA
// 300mm D1/C1 ReSe2 Contact, Pt Nanomesh Plasmonic Interconnect & SnSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Re/Sn/Se D1 ReSe2 Contact + Pt nanomesh + SnSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the D1 ReSe2/Pt-nanomesh/SnSe-PCM PEALD cluster')
@allowed([
  'prod-d1-rese2-ptnanomesh-snse-pcm-sil3'
  'staging-rese2-ptnanomesh-digital-twin'
])
param environment string = 'prod-d1-rese2-ptnanomesh-snse-pcm-sil3'

@description('Target 6N5 Re(MeCp)(COD), Re(acac)3, TDMASn, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target ReSe2/SnSe2 van der Waals contact spec')
param targetRese2ContactSpec string = '28.2Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Pt nanomesh plasmonic interconnect spec')
param targetPtNanomeshPlasmonicSpec string = '157um-Lspp-0.025dB_um-RMS0.08nm-Pt111'

@description('Target SnSe PCM spec (switch latency, Ron/Roff and energy)')
param targetSnsePcmSpec string = '390ps-RonRoff2.8e8-0.08pJ_bit-6Bit'

var clusterName = 'aks-remecp-rese2-snse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-rese2snse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-rese2-snse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-ReMeCpCOD-Reacac3-TDMASn-DESe-TMA-D1-ReSe2-PtNanomesh-SnSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetRese2ContactSpec
    PlasmonicTarget: targetPtNanomeshPlasmonicSpec
    PcmTarget: targetSnsePcmSpec
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
          'agent-infra/role': 'remecpcod-reacac3-tdmasn-dese-tma-d1-rese2-contact-pt-nanomesh-snse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-re-sn-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-ReSnSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
