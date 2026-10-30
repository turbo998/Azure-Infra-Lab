// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #316 (Cycle #315)
// Electronic-Grade Pt(MeCp)(COD) / Pt(acac)2 + TDMASi + DESe + TMA
// 300mm F1/E1 PtSe2 Contact, Rh Nanomesh Plasmonic Interconnect & SiSe PCM
// PEALD PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Pt/Si/Se F1 PtSe2 Contact + Rh nanomesh + SiSe PCM control plane')
param location string = resourceGroup().location

@description('Environment tier for the F1 PtSe2/Rh-nanomesh/SiSe-PCM PEALD cluster')
@allowed([
  'prod-f1-ptse2-rhnanomesh-sise-pcm-sil3'
  'staging-ptse2-rhnanomesh-digital-twin'
])
param environment string = 'prod-f1-ptse2-rhnanomesh-sise-pcm-sil3'

@description('Target 6N5 Pt(MeCp)(COD), Pt(acac)2, TDMASi, DESe and TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for advanced-node soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target PtSe2/SiSe2 van der Waals contact spec')
param targetPtse2ContactSpec string = '27.6Ohm_um-pCFET-S0.99-VdWGap0.15nm'

@description('Target Rh nanomesh plasmonic interconnect spec')
param targetRhNanomeshPlasmonicSpec string = '163um-Lspp-0.023dB_um-RMS0.08nm-Rh111'

@description('Target SiSe PCM spec (switch latency, Ron/Roff and energy)')
param targetSisePcmSpec string = '350ps-RonRoff3.2e8-0.06pJ_bit-6Bit'

var clusterName = 'aks-ptmecp-ptse2-sise-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-ptse2sise-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-ptse2-sise-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-PtMeCpCOD-Ptacac2-TDMASi-DESe-TMA-F1-PtSe2-RhNanomesh-SiSe-PCM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetPtse2ContactSpec
    PlasmonicTarget: targetRhNanomeshPlasmonicSpec
    PcmTarget: targetSisePcmSpec
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
          'agent-infra/role': 'ptmecpcod-ptacac2-tdmasi-dese-tma-f1-ptse2-contact-rh-nanomesh-sise-pcm-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-pt-si-se-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-PtSiSe-TMA-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-XPS-TLM-ARPES-sSNOM-Plasmonic-and-PCM-Pulse-IV'
