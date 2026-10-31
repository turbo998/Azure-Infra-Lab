// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #331 (Cycle #330)
// Electronic-Grade La(MeCp)(COD) / La(acac)3 + TDMAPr + DESe + TMA
// 300mm U1/T1 LaSe2 Contact, Cu Nanomesh Plasmonic Interconnect & PrSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 La/Pr/Se U1 LaSe2 Contact + Cu nanomesh + PrSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the U1 LaSe2/Cu-nanomesh/PrSe-PCM PEALD cluster')
@allowed([
  'prod-u1-lase2-cunanomesh-prse-pcm-sil3'
  'staging-lase2-cunanomesh-digital-twin'
])
param environment string = 'prod-u1-lase2-cunanomesh-prse-pcm-sil3'

@description('Target 6N5 La(MeCp)(COD), La(acac)3, TDMAPr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target LaSe2/PrSe2 van der Waals contact spec')
param targetLase2ContactSpec string = '23.3Ohm_um-pCFET-S0.99-VdWGap0.12nm'

@description('Target Cu nanomesh plasmonic interconnect spec')
param targetCuNanomeshPlasmonicSpec string = '196um-Lspp-0.009dB_um-RMS0.07nm-Cu111'

@description('Target PrSe PCM spec (switch latency, Ron/Roff and energy)')
param targetPrsePcmSpec string = '220ps-RonRoff6.2e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-lamecp-lase2-prse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-lase2prse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-lase2-prse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-LaMeCpCOD-Laacac3-TDMAPr-DESe-TMA-U1-LaSe2-CuNanomesh-PrSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetLase2ContactSpec
    PlasmonicTarget: targetCuNanomeshPlasmonicSpec
    PcmTarget: targetPrsePcmSpec
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
          'agent-infra/role': 'lamecpcod-laacac3-tdmapr-dese-tma-u1-lase2-contact-cu-nanomesh-prse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-la-pr-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-LaPrSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
