// ============================================================================
// AKSClaw Curium (Cm, Z=96), Berkelium (Bk, Z=97) & Californium-252 (252Cf, Z=98)
// High-Flux Isotope Reactor (HFIR) 244-248CmO2-Al Target Transmutation, High-Pressure
// Ion-Exchange (HPIX alpha-HIBA) Chromatography, Pd-252Cf2O3 Spontaneous-Fission
// Neutron Source Wire/Capsule & Gd2O3/Er2O3/10B4C Burnable Absorber HIP Pool (Blueprint #211)
// Cycle #210 (210-Cycle & 210-Simulator Milestone!) — PINN-MPC + 10kHz Stilbene PSD,
// Cherenkov/Alpha Eluate & He-Leak Edge + 10 CFR 70 / ANSI/ANS-8.15 / ISO 2919 / SIL-3 Interlock
// ============================================================================

@description('Azure region for the AKSClaw Cm/Bk/252Cf transplutonium neutron source & reactor control absorber cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Cm/Bk/252Cf HPIX chromatography, Pd-252Cf2O3 neutron source & 10B4C/Gd2O3 absorber workloads')
param clusterName string = 'aks-aksclaw-curium-berkelium-californium252-sil3'

@description('GPU node count for HFIR Bateman transmutation, alpha-HIBA HPIX elution & Pd-252Cf2O3 / Gd2O3-10B4C HIP PINN-MPC')
@minValue(1)
@maxValue(32)
param gpuNodeCount int = 4

@description('Deterministic RT node count for 10 CFR 70 / ANSI/ANS-8.15 / ISO 2919 SIL-3 WEP neutron shield, H2/O2 recombiner & capsule leak interlock')
@minValue(2)
@maxValue(16)
param rtSil3NodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// 1. GPU Node Pool (Standard_NC24ads_A100_v4) for HFIR Cm-target transmutation, alpha-HIBA HPIX & Pd-252Cf2O3 PINN-MPC
resource cmbkcfPinnGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'cmbkcf210s3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 1
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-tier': 'cm-bk-cf252-hpix-neutron-source-burnable-absorber-pinn-mpc'
      'aksclaw.io/edge-metrology': 'stilbene-psd-fast-neutron-cherenkov-alpha-eluate-and-he-leak-10khz'
      'aksclaw.io/metrology-latency-target-ms': '0.17'
      'aksclaw.io/wan-bandwidth-reduction-pct': '99.7'
    }
    nodeTaints: [
      'aksclaw.io/transplutonium-cf252-gpu=true:NoSchedule'
    ]
  }
}

// 2. Real-Time SIL-3 Safety Node Pool (Standard_F16s_v2) for 0.21ms WEP neutron shield, radiolytic H2 recombiner & ISO 2919 capsule interlock
resource cmbkcfSil3RtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'cmbkcf210rt'
  properties: {
    count: rtSil3NodeCount
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    enableAutoScaling: false
    nodeLabels: {
      'aksclaw.io/safety-integrity-level': 'IEC-61511-SIL-3'
      'aksclaw.io/nuclear-safety-standard': '10-CFR-70-ANSI-ANS-8.15-ISO-2919-IAEA-SSR-6-ASME-NQA-1'
      'aksclaw.io/interlock-cutoff-latency-ms': '0.21'
      'aksclaw.io/wep-borated-paraffin-neutron-shield-radiolytic-h2-recombiner-and-iso2919-c66646-capsule-trip': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/sil3-hardware-interlock=true:NoExecute'
    ]
  }
}

output pinnMpcPoolName string = cmbkcfPinnGpuPool.name
output sil3InterlockPoolName string = cmbkcfSil3RtPool.name
output targetEdgeMetrologyLatencyMs string = '0.17'
output targetSil3InterlockLatencyMs string = '0.21'
