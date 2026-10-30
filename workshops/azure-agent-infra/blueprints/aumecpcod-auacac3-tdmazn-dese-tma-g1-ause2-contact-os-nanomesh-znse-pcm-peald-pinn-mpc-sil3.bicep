// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #317 (Cycle #316)
// Electronic-Grade Au(MeCp)(COD) / Au(acac)3 + TDMAZn + DESe + TMA
// 300mm G1/F1 AuSe2 Contact, Os Nanomesh Plasmonic Interconnect & ZnSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Au/Zn/Se G1 AuSe2 Contact + Os nanomesh + ZnSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the G1 AuSe2/Os-nanomesh/ZnSe-PCM PEALD cluster')
@allowed([
  'prod-g1-ause2-osnanomesh-znse-pcm-sil3'
  'staging-ause2-osnanomesh-digital-twin'
])
param environment string = 'prod-g1-ause2-osnanomesh-znse-pcm-sil3'

@description('Target 6N5 Au(MeCp)(COD), Au(acac)3, TDMAZn, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target AuSe2/ZnSe2 van der Waals contact spec')
param targetAuse2ContactSpec string = '27.3Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Os nanomesh plasmonic interconnect spec')
param targetOsNanomeshPlasmonicSpec string = '166um-Lspp-0.022dB_um-RMS0.08nm-Os111'

@description('Target ZnSe PCM spec (switch latency, Ron/Roff and energy)')
param targetZnsePcmSpec string = '330ps-RonRoff3.4e8-0.05pJ_bit-6Bit'

var clusterName = 'aks-aumecp-ause2-znse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ause2znse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ause2-znse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-AuMeCpCOD-Auacac3-TDMAZn-DESe-TMA-G1-AuSe2-OsNanomesh-ZnSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetAuse2ContactSpec
    PlasmonicTarget: targetOsNanomeshPlasmonicSpec
    PcmTarget: targetZnsePcmSpec
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
          'agent-infra/role': 'aumecpcod-auacac3-tdmazn-dese-tma-g1-ause2-contact-os-nanomesh-znse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-au-zn-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-AuZnSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
