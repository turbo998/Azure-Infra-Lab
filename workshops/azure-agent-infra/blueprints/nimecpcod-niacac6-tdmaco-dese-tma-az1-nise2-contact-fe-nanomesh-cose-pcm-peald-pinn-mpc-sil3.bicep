// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #362 (Cycle #361)
// Electronic-Grade Ni(MeCp)(COD) / Ni(acac)6 + TDMACo + DESe + TMA
// 300mm AZ1/AY1 NiSe2 Contact, Fe Nanomesh Plasmonic Interconnect & CoSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ni/Co/Se AZ1 NiSe2 Contact + Fe nanomesh + CoSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AZ1 NiSe2/Fe-nanomesh/CoSe-PCM PEALD cluster')
@allowed([
  'prod-az1-nise2-fenanomesh-cose-pcm-sil3'
  'staging-nise2-fenanomesh-digital-twin'
])
param environment string = 'prod-az1-nise2-fenanomesh-cose-pcm-sil3'

@description('Target 6N5 Ni(MeCp)(COD), Ni(acac)6, TDMACo, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target NiSe2/CoSe2 van der Waals contact spec')
param targetNise2ContactSpec string = '15.1Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Fe nanomesh plasmonic interconnect spec')
param targetFeNanomeshPlasmonicSpec string = '258um-Lspp-0.005dB_um-RMS0.07nm-Fe110'

@description('Target CoSe PCM spec (switch latency, Ron/Roff and energy)')
param targetCosePcmSpec string = '104ps-RonRoff1.17e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-nimecp-nise2-cose-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-nise2cose-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-nise2-cose-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-NiMeCpCOD-Niacac6-TDMACo-DESe-TMA-AZ1-NiSe2-FeNanomesh-CoSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetNise2ContactSpec
    PlasmonicTarget: targetFeNanomeshPlasmonicSpec
    PcmTarget: targetCosePcmSpec
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
          'agent-infra/role': 'nimecpcod-niacac6-tdmaco-dese-tma-az1-nise2-contact-fe-nanomesh-cose-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ni-co-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-NiCoSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
