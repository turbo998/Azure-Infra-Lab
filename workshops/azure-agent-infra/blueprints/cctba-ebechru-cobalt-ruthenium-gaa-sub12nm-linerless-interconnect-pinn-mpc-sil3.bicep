// =============================================================================
// Blueprint #262 (Cycle #261 · 270-Test Milestone! — Chapter 266 + Summary 267)
// Electronic-Grade 6N5 Cobalt Carbonyl (CCTBA Co2(CO)6(HC≡CtBu) / Co(AMD)2) &
// 6N5 Ruthenium Precursor (EBECHRu (η6-C6H4Et2)Ru(η4-C6H8) / Ru3(CO)12)
// Sublimation/Distillation Purification, 2nm GAA Sub-12nm M0/M1 Pitch Linerless
// Ruthenium Trench Metallization & Selective Cobalt EM-Capping CVD/ALD PINN-MPC,
// and SEMI S2 / NFPA 704 / OSHA 1910.119 SIL-3 Toxic Carbonyl & CO Interlock
// =============================================================================

@description('Azure region for the Edge-Cloud Hybrid PINN-MPC + SIL-3 Semiconductor Interconnect Metallization Control Plane')
param location string = resourceGroup().location

@description('Environment prefix for 6N5 CCTBA / 6N5 EBECHRu & Sub-12nm GAA Ru/Co Interconnect Metallization resources')
param environmentPrefix string = 'cctbaebechru261'

@description('Target 6N5 CCTBA & 6N5 EBECHRu trace Fe/Ni/Cu/Na/Cl impurity ceiling (pptw)')
param maxTraceMetalHalideImpurityPptw int = 25

@description('Maximum SEMI S2 / NFPA 704 / OSHA PSM SIL-3 toxic carbonyl & CO ampoule decomposition lockout latency (microseconds)')
param maxSil3CarbonylLockoutLatencyUs int = 130

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aksclaw-sil3'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-aks'
    agentPoolProfiles: [
      {
        name: 'pinnmpcpool'
        count: 3
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'System'
        osType: 'Linux'
        nodeLabels: {
          'workload.azure.ai/domain': 'cctba-ebechru-cobalt-ruthenium-sub12nm-interconnect-pinn-mpc'
          'safety.iec61511/sil-rating': 'SIL-3'
          'semiconductor.semi-s2/interconnect': '6N5-CCTBA-6N5-EBECHRu-Sub12nm-M0-M1-Ru-Co-Metallization'
        }
      }
    ]
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${environmentPrefix}-iothub-sil3'
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1M'
    }
  }
}

output blueprintId string = 'blueprint-262-cctba-ebechru-cobalt-ruthenium-gaa-sub12nm-linerless-interconnect-pinn-mpc-sil3'
output targetImpurityCeilingPptw int = maxTraceMetalHalideImpurityPptw
output targetSil3LockoutLatencyUs int = maxSil3CarbonylLockoutLatencyUs
output aksClusterId string = aksCluster.id
output iotHubId string = iotHub.id
