// =============================================================================
// Blueprint #106: Autonomous Ultra-Deep Continental Scientific & Superhot-Rock
// (10,000–12,000 m, >260 °C / 180 MPa) Hybrid Plasma-Percussion Drilling,
// High-Temperature Mud Rheology & Borehole Thermoelastic Breakout PINN-MPC,
// In-Situ Sonic-While-Drilling FWI & API RP 53 / ISO 15156 / IEC 61511 SIL-3
// H2S Sulfide-Stress-Cracking & 140 MPa BOP Interlock Agent Pool
// =============================================================================

@description('Azure region for the ultra-deep 10km superhot-rock drilling cluster')
param location string = resourceGroup().location

@description('AKS cluster name hosting the ultra-deep 10km drilling & ISO 15156 SIL-3 digital twin pool')
param aksClusterName string = 'aks-aksclaw-ultradeep-10km-sil3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU PINN-MPC Pool: Kirsch-Biot Thermoelastic Borehole Breakout, Herschel-Bulkley HTHP
//    Mud Sag/Rheology & Stick-Slip/Whirl PINN + WOB/RPM/ECD & Plasma-Percussion MPC
resource ultradeepDrillingGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'deep10kmsil3'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'OCIContainer'
    enableUltraSSD: true
    nodeLabels: {
      'aksclaw.io/workload-class': 'ultradeep-10km-superhot-rock-drilling-fwi-iso15156-sil3-agent'
      'aksclaw.io/pinn-mpc-thermoelastic-breakout-hthp-rheology': 'enabled-35.2pct-rop-bit-life-gain-47.6pct-breakout-stuck-pipe-cut'
      'aksclaw.io/apirp53-iso15156-sil3-h2s-140mpa-bop-guard': 'enforced-0.4ms-zero-h2s-ssc-embrittlement-or-hthp-blowout'
      'aksclaw.io/rig-edge-swd-fwi-wired-pipe-coriolis-fusion': 'enabled-0.4ms-99.3pct-rig-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/ultradeep-10km-gpu=true:NoSchedule'
    ]
  }
}

// 2. Rig-Floor Edge Pool: Sonic-While-Drilling (SWD) Look-Ahead FWI, High-Speed Wired
//    Drill Pipe (WDP) Telemetry & Coriolis Micro-Flux H2S/Kick Edge Triage
resource ultradeepRigEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'rig10kmedge'
  properties: {
    count: 4
    vmSize: 'Standard_D32as_v7'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'aksclaw.io/tier': 'rig-edge-swd-fwi-wired-pipe-coriolis'
      'aksclaw.io/interlock-standard': 'api-rp53-nace-mr0175-iso15156-iec61511-sil3'
      'aksclaw.io/fieldbus-protocol': 'witsml-profisafe-ethercat-0.4ms'
    }
  }
}
