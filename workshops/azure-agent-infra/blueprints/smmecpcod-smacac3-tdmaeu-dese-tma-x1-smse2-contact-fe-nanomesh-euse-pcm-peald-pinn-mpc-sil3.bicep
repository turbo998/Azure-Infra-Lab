// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #334 (Cycle #333)
// Electronic-Grade Sm(MeCp)(COD) / Sm(acac)3 + TDMAEu + DESe + TMA
// 300mm X1/W1 SmSe2 Contact, Fe Nanomesh Plasmonic Interconnect & EuSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Sm/Eu/Se X1 SmSe2 Contact + Fe nanomesh + EuSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the X1 SmSe2/Fe-nanomesh/EuSe-PCM PEALD cluster')
@allowed([
  'prod-x1-smse2-fenanomesh-euse-pcm-sil3'
  'staging-smse2-fenanomesh-digital-twin'
])
param environment string = 'prod-x1-smse2-fenanomesh-euse-pcm-sil3'

@description('Target 6N5 Sm(MeCp)(COD), Sm(acac)3, TDMAEu, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target SmSe2/EuSe2 van der Waals contact spec')
param targetSmse2ContactSpec string = '22.4Ohm_um-pCFET-S0.99-VdWGap0.11nm'

@description('Target Fe nanomesh plasmonic interconnect spec')
param targetFeNanomeshPlasmonicSpec string = '202um-Lspp-0.008dB_um-RMS0.07nm-Fe111'

@description('Target EuSe PCM spec (switch latency, Ron/Roff and energy)')
param targetEusePcmSpec string = '205ps-RonRoff6.8e8-0.02pJ_bit-6Bit'

var clusterName = 'aks-smmecp-smse2-euse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-smse2euse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-smse2-euse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-SmMeCpCOD-Smacac3-TDMAEu-DESe-TMA-X1-SmSe2-FeNanomesh-EuSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetSmse2ContactSpec
    PlasmonicTarget: targetFeNanomeshPlasmonicSpec
    PcmTarget: targetEusePcmSpec
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
          'agent-infra/role': 'smmecpcod-smacac3-tdmaeu-dese-tma-x1-smse2-contact-fe-nanomesh-euse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-sm-eu-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-SmEuSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
