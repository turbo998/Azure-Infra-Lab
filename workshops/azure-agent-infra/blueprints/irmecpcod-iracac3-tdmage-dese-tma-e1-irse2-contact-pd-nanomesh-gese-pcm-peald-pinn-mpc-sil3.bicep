// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #315 (Cycle #314)
// Electronic-Grade Ir(MeCp)(COD) / Ir(acac)3 + TDMAGe + DESe + TMA
// 300mm E1/D1 IrSe2 Contact, Pd Nanomesh Plasmonic Interconnect & GeSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ir/Ge/Se E1 IrSe2 Contact + Pd nanomesh + GeSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the E1 IrSe2/Pd-nanomesh/GeSe-PCM PEALD cluster')
@allowed([
  'prod-e1-irse2-pdnanomesh-gese-pcm-sil3'
  'staging-irse2-pdnanomesh-digital-twin'
])
param environment string = 'prod-e1-irse2-pdnanomesh-gese-pcm-sil3'

@description('Target 6N5 Ir(MeCp)(COD), Ir(acac)3, TDMAGe, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target IrSe2/GeSe2 van der Waals contact spec')
param targetIrse2ContactSpec string = '27.9Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Pd nanomesh plasmonic interconnect spec')
param targetPdNanomeshPlasmonicSpec string = '160um-Lspp-0.024dB_um-RMS0.08nm-Pd111'

@description('Target GeSe PCM spec (switch latency, Ron/Roff and energy)')
param targetGesePcmSpec string = '370ps-RonRoff3.0e8-0.07pJ_bit-6Bit'

var clusterName = 'aks-irmecp-irse2-gese-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-irse2gese-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-irse2-gese-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-IrMeCpCOD-Iracac3-TDMAGe-DESe-TMA-E1-IrSe2-PdNanomesh-GeSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetIrse2ContactSpec
    PlasmonicTarget: targetPdNanomeshPlasmonicSpec
    PcmTarget: targetGesePcmSpec
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
          'agent-infra/role': 'irmecpcod-iracac3-tdmage-dese-tma-e1-irse2-contact-pd-nanomesh-gese-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ir-ge-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-IrGeSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
