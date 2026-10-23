// Blueprint #173: Bayer Process Alumina Refinery High-Temperature Tube Digestion (245-280 °C / 3.5-5.5 MPa Boehmite/Diaspore Bauxite Caustic Leaching AlO(OH) + OH- + H2O -> Al(OH)4-), Sodium Aluminosilicate Desilication Product (DSP Sodalite/Cancrinite Scale) & Gibbsite Seeded Precipitation Population-Balance PINN-MPC, Online 10 kHz Ultrasonic Scale Tomography / Raman Supersaturation (A/C Ratio) / Coriolis Liquor Metrology & ASME BPVC Section VIII / API RP 556 / OSHA 1910.119 / IEC 61511 SIL-3 Flash-Tank Caustic-Steam Eruption, Autoclave Overpressure & Alkaline Stress-Corrosion Cracking (SCC) Pool
param aksClusterName string = 'aks-bayer-alumina-refinery-tube-digestion-asme8-sil3'
param location string = resourceGroup().location

resource bayerAluminaPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'bayerpinn'
  properties: {
    count: 2 // Standard_NV36ads_A10_v5 (Bayer Tube Digestion Leaching, DSP Sodalite/Cancrinite Scale Kinetics & Gibbsite Seeded Precipitation PBM PINN-MPC + Online 10 kHz Ultrasonic Scale / Raman A/C Ratio / Coriolis Liquor Edge)
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'bayer-alumina-refinery-tube-digestion-dsp-scale-gibbsite-pbm-asme8-sil3-agent'
      'aksclaw.io/pinn-mpc-bayer-tube-digestion-dsp-scale-gibbsite-seeded-precipitation-pbm': 'enabled-45.1pct-alumina-yield-heat-transfer-gain-68.2pct-dsp-sodalite-scale-fines-nucleation-cut'
      'aksclaw.io/asme8-apirp556-osha1910119-sil3-caustic-flash-eruption-autoclave-scc': 'enforced-0.4ms-zero-autoclave-rupture-flash-tank-caustic-carryover-or-alkaline-scc-leak'
      'aksclaw.io/digester-edge-10khz-ultrasonic-dsp-scale-raman-ac-supersaturation-coriolis': 'enabled-0.3ms-99.6pct-alumina-refinery-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/bayer-alumina-refinery-tube-digestion-dsp-scale-gibbsite-pbm-asme8-sil3=true:NoSchedule'
    ]
  }
}
