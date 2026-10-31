// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #337 (Cycle #336)
// Electronic-Grade Yb(MeCp)(COD) / Yb(acac)3 + TDMAEr + DESe + TMA
// 300mm AA1/Z1 YbSe2 Contact, Re Nanomesh Plasmonic Interconnect & ErSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Yb/Er/Se AA1 YbSe2 Contact + Re nanomesh + ErSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AA1 YbSe2/Re-nanomesh/ErSe-PCM PEALD cluster')
@allowed([
  'prod-aa1-ybse2-renanomesh-erse-pcm-sil3'
  'staging-ybse2-renanomesh-digital-twin'
])
param environment string = 'prod-aa1-ybse2-renanomesh-erse-pcm-sil3'

@description('Target 6N5 Yb(MeCp)(COD), Yb(acac)3, TDMAEr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target YbSe2/ErSe2 van der Waals contact spec')
param targetYbse2ContactSpec string = '21.5Ohm_um-pCFET-S0.99-VdWGap0.11nm'

@description('Target Re nanomesh plasmonic interconnect spec')
param targetReNanomeshPlasmonicSpec string = '208um-Lspp-0.008dB_um-RMS0.07nm-Re111'

@description('Target ErSe PCM spec (switch latency, Ron/Roff and energy)')
param targetErsePcmSpec string = '190ps-RonRoff7.4e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-ybmecp-ybse2-erse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ybse2erse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ybse2-erse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-YbMeCpCOD-Ybacac3-TDMAEr-DESe-TMA-AA1-YbSe2-ReNanomesh-ErSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetYbse2ContactSpec
    PlasmonicTarget: targetReNanomeshPlasmonicSpec
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
          'agent-infra/role': 'ybmecpcod-ybacac3-tdmaer-dese-tma-aa1-ybse2-contact-re-nanomesh-erse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-yb-er-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-YbErSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
