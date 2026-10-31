// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #356 (Cycle #355)
// Electronic-Grade Rh(MeCp)(COD) / Rh(acac)6 + TDMAIr + DESe + TMA
// 300mm AT1/AS1 RhSe2 Contact, Pt Nanomesh Plasmonic Interconnect & IrSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Rh/Ir/Se AT1 RhSe2 Contact + Pt nanomesh + IrSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the AT1 RhSe2/Pt-nanomesh/IrSe-PCM PEALD cluster')
@allowed([
  'prod-at1-rhse2-ptnanomesh-irse-pcm-sil3'
  'staging-rhse2-ptnanomesh-digital-twin'
])
param environment string = 'prod-at1-rhse2-ptnanomesh-irse-pcm-sil3'

@description('Target 6N5 Rh(MeCp)(COD), Rh(acac)6, TDMAIr, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/rare-earth metal impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target RhSe2/IrSe2 van der Waals contact spec')
param targetRhse2ContactSpec string = '16.3Ohm_um-pCFET-S0.99-VdWGap0.10nm'

@description('Target Pt nanomesh plasmonic interconnect spec')
param targetPtNanomeshPlasmonicSpec string = '246um-Lspp-0.007dB_um-RMS0.07nm-Pt111'

@description('Target IrSe PCM spec (switch latency, Ron/Roff and energy)')
param targetIrsePcmSpec string = '116ps-RonRoff1.11e9-0.02pJ_bit-6Bit'

var clusterName = 'aks-rhmecp-rhse2-irse-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-rhse2irse-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-rhse2-irse-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-RhMeCpCOD-Rhacac6-TDMAIr-DESe-TMA-AT1-RhSe2-PtNanomesh-IrSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetRhse2ContactSpec
    PlasmonicTarget: targetPtNanomeshPlasmonicSpec
    PcmTarget: targetIrsePcmSpec
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
          'agent-infra/role': 'rhmecpcod-rhacac6-tdmair-dese-tma-at1-rhse2-contact-pt-nanomesh-irse-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-rh-ir-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-RhIrSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
