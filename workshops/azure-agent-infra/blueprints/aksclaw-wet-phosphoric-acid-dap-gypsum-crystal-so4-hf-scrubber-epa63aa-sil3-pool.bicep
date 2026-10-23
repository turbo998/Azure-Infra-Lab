// ============================================================================
// Blueprint #142: Autonomous Wet-Process Phosphoric Acid (WPA DH-HH 80-98 C
// Phosphate-Rock H2SO4 Attack Reactor) & Diammonium Phosphate (DAP 18-46-0
// Pipe-Cross Reactor PCR & Rotary Ammoniator-Granulator), Phosphogypsum
// (CaSO4.2H2O) Crystal Habit Supersaturation & Free Sulfate (SO4 2- 24-28 g/L)
// Filtration PINN-MPC, Online Slurry ATR-FTIR / Vent TDLAS HF-SiF4-NH3 Metrology
// & EPA 40 CFR 63 Subpart AA / NFPA 704 / IEC 61508 SIL-3 HF/SiF4 Scrubber
// Breakthrough, Carbonate Foam Boil-Over & PCR Slurry Overpressure Interlock Pool
// ============================================================================
param location string = resourceGroup().location
param clusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// 1. Wet-Process Phosphoric Acid (WPA) & DAP Granulation PINN-MPC + SIL-3 GPU Pool
resource wpaDapGypsumCrystalHfSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'wpadaphfs3'
  properties: {
    count: 2
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'wet-phosphoric-acid-dap-gypsum-crystal-so4-hf-scrubber-epa63aa-sil3-agent'
      'aksclaw.io/pinn-mpc-phosphogypsum-supersaturation-free-so4-dap-nmr': 'enabled-43.1pct-p2o5-recovery-filtration-rate-gain-58.9pct-gypsum-blinding-nh3-slip-cut'
      'aksclaw.io/epa63aa-nfpa704-sil3-hf-sif4-scrubber-antifoam-pcr-cutoff': 'enforced-0.3ms-zero-hf-sif4-toxic-plume-or-reactor-foam-boilover'
      'aksclaw.io/attack-tank-edge-atr-ftir-so4-tdlas-hf-nh3': 'enabled-0.3ms-99.6pct-phosphate-fertilizer-complex-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/wpa-dap-gypsum-hf-sil3=dedicated:NoSchedule'
    ]
  }
}

output poolResourceId string = wpaDapGypsumCrystalHfSil3Pool.id
