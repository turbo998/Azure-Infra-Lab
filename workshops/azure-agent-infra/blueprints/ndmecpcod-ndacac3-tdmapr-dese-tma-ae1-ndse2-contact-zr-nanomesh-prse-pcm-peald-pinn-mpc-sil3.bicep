// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #341 (Cycle #340)
// Electronic-Grade Nd(MeCp)(COD) / Nd(acac)3 + TDMAPr + DESe + TMA
// 300mm AE1/AD1 NdSe2 Contact, Zr Nanomesh Plasmonic Interconnect & PrSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Nd/Pr/Se AE1 NdSe2 Contact + Zr nanomesh + PrSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AE1 NdSe2/Zr-nanomesh/PrSe-PCM PEALD cluster')
@allowed([
  'prod-ae1-ndse2-zrnanomesh-prse-pcm-sil3'
  'staging-ndse2-zrnanomesh-digital-twin'
])
param environment string = 'prod-ae1-ndse2-zrnanomesh-prse-pcm-sil3'

@description('Target 6N5 Nd(MeCp)(COD), Nd(acac)3, TDMAPr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target NdSe2/PrSe2 van der Waals contact spec')
param targetNdse2ContactSpec string = '20.3Ohm_um-pCFET-S0.99-VdWGap0.11nm'

@description('Target Zr nanomesh plasmonic interconnect spec')
param targetZrNanomeshPlasmonicSpec string = '216um-Lspp-0.008dB_um-RMS0.07nm-Zr111'

@description('Target PrSe PCM spec (switch latency, Ron/Roff and energy)')
param targetPrsePcmSpec string = '172ps-RonRoff8.3e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-ndmecp-ndse2-prse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ndse2prse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ndse2-prse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-NdMeCpCOD-Ndacac3-TDMAPr-DESe-TMA-AE1-NdSe2-ZrNanomesh-PrSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetNdse2ContactSpec
    PlasmonicTarget: targetZrNanomeshPlasmonicSpec
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
          'agent-infra/role': 'ndmecpcod-ndacac3-tdmapr-dese-tma-ae1-ndse2-contact-zr-nanomesh-prse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-nd-pr-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-NdPrSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
