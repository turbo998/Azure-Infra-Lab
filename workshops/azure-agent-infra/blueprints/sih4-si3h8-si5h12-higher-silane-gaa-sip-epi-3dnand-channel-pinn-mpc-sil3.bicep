// =============================================================================
// Blueprint #261 (Cycle #260 · 260-Cycle & 260-Simulator Milestone!):
// Autonomous Electronic-Grade Monosilane (7N SiH4 >= 99.99999%, b.p. -111.9C,
// Spontaneously Pyrophoric in Air >=1.4%, TLV-TWA 5 ppmv, Ultra-Low Chlorosilanes
// SiH3Cl/SiH2Cl2 <=0.05 ppbv, Disiloxane H3SiOSiH3 <=0.10 ppbv, B/P/As <=0.01 ppbv),
// Electronic-Grade Trisilane (5N5 Si3H8 >= 99.9995%, Silcore, b.p. +52.9C,
// Pyrophoric Liquid Precursor, Si4H10 <=5.0 ppmv, Siloxanes <=0.20 ppmv) &
// Electronic-Grade Neopentasilane (5N Si5H12 >= 99.999%, Branched Si(SiH3)4,
// b.p. +133C, Zero-Incubation Seedless Gap-Fill) 2nm GAA Nanosheet Ultra-Low-Temp
// (<420C) Selective n+ Si:P / SiCP Source/Drain Epitaxy & 300+ Layer 3D NAND
// High-Mobility Poly-Si Macaroni Channel (HAR > 100:1) CVD PINN-MPC, Online 10 kHz
// QCL-TDLAS / FTIR (2189 cm-1 SiH4 nu3 / 2155 cm-1 Si3H8 Si-H / 1107 cm-1 Si-O-Si
// Disiloxane / 845 cm-1 SiH2 Bending) + GC-MS/PDD + In-Situ Spectroscopic Ellipsometry
// / Laser Light Scattering & SEMI S2 / SEMI C3 / NFPA 55 / NFPA 318 / OSHA PSM /
// IEC 61511 SIL-3 Pyrophoric Silane/Trisilane Delayed-Ignition Overpressure
// Detonation & Polysilane (SixHy) Yellow-Powder Exhaust Autoignition Hard Interlock
// =============================================================================

@description('Azure region for the Electronic-Grade 7N SiH4, 5N5 Si3H8 (Trisilane) & 5N Si5H12 (Neopentasilane) 2nm GAA Si:P Epitaxy & 3D NAND Poly-Si Channel CVD PINN-MPC + SIL-3 digital twin')
param location string = resourceGroup().location

@description('Environment name (prod-fab, pilot-epi, sil3-certification)')
@allowed([
  'prod-fab'
  'pilot-epi'
  'sil3-certification'
])
param environment string = 'prod-fab'

@description('Number of parallel 7N SiH4 / 5N5 Si3H8 / 5N Si5H12 purification & 2nm GAA Si:P / 3D NAND Poly-Si channel CVD trains (1-64)')
@minValue(1)
@maxValue(64)
param sih4Si3h8Si5h12Trains int = 8

@description('Maximum SEMI S2 / NFPA 55 / NFPA 318 / OSHA PSM / IEC 61511 SIL-3 pyrophoric silane/trisilane delayed-ignition & SixHy yellow-powder autoignition lockout latency in milliseconds (<= 0.15 ms)')
param maxSil3LockoutLatencyMs string = '0.13'

@description('Target 10 kHz QCL-TDLAS / FTIR (2189 cm-1 SiH4 / 2155 cm-1 Si3H8 / 1107 cm-1 H3SiOSiH3 / 845 cm-1 SiH2), GC-MS/PDD & In-Situ SE / LLS edge inference latency in milliseconds')
param targetEdgeMetrologyLatencyMs string = '0.13'

var clusterName = 'aks-sih4-si3h8-si5h12-epi-${environment}'
var iotHubName = 'iothub-sih4-si3h8-sil3-${uniqueString(resourceGroup().id)}'
var workspaceName = 'log-sih4-si3h8-si5h12-${uniqueString(resourceGroup().id)}'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource sil3IoTHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
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
      defaultTtlAsIso8601: 'PT1M'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'sih4-si3h8-si5h12-higher-silane-gaa-sip-epi-3dnand-channel-pinn-mpc-sil3'
    cycle: '260'
    blueprintNumber: '261'
    safetyStandard: 'SEMI-S2-SEMI-C3-NFPA-55-NFPA-318-OSHA-PSM-IEC-61511-SIL3'
    maxSil3LatencyMs: maxSil3LockoutLatencyMs
    targetEdgeMetrologyLatencyMs: targetEdgeMetrologyLatencyMs
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'katapinnmpc'
        count: sih4Si3h8Si5h12Trains
        vmSize: 'Standard_NV36ads_A10_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/runtime': 'aks-kata-gpu'
          'industrial.azure.com/domain': 'sih4-si3h8-si5h12-higher-silane-gaa-sip-epi-3dnand-channel'
          'industrial.azure.com/safety-loop': 'semi-s2-nfpa55-nfpa318-osha-psm-sil3-0.13ms'
          'industrial.azure.com/metrology': 'qcl-tdlas-2189cm1-2155cm1-1107cm1-845cm1-gcms-se-10khz'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logWorkspace.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output iotHubHostname string = sil3IoTHub.properties.hostName
output governanceMode string = 'pinn_mpc_sih4_si3h8_si5h12_higher_silane_and_gaa_sip_epi_3dnand_channel_sil3_edge'
output sil3InterlockSpec string = 'SEMI S2 / NFPA 55 / NFPA 318 / OSHA PSM / IEC 61511 SIL-3 (<0.13 ms 2oo3 pneumatic Hastelloy-C22 diaphragm valve lockout + RFO flow restrictor + H2/N2 dilution + CDO controlled burn-box + foreline oil-free dry-pump N2 ballast purging SixHy yellow powder on >0.5 ppmv 2189cm-1 SiH4 or >0.2 ppmv 2155cm-1 Si3H8/Si5H12 leak or >0.20 ppbv 1107cm-1 H3SiOSiH3 disiloxane or foreline pressure spike)'
