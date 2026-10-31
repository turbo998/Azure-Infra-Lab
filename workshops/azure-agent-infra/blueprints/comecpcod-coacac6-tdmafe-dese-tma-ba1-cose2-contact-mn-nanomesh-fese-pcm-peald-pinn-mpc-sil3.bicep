// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #363 (Cycle #362)
// Electronic-Grade Co(MeCp)(COD) / Co(acac)6 + TDMAFe + DESe + TMA
// 300mm BA1/AZ1 CoSe2 Contact, Mn Nanomesh Plasmonic Interconnect & FeSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Co/Fe/Se BA1 CoSe2 Contact + Mn nanomesh + FeSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the BA1 CoSe2/Mn-nanomesh/FeSe-PCM PEALD cluster')
@allowed([
  'prod-ba1-cose2-mnnanomesh-fese-pcm-sil3'
  'staging-cose2-mnnanomesh-digital-twin'
])
param environment string = 'prod-ba1-cose2-mnnanomesh-fese-pcm-sil3'

@description('Target 6N5 Co(MeCp)(COD), Co(acac)6, TDMAFe, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target CoSe2/FeSe2 van der Waals contact spec')
param targetCose2ContactSpec string = '14.9Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Mn nanomesh plasmonic interconnect spec')
param targetMnNanomeshPlasmonicSpec string = '260um-Lspp-0.005dB_um-RMS0.07nm-Mn111'

@description('Target FeSe PCM spec (switch latency, Ron/Roff and energy)')
param targetFesePcmSpec string = '102ps-RonRoff1.18e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-comecp-cose2-fese-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-cose2fese-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-cose2-fese-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-CoMeCpCOD-Coacac6-TDMAFe-DESe-TMA-BA1-CoSe2-MnNanomesh-FeSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetCose2ContactSpec
    PlasmonicTarget: targetMnNanomeshPlasmonicSpec
    PcmTarget: targetFesePcmSpec
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
          'agent-infra/role': 'comecpcod-coacac6-tdmafe-dese-tma-ba1-cose2-contact-mn-nanomesh-fese-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-co-fe-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-CoFeSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
