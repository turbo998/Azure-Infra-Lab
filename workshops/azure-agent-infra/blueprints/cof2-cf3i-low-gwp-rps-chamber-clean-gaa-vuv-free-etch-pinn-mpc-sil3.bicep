// blueprints/cof2-cf3i-low-gwp-rps-chamber-clean-gaa-vuv-free-etch-pinn-mpc-sil3.bicep
// Cycle #245 (245-Cycle & 245-Simulator Milestone!): Electronic-Grade Carbonyl Fluoride (5N COF2 >=99.999%, GWP100 ~1.0) & Trifluoroiodomethane (5N CF3I >=99.999%, GWP100 <0.4) + 20% F2/N2 Ultra-Low-GWP RPS PECVD/ALD Chamber Cleaning & 2nm GAA Low-UV-Damage Selective Etch PINN-MPC + SIL-3 Interlock

param location string = resourceGroup().location
param environmentName string = 'prod-cof2-cf3i-lowgwp-sil3'
param aksNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-${environmentName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: environmentName
    agentPoolProfiles: [
      {
        name: 'h100pinn'
        count: aksNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        osType: 'Linux'
        mode: 'System'
        nodeLabels: {
          'workload/type': 'cof2-cf3i-low-gwp-rps-chamber-clean-gaa-vuv-free-etch-pinn-mpc'
          'safety/interlock': 'semi-s2-semi-c3-nfpa55-osha-pel-sil3-cof2-hydrolysis-and-cf3i-iodine-plugging-lockout'
          'metrology/edge': '10khz-qcl-tdlas-1928cm1-1075cm1-1827cm1-4100cm1-oes-uvvis-edge'
        }
      }
    ]
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: 'iothub-${environmentName}'
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
  }
}

output clusterName string = aksCluster.name
output safetyProtocol string = 'SEMI-S2-SEMI-C3-NFPA55-OSHA-PEL-IEC61511-SIL3-COF2-FluoroPhosgene-Scrubbing-And-CF3I-Iodine-Lockout'
