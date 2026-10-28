// blueprints/dezn-dmzn-tmin-tbas-tbp-inp-eml-cpo-laser-igzo-m3d-mocvd-ald-pinn-mpc-sil3.bicep
// Cycle #271 (280-Test Milestone! — Chapter 276 + Summary 277 = 279 Chapters, Blueprint #272, Simulator #271, Tool 271):
// Electronic-Grade Ultrapure Diethylzinc (6N5 DEZn >= 99.99995%, EtZnOEt <= 0.03 ppmw, Cd/Pb/Fe/Cu <= 0.01 ppbw)
// & Dimethylzinc (6N5 DMZn >= 99.99995%) + Trimethylindium (6N5 TMIn >= 99.99995%) + Tertiarybutylarsine (6N5 TBAs)
// & Tertiarybutylphosphine (6N5 TBP) 1.6T / 3.2T Co-Packaged Optics (CPO) Silicon Photonics Heterogeneous InP EML / DFB
// Quantum-Well Laser p-Cladding Dopant Diffusion Barrier & BEOL Monolithic 3D (M3D) Amorphous InGaZnO4 (a-IGZO 2T0C DRAM)
// MOCVD / Super-Cycle PEALD PINN-MPC & SEMI S2 / NFPA 704 / OSHA 1910.119 SIL-3 Dual-Plane Architecture

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 6N5 DEZn & 6N5 DMZn + 6N5 TMIn + 6N5 TBAs/TBP 1.6T/3.2T CPO InP EML Laser & BEOL M3D a-IGZO MOCVD/PEALD edge-cloud deployment')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #271 resources')
param environmentPrefix string = 'dezndmzncpoigzo271'

@description('AKS node count for PINN-MPC Frank-Turnbull / Kick-Out Zn diffusion and super-cycle a-IGZO PEALD inference')
param aksAgentCount int = 3

var aksClusterName = '${environmentPrefix}-aks-sil3'
var iotHubName = '${environmentPrefix}-iothub-mocvdald'
var eventHubNamespaceName = '${environmentPrefix}-ehns-telemetry'
var adxClusterName = '${environmentPrefix}adx'
var adxDatabaseName = 'DeznDmznTminTbasTbpInpCpoLaserAndIgzoM3dTelemetryDb'
var keyVaultName = '${environmentPrefix}-kv-s2'

// 1. Azure IoT Hub for UV-EPISON (213.9 nm Zn I / 451.1 nm In I), QCL-TDLAS (AsH3 / PH3 / TBAs / TBP), and LayTec EpiTT + Spectroscopic Ellipsometry
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 8
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

// 2. Azure Event Hubs Namespace for sub-millisecond MOCVD & Super-Cycle PEALD telemetry streaming
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 12
    minimumTlsVersion: '1.2'
  }
}

resource mocvdAldTelemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'dezn-dmzn-tmin-tbas-tbp-cpo-eml-igzo-telemetry'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 8
  }
}

// 3. Azure Data Explorer (Kusto) for Frank-Turnbull / Kick-Out Zn interstitial diffusion and 2T0C a-IGZO Vth / Ioff digital twin logs
resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_D13_v2'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: false
  }
}

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: adxDatabaseName
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
}

// 4. Azure Key Vault for SEMI S2 / NFPA 704 Class 4 Pyrophoric DEZn/DMZn & Class 1 Toxic Hydride TBAs/TBP/AsH3/PH3 SIL-3 cryptographic signing keys
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}

// 5. AKS Cluster hosting AKSClaw Control Plane + E2B Firecracker PINN-MPC Frank-Turnbull/Kick-Out Zn Diffusion & Super-Cycle a-IGZO Sandboxes
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'controlpool'
        count: aksAgentCount
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 1
        maxCount: 4
        nodeLabels: {
          'workload-type': 'dezn-dmzn-tmin-tbas-tbp-inp-eml-cpo-laser-igzo-m3d-pinn-mpc'
          'safety-plane': 'semi-s2-nfpa704-osha-psm-sil3-isolated'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
    }
  }
}

output aksClusterId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output adxClusterUri string = adxCluster.properties.uri
output safetyStandard string = 'SEMI-S2-S8-NFPA704-Class4-Pyrophoric-DEZn-DMZn-TMIn-OSHA-PSM-1910.119-TBAs-TBP-AsH3-PH3-IEC61511-SIL3'
