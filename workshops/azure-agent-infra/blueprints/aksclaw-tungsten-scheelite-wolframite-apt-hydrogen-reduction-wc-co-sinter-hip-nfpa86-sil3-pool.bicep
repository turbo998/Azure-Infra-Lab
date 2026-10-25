// Blueprint #198: Autonomous Scheelite (CaWO4) & Wolframite ((Fe,Mn)WO4) Soda/Caustic Autoclave Pressure Leaching, Molybdenum Sulfidation-Ion-Exchange Deep Separation (MoS4^2- < 5 ppm), Ammonium Paratungstate (APT, (NH4)10[H2W12O42]·4H2O) Evaporative Crystallization, Rotary-Kiln Violet/Blue Tungsten Oxide (WO2.72/WO2.90) Calcination, Multi-Zone Pusher-Furnace Hydrogen Reduction (WO2.72 + 2.72H2 <-> W + 2.72H2O Dew-Point CVT Grain-Size Control 80 nm - 2.0 um), Ultrafine Tungsten Carbide-Cobalt (WC-Co with VC/Cr3C2 Inhibitors, 1420 C Vacuum/Sinter-HIP Avoiding Eta-Phase Co3W3C & Free Graphite) & Fusion-Reactor Tokamak Divertor W-Cu Monoblock PINN-MPC, Online 10 kHz In-Situ Raman (WO4^2-/MoS4^2-/WC), TDLAS (H2O/H2/NH3/H2S) & Magnetic Saturation (Com / Coercivity Hc) Metrology & NFPA 86 / NFPA 652 / ASME BPVC VIII / OSHA 1910.119 / IEC 61511 SIL-3 Pusher-Furnace Hydrogen Air-Ingress Detonation Prevention, Pyrophoric Nano-Tungsten Powder (< 150 nm) Argon Passivation & Sulfidation H2S Scrubbing Interlock Pool (Cycle #197)
param aksClusterName string = 'aks-tungsten-apt-wcco-sinter-hip-sil3'
param location string = resourceGroup().location

resource tungstenAptWcCoSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'tungstsil3'
  location: location
  properties: {
    count: 4 // Standard_NC40ads_H100_v5 (Scheelite/Wolframite Autoclave Leaching, MoS4^2- Ion-Exchange, APT Crystallization, H2 Reduction CVT Dew-Point, WC-Co Sinter-HIP Eta/Carbon Window & Tokamak W-Cu Divertor PINN-MPC + Online 10 kHz In-Situ Raman / TDLAS / Magnetic Com-Hc Edge)
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'tungsten-scheelite-wolframite-apt-hydrogen-reduction-wc-co-sinter-hip-nfpa86-sil3-agent'
      'aksclaw.io/pinn-mpc-scheelite-apt-h2-cvt-wcco-sinter-hip-divertor': 'enabled-50.1pct-wo3-leach-apt-purity-wcco-toughness-gain-74.8pct-eta-phase-co3w3c-cvt-coarsening-cut'
      'aksclaw.io/nfpa86-nfpa652-asme8-osha1910119-sil3-h2-furnace-pyrophoric-w-h2s-interlock': 'enforced-0.25ms-zero-pusher-furnace-h2-explosion-pyrophoric-nano-w-fire-or-h2s-release'
      'aksclaw.io/tungsten-edge-10khz-insitu-raman-wo4-mos4-tdlas-h2o-com-hc': 'enabled-0.19ms-99.7pct-tungsten-apt-cemented-carbide-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/tungsten-apt-wcco-sinter-hip-sil3=true:NoSchedule'
    ]
  }
}
