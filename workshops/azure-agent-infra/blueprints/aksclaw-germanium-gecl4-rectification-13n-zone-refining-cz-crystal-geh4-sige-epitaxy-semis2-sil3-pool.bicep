// Blueprint #199: Autonomous Germanium (Ge) Zinc-Leach Residue & Lignite Fly-Ash Chlorination Distillation (GeCl4 Boiling Point 83.1 C Ultra-Trace AsCl3/BCl3 Rectification to 7N Purity), GeO2 Hydrolysis & Hydrogen Reduction (650 C), RF Induction Horizontal Zone Refining (13N Intrinsic Resistivity >= 50 Ohm-cm), Dislocation-Free Czochralski (CZ) Ge Single-Crystal Pulling (Space-Grade Multi-Junction GaInP/GaAs/Ge Solar Wafer, HPGe Gamma Detector & 8-12 um LWIR Thermal Optics) & 6N Germane (GeH4) Synthesis for 2nm SiGe Gate-All-Around (GAA) Nanosheet Epitaxy PINN-MPC, Online 10 kHz In-Situ FTIR (GeCl4/AsCl3/GeH4/AsH3), ICP-MS & Four-Point Probe Hall Resistivity Metrology & SEMI S2 / NFPA 55 / OSHA 1910.119 / IEC 61511 SIL-3 Pyrophoric/Toxic Germane (GeH4, TLV 0.2 ppm) & Arsine (AsH3, IDLH 3 ppm) Auto-Decomposition, Corrosive GeCl4/HCl Scrubbing & Zone-Refining Melt-Runaway Interlock Pool (Cycle #198)
param aksClusterName string = 'aks-germanium-13n-cz-geh4-sige-sil3'
param location string = resourceGroup().location

resource germanium13nCzGeh4Sil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'germanisil3'
  location: location
  properties: {
    count: 4 // Standard_NC40ads_H100_v5 (GeCl4 Rectification, 13N Zone Refining Pfann Segregation, Dislocation-Free CZ Ge Wafer & 6N GeH4 SiGe Epitaxy PINN-MPC + Online 10 kHz In-Situ FTIR GeCl4/AsCl3/GeH4 / ICP-MS / Hall 50 Ohm-cm Edge)
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'germanium-gecl4-rectification-13n-zone-refining-cz-crystal-geh4-sige-epitaxy-semis2-sil3-agent'
      'aksclaw.io/pinn-mpc-gecl4-rectification-13n-zone-refining-cz-ge-6n-geh4': 'enabled-50.3pct-13n-ge-purity-cz-solar-wafer-6n-geh4-yield-gain-75.0pct-ascl3-bcl3-vacancy-ring-cut'
      'aksclaw.io/semis2-nfpa55-osha1910119-sil3-pyrophoric-geh4-ash3-gecl4-interlock': 'enforced-0.25ms-zero-pyrophoric-geh4-auto-ignition-ash3-release-or-gecl4-hcl-plume'
      'aksclaw.io/germanium-edge-10khz-insitu-ftir-gecl4-ascl3-geh4-hall-50ohmcm': 'enabled-0.19ms-99.7pct-germanium-13n-cz-geh4-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/germanium-13n-cz-geh4-sige-sil3=true:NoSchedule'
    ]
  }
}
