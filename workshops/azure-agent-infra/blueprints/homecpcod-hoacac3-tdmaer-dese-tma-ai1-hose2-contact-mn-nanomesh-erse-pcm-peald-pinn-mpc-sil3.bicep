// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #345 (Cycle #344)
// Electronic-Grade Ho(MeCp)(COD) / Ho(acac)3 + TDMAEr + DESe + TMA
// 300mm AI1/AH1 HoSe2 Contact, Mn Nanomesh Plasmonic Interconnect & ErSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ho/Er/Se AI1 HoSe2 Contact + Mn nanomesh + ErSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AI1 HoSe2/Mn-nanomesh/ErSe-PCM PEALD cluster')
@allowed([
  'prod-ai1-hose2-mnnanomesh-erse-pcm-sil3'
  'staging-hose2-mnnanomesh-digital-twin'
])
param environment string = 'prod-ai1-hose2-mnnanomesh-erse-pcm-sil3'

@description('Target 6N5 Ho(MeCp)(COD), Ho(acac)3, TDMAEr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target HoSe2/ErSe2 van der Waals contact spec')
param targetHose2ContactSpec string = '19.1Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Mn nanomesh plasmonic interconnect spec')
param targetMnNanomeshPlasmonicSpec string = '224um-Lspp-0.008dB_um-RMS0.07nm-Mn110'

@description('Target ErSe PCM spec (switch latency, Ron/Roff and energy)')
param targetErsePcmSpec string = '156ps-RonRoff9.1e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-homecp-hose2-erse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-hose2erse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-hose2-erse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-HoMeCpCOD-Hoacac3-TDMAEr-DESe-TMA-AI1-HoSe2-MnNanomesh-ErSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetHose2ContactSpec
    PlasmonicTarget: targetMnNanomeshPlasmonicSpec
    PcmTarget: targetErsePcmSpec
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
          'agent-infra/role': 'homecpcod-hoacac3-tdmaer-dese-tma-ai1-hose2-contact-mn-nanomesh-erse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ho-er-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-HoErSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
