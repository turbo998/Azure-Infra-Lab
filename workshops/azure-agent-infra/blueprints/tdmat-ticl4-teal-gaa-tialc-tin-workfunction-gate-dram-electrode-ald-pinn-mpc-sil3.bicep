// ============================================================================
// Blueprint #265 (265-Blueprint Milestone!): Electronic-Grade Tetrakis(dimethylamino)titanium
// (6N5 TDMAT Ti[N(CH3)2]4 >=99.99995%, Cl- <=0.05ppmw), Titanium Tetrachloride
// (6N5 TiCl4 >=99.99995%, VOCl3 <=0.05ppmw) & Triethylaluminum (6N5 TEAl Al(C2H5)3)
// 2nm GAA Dual-Work-Function Metal Gate (n-WF TiAlC 4.18eV & p-WF TiN 4.92eV) &
// 1c/1d DRAM HAR >75:1 TiN Capacitor Electrode ALD PINN-MPC & SIL-3 Interlock
// Cycle #264 · Chapter 269 · 265-Blueprint Milestone!
// ============================================================================

@description('Azure region for the Electronic-Grade 6N5 TDMAT / 6N5 TiCl4 / 6N5 TEAl 2nm GAA Dual-Work-Function Metal Gate & 1c DRAM TiN Electrode ALD control plane')
param location string = resourceGroup().location

@description('Environment prefix for 6N5 TDMAT & 6N5 TiCl4 + 6N5 TEAl GAA TiAlC/TiN Work-Function & DRAM Electrode ALD resources')
param envPrefix string = 'tdmat-ticl4-gaa-wf-sil3'

@description('AKS GPU node VM size for Wiped-Film Molecular Distillation, VOCl3 Vanadium Stripping & 2nm GAA TiAlC/TiN Work-Function ALD PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Target 6N5 TDMAT / 6N5 TiCl4 / 6N5 TEAl purity (%)')
param targetPrecursorPurityPct string = '99.99995'

@description('Maximum near-azeotropic VOCl3 vanadium impurity in 6N5 TiCl4 (ppmw) and Cl- halide in 6N5 TDMAT (ppmw)')
param maxVocl3AndHalidePpmw string = '0.05'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpcpool'
        count: 4
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'workload/domain': 'electronic-6n5-tdmat-6n5-ticl4-6n5-teal-2nm-gaa-tialc-tin-wf-dram-electrode-ald'
          'safety/standard': 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-PSM-IEC-61511-SIL3'
          'metrology/loop': '10kHz-QCL-TDLAS-FTIR-498-948-1035-1250cm1-GC-AED-HR-ICP-MS-SE-AR-XPS-KPFM'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
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
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

output clusterName string = aksCluster.name
output targetPurity string = targetPrecursorPurityPct
output maxVocl3AndHalideCapPpmw string = maxVocl3AndHalidePpmw
output safetyInterlockSpec string = 'SEMI S2 / SEMI C3 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 Corrosive Fuming TiCl4 Hydrolysis (TiO2 + 4HCl) & Pyrophoric TEAl/TDMAT Dual-Hazard 0.13ms Hard Interlock'
