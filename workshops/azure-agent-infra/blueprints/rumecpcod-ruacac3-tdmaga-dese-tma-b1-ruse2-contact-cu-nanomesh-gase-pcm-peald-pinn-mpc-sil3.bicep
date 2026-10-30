// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #312 (Cycle #311)
// Electronic-Grade Ru(MeCp)(COD) / Ru(acac)3 + TDMAGa + DESe + TMA
// 300mm B1/B0 RuSe2 Contact, Cu Nanomesh Plasmonic Interconnect & GaSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ru/Ga/Se B1 RuSe2 Contact + Cu nanomesh + GaSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the B1 RuSe2/Cu-nanomesh/GaSe-PCM PEALD cluster')
@allowed([
  'prod-b1-ruse2-cunanomesh-gase-pcm-sil3'
  'staging-ruse2-cunanomesh-digital-twin'
])
param environment string = 'prod-b1-ruse2-cunanomesh-gase-pcm-sil3'

@description('Target 6N5 Ru(MeCp)(COD), Ru(acac)3, TDMAGa, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target RuSe2/In2Se3 van der Waals contact spec')
param targetRuse2ContactSpec string = '28.9Ohm_um-pCFET-S0.99-VdWGap0.16nm'

@description('Target Cu nanomesh plasmonic interconnect spec')
param targetCuNanomeshPlasmonicSpec string = '151um-Lspp-0.027dB_um-RMS0.09nm-Cu111'

@description('Target GaSe PCM spec (switch latency, Ron/Roff and energy)')
param targetGasePcmSpec string = '430ps-RonRoff2.4e8-0.10pJ_bit-6Bit'

var clusterName = 'aks-rumecp-ruse2-gase-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ruse2gase-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ruse2-gase-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-RuMeCpCOD-Ruacac3-TDMAGa-DESe-TMA-B1-RuSe2-CuNanomesh-GaSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetRuse2ContactSpec
    PlasmonicTarget: targetCuNanomeshPlasmonicSpec
    PcmTarget: targetGasePcmSpec
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
          'agent-infra/role': 'rumecpcod-ruacac3-tdmaga-dese-tma-b1-ruse2-contact-cu-nanomesh-gase-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ru-ga-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-RuGaSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
