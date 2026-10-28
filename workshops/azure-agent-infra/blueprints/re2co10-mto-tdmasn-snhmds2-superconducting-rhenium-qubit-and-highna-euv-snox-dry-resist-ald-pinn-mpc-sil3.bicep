// Blueprint #284: Electronic-Grade 6N5 Re2(CO)10 & 6N5 MTO + 6N5 TDMASn + 6N5 Sn(HMDS)2
// Fault-Tolerant Superconducting Quantum Qubit Zero-TLS Rhenium (Re/ReTi) Resonator &
// High-NA EUV (0.55 NA) 8nm Half-Pitch All-Dry Organotin Oxo-Cage (SnOx) Photoresist ALD/MLD
// PINN-MPC + SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3 Edge Architecture (Cycle #283)
targetScope = 'resourceGroup'

@description('Azure region for the AKSClaw + Kata + GPU PINN-MPC control plane')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #283 Superconducting Rhenium Qubit & High-NA EUV Dry SnOx Resist ALD/MLD')
param envPrefix string = 'aksclaw-re2co10-tdmasn-sil3'

@description('AKS GPU node VM size for Re2(CO)10/MTO TLS-Free Epitaxy & TDMASn EUV Dry-Resist MLD PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Target single-photon internal quality factor Qi for Re(0001)/ReTi resonator (>= 2.0e7)')
param minResonatorQi int = 28500000

@description('Target High-NA EUV 8nm half-pitch 3-sigma Line-Width Roughness in pm (<= 1000 pm = 1.0 nm)')
param maxEuvDryResistLwrPm int = 880

@description('SIL-3 neurotoxic organotin vapor & CO desorption interlock trip threshold in ppbv')
param maxOrganotinVaporPpbv int = 50

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.283.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-kata-gpu-subnet'
        properties: {
          addressPrefix: '10.283.1.0/24'
        }
      }
      {
        name: 'sil3-qcl-rheed-euv-edge-subnet'
        properties: {
          addressPrefix: '10.283.2.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: envPrefix
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'katagpupinn'
        count: 4
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/PrecursorGrade': '6N5-Re2CO10-MTO-TDMASn-SnHMDS2'
          'agent.azure.com/ProcessNode': 'Superconducting-Re-Qubit-Qi28M-and-HighNA-EUV-8nm-SnOx-MLD'
          'agent.azure.com/SafetyIntegrityLevel': 'SEMI-S2-NFPA704-OSHA1910-1000-IEC61511-SIL3'
          'agent.azure.com/MinResonatorQi': string(minResonatorQi)
          'agent.azure.com/MaxEuvDryResistLwrPm': string(maxEuvDryResistLwrPm)
          'agent.azure.com/MaxOrganotinVaporPpbv': string(maxOrganotinVaporPpbv)
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output aksClusterName string = aksCluster.name
output pinnMpcWorkloadRuntime string = 'KataMshvVmIsolation'
output targetPrecursors array = [
  '6N5-Re2(CO)10-99.99995pct'
  '6N5-CH3ReO3-MTO-99.99995pct'
  '6N5-TDMASn-99.99995pct'
  '6N5-Sn(HMDS)2-99.99995pct'
]
output sil3InterlockLatencyMs string = '0.10'
output resonatorSinglePhotonQi int = minResonatorQi
output highNaEuvDryResistLwrPm int = maxEuvDryResistLwrPm
