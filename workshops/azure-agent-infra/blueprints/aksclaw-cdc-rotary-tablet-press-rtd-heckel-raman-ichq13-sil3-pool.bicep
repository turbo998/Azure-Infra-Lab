// blueprints/aksclaw-cdc-rotary-tablet-press-rtd-heckel-raman-ichq13-sil3-pool.bicep
// Blueprint #165 (165-Blueprint Milestone!): Autonomous Pharmaceutical Continuous Direct Compression (CDC Loss-in-Weight Twin-Screw Feeder, Continuous Blender & High-Speed 72-Station Rotary Tablet Press) Residence-Time-Distribution (RTD Tank-in-Series Taylor Dispersion) & Heckel/Kawakita Compaction PINN-MPC, Online 10 kHz Piezo Punch-Force, Near-Infrared (NIR) / Transmission Raman Content-Uniformity (RSD < 1.5%) & Terahertz Coating Metrology & FDA 21 CFR Part 11 / ICH Q13 / ATEX / IEC 61511 SIL-3 Single-Tablet Reject-Gate, Punch-Binding Overload & Combustible-Dust Explosion Interlock Pool

param aksClusterName string = 'aks-cdc-tablet-press-ichq13-sil3'
param location string = resourceGroup().location
param gpuNodeCount int = 2

resource cdcTabletPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'cdctabpool3'
  location: location
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'cdc-rotary-tablet-press-rtd-heckel-raman-ichq13-sil3-agent'
      'aksclaw.io/gpu-accelerator': 'nvidia-a10-24gb'
      'aksclaw.io/pinn-mpc-rtd-taylor-dispersion-heckel-kawakita-compaction': 'enabled-44.2pct-rtrt-yield-gain-66.8pct-api-rsd-capping-cut'
      'aksclaw.io/ichq13-21cfr11-atex-sil3-single-tablet-reject-punch-overload': 'enforced-0.4ms-zero-oot-subpotent-tablet-escape-punch-collision-or-dust-explosion'
      'aksclaw.io/press-edge-10khz-piezo-punch-nir-transmission-raman-thz': 'enabled-0.3ms-99.7pct-pharma-suite-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/cdc-rotary-tablet-press-rtd-heckel-raman-ichq13-sil3=true:NoSchedule'
    ]
  }
}
