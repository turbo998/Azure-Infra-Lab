// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #355 (Cycle #354)
// Electronic-Grade Os(MeCp)(COD) / Os(acac)6 + TDMARh + DESe + TMA
// 300mm AS1/AR1 OsSe2 Contact, Ir Nanomesh Plasmonic Interconnect & RhSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Os/Rh/Se AS1 OsSe2 Contact + Ir nanomesh + RhSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AS1 OsSe2/Ir-nanomesh/RhSe-PCM PEALD cluster')
@allowed([
  'prod-as1-osse2-irnanomesh-rhse-pcm-sil3'
  'staging-osse2-irnanomesh-digital-twin'
])
param environment string = 'prod-as1-osse2-irnanomesh-rhse-pcm-sil3'

@description('Target 6N5 Os(MeCp)(COD), Os(acac)6, TDMARh, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target OsSe2/RhSe2 van der Waals contact spec')
param targetOsse2ContactSpec string = '16.5Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Ir nanomesh plasmonic interconnect spec')
param targetIrNanomeshPlasmonicSpec string = '244um-Lspp-0.007dB_um-RMS0.07nm-Ir111'

@description('Target RhSe PCM spec (switch latency, Ron/Roff and energy)')
param targetRhsePcmSpec string = '118ps-RonRoff1.10e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-osmecp-osse2-rhse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-osse2rhse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-osse2-rhse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-OsMeCpCOD-Osacac6-TDMARh-DESe-TMA-AS1-OsSe2-IrNanomesh-RhSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetOsse2ContactSpec
    PlasmonicTarget: targetIrNanomeshPlasmonicSpec
    PcmTarget: targetRhsePcmSpec
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
          'agent-infra/role': 'osmecpcod-osacac6-tdmarh-dese-tma-as1-osse2-contact-ir-nanomesh-rhse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-os-rh-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-OsRhSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
