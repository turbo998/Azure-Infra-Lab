// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #306 (Cycle #305 — 305-Cycle & 305-Simulator Double Milestone!)
// Electronic-Grade Ultrapure Ag(hfac)(COD) / Ag(hfac)(PMe3) (6N5 >=99.99995%) &
// Pd(hfac)2 / Pd(allyl)(Cp) (6N5 >=99.99995%) + Te(dedtc)2 / iPr2Te (6N5 >=99.99995%) +
// TMA (6N5 >=99.99995%) 300mm A7/A5 2D PdTe2/WSe2 Type-II Dirac Semimetal VdW p-CFET Contact,
// Single-Crystal Ag(111) Plasmonic Waveguide & Ag/Ag2Te/HfO2 CBRAM PEALD/VDW-Epitaxy PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Ag(hfac)(COD) & Pd(hfac)2 + iPr2Te + TMA A7 PdTe2 Contact, Ag(111) Plasmonic & Ag2Te CBRAM control plane')
param location string = resourceGroup().location

@description('Environment tier for the 300mm A7/A5 2D PdTe2 VdW Contact, Ag(111) Plasmonic Waveguide & Ag2Te CBRAM PEALD/Epitaxy cluster')
@allowed([
  'prod-a7-pdte2-ag111-plasmonic-cbram-sil3'
  'staging-pdte2-ag111-digital-twin'
])
param environment string = 'prod-a7-pdte2-ag111-plasmonic-cbram-sil3'

@description('Target 6N5 Ag(hfac)(COD), Pd(hfac)2, iPr2Te & TMA purity fraction')
param targetPrecursorPurityPercent string = '99.99995'

@description('Maximum trace transition/alkali metal and actinide impurity ceiling (Cu, Au, Pd, Fe, Ni, Na, K, U, Th) in ppbw')
param maxTraceMetalImpurityPpbw string = '0.05'

@description('Maximum ultra-low alpha particle emission ceiling (counts/cm^2*hr) for sub-7nm CFET soft-error immunity')
param maxAlphaEmissionCountsPerCm2Hr string = '0.0001'

@description('Target 2D PdTe2/WSe2 van der Waals p-CFET specific contact resistance R_{c,p} (Ohm*um) and pinning factor S')
param targetPdte2ContactSpec string = '34.0Ohm_um-pCFET-S0.97-VdWGap0.19nm'

@description('Target single-crystal Ag(111) plasmonic waveguide SPP propagation length L_SPP (um) at 1310nm and RMS roughness (nm)')
param targetAg111PlasmonicSpec string = '148um-Lspp-0.028dB_um-RMS0.12nm-Ag111'

@description('Target Ag/Ag2Te/HfO2 conductive-bridge filamentary synapse (CBRAM) switching time (ps), Ron/Roff ratio, and energy (pJ/bit)')
param targetAg2teCbramSpec string = '650ps-RonRoff1.2e8-0.18pJ_bit-6Bit'

var clusterName = 'aks-aghfac-pdte2-ag111-cbram-${uniqueString(resourceGroup().id)}'
var keyVaultName = 'kv-agpdte-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-aghfac-pdte2-sil3-${uniqueString(resourceGroup().id)}'

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
    Workload: 'Electronic-Grade-6N5-AghfacCOD-Pdhfac2-iPr2Te-TMA-A7-PdTe2-Contact-Ag111-Plasmonic-Ag2Te-CBRAM-PEALD'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    PrecursorPurity: '${targetPrecursorPurityPercent}-6N5-TraceMetal-${maxTraceMetalImpurityPpbw}ppbw-Alpha-${maxAlphaEmissionCountsPerCm2Hr}'
    ContactTarget: targetPdte2ContactSpec
    PlasmonicTarget: targetAg111PlasmonicSpec
    CbramTarget: targetAg2teCbramSpec
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
          'agent-infra/role': 'aghfaccod-pdhfac2-ipr2te-tma-a7-pdte2-ag111-cbram-pinn-mpc'
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
          'agent-infra/role': 'semi-s2-nfpa704-osha-sil3-ipr2te-hfac-tma-interlock'
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
output sil3SafetyInterlockSpec string = 'SEMI-S2-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3-2oo3-0.10ms-iPr2Te-0.01ppmv-HF-0.2ppmv-AgPd-0.005mgm3-TMA-Pyrophoric-Lockout'
output metroSpec string = '10kHz-QCL-CRDS-SF-ICP-MS-InSitu-TLM-ARPES-KPFM-sSNOM-Plasmonic-Interferometry-and-CBRAM-Pulse-IV'
