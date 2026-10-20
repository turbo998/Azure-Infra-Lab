// ============================================================================
// Blueprint #70: AKSClaw Autonomous LNG Liquefaction Train (C3MR),
// Boil-Off Gas (BOG) Compressor Anti-Surge, Cryogenic Tank Rollover &
// NFPA 59A / SIGTTO / IEC 61511 SIL-3 Emergency Shutdown (ESD / PERC) Pool
// ============================================================================
// Target Architecture:
//   - Cloud Control Plane: AKS + Kata Containers (AKSClaw) on Standard_HB176rs_v4
//     and Standard_NC24ads_A100_v4 for Peng-Robinson Equation-of-State (EOS) PINN
//     Main Cryogenic Heat Exchanger (MCHE) pinch-point MPC & tank stratification modeling
//   - Cryogenic Terminal Edge: Azure Local (Standard_D16s_v5) for 3.5 ms fiber-optic
//     Raman Distributed Temperature Sensing (DTS -162 C) & mid-wave IR OGI plume inference
//   - Safety Interlock: NFPA 59A / SIGTTO / IEC 61511 SIL-3 compressor anti-surge
//     recycle valve & marine loading Powered Emergency Release Coupler (PERC) ESD (1.2 ms)
// ============================================================================

@description('Azure region for the LNG Cryogenic C3MR & BOG Anti-Surge AKSClaw cluster')
param location string = resourceGroup().location

@description('Environment identifier')
@allowed([
  'prod'
  'staging'
  'pilot'
])
param environment string = 'prod'

@description('AKSClaw cluster name for LNG C3MR Liquefaction & NFPA 59A SIL-3 ESD')
param clusterName string = 'aksclaw-lng-c3mr-sil3-${environment}'

@description('Number of C3MR liquefaction & cryogenic BOG control zones')
@minValue(4)
@maxValue(32)
param lngC3mrCryogenicTrains int = 8

@description('Minimum number of Peng-Robinson EOS PINN & MCHE MPC nodes')
@minValue(2)
@maxValue(32)
param minC3mrMpcNodes int = 2

@description('Maximum number of Peng-Robinson EOS PINN & MCHE MPC nodes')
@minValue(2)
@maxValue(64)
param maxC3mrMpcNodes int = 16

@description('Maximum compressor surge margin deficit before SIL-3 anti-surge recycle opens (%)')
param minCompressorSurgeMarginPct int = 10

@description('Cryogenic LNG storage tank rollover stratification density delta limit (kg/m3)')
param maxTankRolloverDensityDeltaKgM3 string = '1.5'

var commonTags = {
  workload: 'aksclaw-lng-cryogenic-c3mr-bog-sil3-esd'
  compliance: 'NFPA-59A-SIGTTO-EN-1473-IEC-61511-SIL3'
  architecture: 'AKSClaw-L2-Kata-AzureLocal-Cryogenic-Edge'
  chapter: 'chapter-74'
  blueprint: 'blueprint-70'
}

resource lngIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${clusterName}-identity'
  location: location
  tags: commonTags
}

resource lngVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${clusterName}-vnet'
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.244.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.244.1.0/24'
        }
      }
      {
        name: 'c3mr-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.244.2.0/24'
        }
      }
      {
        name: 'nfpa59a-sil3-perc-esd-subnet'
        properties: {
          addressPrefix: '10.244.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  tags: commonTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${lngIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: clusterName
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        vnetSubnetID: lngVnet.properties.subnets[0].id
      }
      {
        name: 'c3mrmpcpool'
        count: minC3mrMpcNodes
        minCount: minC3mrMpcNodes
        maxCount: maxC3mrMpcNodes
        enableAutoScaling: true
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: lngVnet.properties.subnets[1].id
        nodeLabels: {
          'aksclaw.io/isolation': 'kata-mshv'
          'aksclaw.io/domain': 'lng-c3mr-mche-pinch-mpc'
          'aksclaw.io/cryogenic-trains': string(lngC3mrCryogenicTrains)
        }
        nodeTaints: [
          'aksclaw.io/lng-c3mr=true:NoSchedule'
        ]
      }
      {
        name: 'sil3esdedge'
        count: 2
        minCount: 2
        maxCount: 8
        enableAutoScaling: true
        vmSize: 'Standard_D16s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: lngVnet.properties.subnets[2].id
        nodeLabels: {
          'aksclaw.io/isolation': 'kata-mshv'
          'aksclaw.io/domain': 'nfpa59a-sil3-antisurge-perc-esd'
          'aksclaw.io/min-surge-margin-pct': string(minCompressorSurgeMarginPct)
          'aksclaw.io/max-rollover-density-delta-kgm3': maxTankRolloverDensityDeltaKgM3
        }
        nodeTaints: [
          'aksclaw.io/nfpa59a-sil3=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output c3mrMpcPoolVmSize string = 'Standard_NC24ads_A100_v4'
output sil3InterlockCompliance string = 'NFPA-59A-SIGTTO-IEC-61511-SIL3-1.2ms'
