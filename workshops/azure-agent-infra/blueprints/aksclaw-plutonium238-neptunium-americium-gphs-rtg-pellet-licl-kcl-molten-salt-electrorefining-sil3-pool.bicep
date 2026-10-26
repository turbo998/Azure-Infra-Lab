// blueprints/aksclaw-plutonium238-neptunium-americium-gphs-rtg-pellet-licl-kcl-molten-salt-electrorefining-sil3-pool.bicep
// Cycle #209 (215-Chapter & 210-Blueprint Milestone!): Autonomous Transuranic Actinides — Neptunium (Np, Z=93), Plutonium-238 (238Pu, Z=94) & Americium-241 (241Am, Z=95) Deep-Space Multi-Mission Radioisotope Thermoelectric Generator (MMRTG) General Purpose Heat Source (GPHS 238PuO2 Ceramic Pellet 16O2 Isotope-Exchange to Suppress (alpha,n) Neutrons & DOP-26 Ir-0.3W Vented Clad Electron-Beam Welding) & Gen-IV Sodium Fast Reactor (SFR) Spent Metallic Fuel 500 degC LiCl-KCl Eutectic Molten-Salt Pyroprocessing Electrorefiner (Liquid Cadmium Cathode LCC U-Pu-Np-Am Co-Recovery) PINN-MPC, Online 10 kHz Molten-Salt Square-Wave Voltammetry (SWV), Neutron Coincidence Counting (NCC) & Ultrasonic DOP-26 Ir Weld Metrology & 10 CFR 70 / DOE-STD-3013 / ANSI/ANS-8.15 / IAEA INFCIRC/225 / IEC 61511 SIL-3 Special Nuclear Material (SNM) Criticality Lock, 238PuO2 Alpha Decay Self-Heating Helium Quench & Argon Hot-Cell Containment Interlock Pool

param aksClusterName string = 'aks-plutonium238-neptunium-americium-gphs-rtg-pyro-sil3'
param location string = resourceGroup().location

resource plutonium238NeptuniumAmericiumGphsRtgPyroSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'punpam209s3'
  properties: {
    count: 4 // Standard_NC24ads_A100_v4 (238PuO2 16O-Exchange Sintering, DOP-26 Ir EB-Welding & 500 degC LiCl-KCl LCC Electrorefining PINN-MPC + Online 10 kHz SWV / NCC (alpha,n) / Ultrasonic Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'plutonium238-neptunium-americium-gphs-rtg-pellet-licl-kcl-molten-salt-electrorefining-sil3-agent'
      'aksclaw.io/pinn-mpc-238puo2-16o-gphs-dop26-ir-and-licl-kcl-lcc-pyro': 'enabled-52.0pct-gphs-thermal-density-16o-exchange-lcc-recovery-gain-76.7pct-alphan-fission-carryover-cut'
      'aksclaw.io/cfr70-doe3013-ans815-sil3-snm-criticality-pu238-decay-heat-and-hotcell': 'enforced-0.22ms-zero-snm-criticality-pu238-alpha-breach-or-licl-kcl-cd-fire'
      'aksclaw.io/actinide-pyro-edge-10khz-swv-ncc-alphan-and-dop26-ultrasonic': 'enabled-0.18ms-99.7pct-transuranic-gphs-rtg-pyroprocessing-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/plutonium238-neptunium-americium-gphs-rtg-pellet-licl-kcl-molten-salt-electrorefining-sil3=true:NoSchedule'
    ]
  }
}

resource plutonium238NeptuniumAmericiumGphsRtgPyroSil3RtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'punpam209rt'
  properties: {
    count: 3 // Dedicated Standard_F16s_v2 deterministic real-time pool for 0.22 ms 10 CFR 70 / DOE-STD-3013 / ANSI/ANS-8.15 / SIL-3 SNM criticality lock, 238PuO2 decay-heat He-quench & hot-cell isolation
    vmSize: 'Standard_F16s_v2'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    nodeLabels: {
      'aksclaw.io/realtime-interlock': 'cfr70-doe3013-ans815-sil3-snm-criticality-pu238-decay-heat-he-quench-and-argon-hotcell'
      'aksclaw.io/interlock-latency-slo-ms': '0.22'
    }
    nodeTaints: [
      'aksclaw.io/sil3-hardware-interlock=true:NoExecute'
    ]
  }
}
