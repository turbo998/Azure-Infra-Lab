// =============================================================================
// Blueprint #258 (Cycle #257 · 265-Chapter Milestone!): Autonomous Electronic-Grade
// Boron Trichloride (6N BCl3 >=99.9999%, b.p. 12.6C, COCl2 <=0.15ppmv, SiCl4 <=0.15ppmv,
// HCl <=0.20ppmv, Cl2 <=0.20ppmv, Fe/Al/Cu <=0.05ppbv) & Chlorine (6N Cl2 >=99.9999%,
// b.p. -34.0C, H2O <=0.20ppmv, CO2 <=0.30ppmv, O2/N2 <=0.30ppmv) + Silicon Tetrachloride
// (6N SiCl4 >=99.9999%, b.p. 57.6C) 8-Inch 4H-SiC Trench Power MOSFET (Sub-Trenching-Free
// BCl3/Cl2/O2/SiCl4 Etch) & AlGaN/GaN HEMT Recessed-Gate Cyclic Atomic Layer Etch (ALE
// Self-Limiting Cl2 Chemisorption + <25eV Ar+/BClx+ Desorption, GaN:AlGaN >=45:1,
// 0.42nm/cycle) Carbothermal Chlorination, Phosgene Decomposition & Quartz Rectification
// PINN-MPC, 10kHz QCL-TDLAS/UV-DOAS/FTIR (956/995/1827cm-1 & 330nm Cl2) + GC-DID/ICP-MS
// + 271.4nm BCl* / 257.7nm AlCl* / 417.2nm Ga* OES & SEMI S2/SEMI C3/NFPA 55/OSHA PSM/
// ACGIH TLV/SIL-3 Violent Moisture Hydrolysis (BCl3+3H2O->H3BO3+3HCl), Trace Phosgene
// (COCl2 TLV 0.1ppmv) & Chlorine (Cl2 TLV 0.1ppmv) Scrubbing Hard Interlock
// =============================================================================

@description('Azure region for the Electronic-Grade 6N BCl3, 6N Cl2 & 6N SiCl4 4H-SiC Trench MOSFET & GaN HEMT ALE Etch sandbox')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param envPrefix string = 'bcl3cl2sicgan257'

@description('AKS GPU node VM size for Carbothermal Chlorination, Phosgene Removal & 4H-SiC/GaN ALE PINN-MPC')
param pinnGpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Maximum phosgene (COCl2) trace impurity threshold in ppmv before SIL-3 catalytic bed switchover')
param maxPhosgenePpmv string = '0.15'

@description('Maximum ambient Cl2 / HCl / COCl2 gas cabinet threshold in ppmv before 0.13ms SIL-3 2oo3 Hastelloy-C276 bellows isolation')
param maxCabinetToxicGasPpmv string = '0.05'

var aksClusterName = '${envPrefix}-aks-pinn-mpc'
var iotHubName = '${envPrefix}-iothub-10khz-tdlas-oes'
var storageAccountName = replace('${envPrefix}adls257', '-', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: take(storageAccountName, 24)
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
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

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
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
        name: 'pinnh100'
        count: 2
        vmSize: pinnGpuVmSize
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'bcl3-cl2-sicl4-sic-trench-gan-hemt-ale-pinn-mpc'
          'safety/interlock': 'semi-s2-nfpa55-osha-psm-bcl3-cocl2-cl2-sil3'
          'metrology/edge': '10khz-qcl-tdlas-956-995-1827cm1-uvdoas-330nm-oes-271nm'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

output aksClusterId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output safetyInterlockSpec object = {
  standard: 'SEMI S2 / SEMI C3 / NFPA 55 / OSHA PSM / ACGIH TLV / IEC 61511 SIL-3'
  maxPhosgenePpmv: maxPhosgenePpmv
  maxCabinetToxicGasPpmv: maxCabinetToxicGasPpmv
  edgeGateLatencyMs: '0.13'
  isolationAction: '2oo3 pneumatic Hastelloy-C276 bellows double-block-and-bleed isolation + heated dry 6N N2 purge (preventing BCl3 + 3H2O -> H3BO3 solid boric acid plugging) + NaOH/Na2S2O3 alkaline-reductive scrubber neutralizing Cl2, HCl, BCl3 and trace COCl2'
}
