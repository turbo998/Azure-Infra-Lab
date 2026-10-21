@description('AKS cluster name for Autonomous Deep-Underground Longwall Mining (800-1,500 m Depth 8-10 m High-Seam Hydraulic Shields & Double-Drum Shearer), Overburden Key-Stratum Rockburst Microseismic Tomography & Coal-Rock Interface Natural-Gamma/THz PINN-MPC, Shield Leg FBG / TDLAS CH4-CO Metrology & IEC 61508 SIL-3 / ATEX Group I Category M1 Ex ia Rockburst High-Flow Yield Valve, Coal-and-Gas Outburst Power Cut-Off & Goaf Nitrogen Inerting Interlock Sandbox Pool')
param clusterName string = 'aksclaw-longwall-rockburst-shearer-atexm1-sil3'

@description('Azure region for ruggedized underground roadway substation Azure Local / AKS hybrid edge cluster')
param location string = resourceGroup().location

@description('GPU node count for Overburden Key-Stratum Masonry-Beam Fracture & Stress-Wave Propagation PINN, Electro-Hydraulic Shield Follow-Up & Shearer Drum Horizon MPC, and Natural-Gamma / 3D Microseismic / TDLAS CH4-CO Edge')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource longwallRockburstShearerSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lwrockbrsts3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    maxPods: 32
    nodeLabels: {
      'aksclaw.io/Runtime-Isolation': 'Kata-VM-Intercepted'
      'aksclaw.io/workload-class': 'longwall-mining-rockburst-shearer-methane-atexm1-sil3-agent'
      'aksclaw.io/pinn-mpc-overburden-rockburst-coal-rock-horizon': 'enabled-39.6pct-raw-coal-recovery-advance-rate-gain-54.5pct-gangue-ratio-leg-yield-cut'
      'aksclaw.io/atexm1-sil3-rockburst-yield-valve-ch4-power-cut-interlock': 'enforced-0.3ms-zero-methane-explosion-or-shield-column-burst'
      'aksclaw.io/roadway-edge-microseismic-gamma-tdlas-ch4-co': 'enabled-0.3ms-99.5pct-mine-shaft-wan-cut'
      'aksclaw.io/gpu-mps-partition': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/longwall-rockburst-atexm1-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output poolResourceId string = longwallRockburstShearerSil3Pool.id
output safetyStandard string = 'IEC-61508-SIL3-ATEX-Group-I-M1-Ex-ia-IEC-60079-0-MSHA-30CFR'
output targetInterlockLatencyMs string = '0.3'
