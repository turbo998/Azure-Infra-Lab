// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #326 (Cycle #325)
// Electronic-Grade Nb(MeCp)(COD) / Nb(acac)3 + TDMASc + DESe + TMA
// 300mm P1/O1 NbSe2 Contact, Ru Nanomesh Plasmonic Interconnect & ScSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Nb/Sc/Se P1 NbSe2 Contact + Ru nanomesh + ScSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the P1 NbSe2/Ru-nanomesh/ScSe-PCM PEALD cluster')
@allowed([
  'prod-p1-nbse2-runanomesh-scse-pcm-sil3'
  'staging-nbse2-runanomesh-digital-twin'
])
param environment string = 'prod-p1-nbse2-runanomesh-scse-pcm-sil3'

@description('Target 6N5 Nb(MeCp)(COD), Nb(acac)3, TDMASc, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target NbSe2/ScSe2 van der Waals contact spec')
param targetNbse2ContactSpec string = '24.8Ohm_um-pCFET-S0.99-VdWGap0.14nm'

@description('Target Ru nanomesh plasmonic interconnect spec')
param targetRuNanomeshPlasmonicSpec string = '186um-Lspp-0.013dB_um-RMS0.08nm-Ru0001'

@description('Target ScSe PCM spec (switch latency, Ron/Roff and energy)')
param targetScsePcmSpec string = '245ps-RonRoff5.2e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-nbmecp-nbse2-scse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-nbse2scse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-nbse2-scse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-NbMeCpCOD-Nbacac3-TDMASc-DESe-TMA-P1-NbSe2-RuNanomesh-ScSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetNbse2ContactSpec
    PlasmonicTarget: targetRuNanomeshPlasmonicSpec
    PcmTarget: targetScsePcmSpec
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
          'agent-infra/role': 'nbmecpcod-nbacac3-tdmasc-dese-tma-p1-nbse2-contact-ru-nanomesh-scse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-nb-sc-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-NbScSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
