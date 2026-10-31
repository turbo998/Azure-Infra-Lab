// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #332 (Cycle #331)
// Electronic-Grade Pr(MeCp)(COD) / Pr(acac)3 + TDMANd + DESe + TMA
// 300mm V1/U1 PrSe2 Contact, Ni Nanomesh Plasmonic Interconnect & NdSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Pr/Nd/Se V1 PrSe2 Contact + Ni nanomesh + NdSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the V1 PrSe2/Ni-nanomesh/NdSe-PCM PEALD cluster')
@allowed([
  'prod-v1-prse2-ninanomesh-ndse-pcm-sil3'
  'staging-prse2-ninanomesh-digital-twin'
])
param environment string = 'prod-v1-prse2-ninanomesh-ndse-pcm-sil3'

@description('Target 6N5 Pr(MeCp)(COD), Pr(acac)3, TDMANd, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target PrSe2/NdSe2 van der Waals contact spec')
param targetPrse2ContactSpec string = '23.0Ohm_um-pCFET-S0.99-VdWGap0.12nm'

@description('Target Ni nanomesh plasmonic interconnect spec')
param targetNiNanomeshPlasmonicSpec string = '198um-Lspp-0.009dB_um-RMS0.07nm-Ni111'

@description('Target NdSe PCM spec (switch latency, Ron/Roff and energy)')
param targetNdsePcmSpec string = '215ps-RonRoff6.4e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-prmecp-prse2-ndse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-prse2ndse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-prse2-ndse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-PrMeCpCOD-Pracac3-TDMANd-DESe-TMA-V1-PrSe2-NiNanomesh-NdSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetPrse2ContactSpec
    PlasmonicTarget: targetNiNanomeshPlasmonicSpec
    PcmTarget: targetNdsePcmSpec
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
          'agent-infra/role': 'prmecpcod-pracac3-tdmand-dese-tma-v1-prse2-contact-ni-nanomesh-ndse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-pr-nd-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-PrNdSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
