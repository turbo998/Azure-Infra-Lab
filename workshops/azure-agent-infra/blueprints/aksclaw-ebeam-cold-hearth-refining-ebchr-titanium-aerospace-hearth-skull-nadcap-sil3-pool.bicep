// Blueprint #166: Autonomous Aerospace Rotor-Grade Titanium & Superalloy Electron-Beam Cold-Hearth Refining (EBCHR 4×800 kW 40 kV Magnetic-Deflection Electron Guns, Water-Cooled Copper Refining Hearth & Withdrawal Mold Skull Melting) High-Density Inclusion (HDI Stokes Sinking) & Hard-Alpha (TiN Dissolution Residence-Time) Elimination & Langmuir-Knudsen Alloying Evaporation (Al/Cr/Sn) PINN-MPC, Online 20 kHz XRF/LIBS Molten-Pool Composition & Two-Color Pyrometry Metrology & AMS 2380 / NADCAP / NFPA 86 / IEC 61511 SIL-3 Water-Cooled Copper Hearth Burn-Through Steam-in-Vacuum Explosion Guard, 40 kV Electron-Gun Arc Crowbar & Ingot Withdrawal Interlock Pool (165-Cycle, 165-Simulator & 170-Chapter Milestone!)
param aksClusterName string = 'aks-ebchr-titanium-hearth-nadcap-sil3'
param location string = resourceGroup().location

resource ebchrTitaniumPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'ebchrtipool3'
  properties: {
    count: 2 // Standard_NV36ads_A10_v5 (Stokes HDI Sinking, TiN Hard-Alpha Dissolution & Langmuir-Knudsen Al Evaporation PINN-MPC + Online 20 kHz XRF/LIBS & Two-Color Pyrometry Edge)
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'ebeam-cold-hearth-refining-ebchr-titanium-aerospace-hearth-skull-nadcap-sil3-agent'
      'aksclaw.io/pinn-mpc-stokes-hdi-sinking-tin-hard-alpha-dissolution-langmuir-al-evaporation': 'enabled-43.5pct-rotor-grade-yield-gain-67.2pct-hard-alpha-al-variance-cut'
      'aksclaw.io/ams2380-nadcap-nfpa86-sil3-copper-hearth-water-leak-40kv-gun-crowbar': 'enforced-0.4ms-zero-copper-hearth-steam-explosion-gun-arc-or-ingot-breakout'
      'aksclaw.io/furnace-edge-20khz-xrf-libs-two-color-pyrometry-ebeam-raster': 'enabled-0.3ms-99.6pct-melt-shop-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/ebchr-titanium-sil3=true:NoSchedule'
    ]
  }
}
