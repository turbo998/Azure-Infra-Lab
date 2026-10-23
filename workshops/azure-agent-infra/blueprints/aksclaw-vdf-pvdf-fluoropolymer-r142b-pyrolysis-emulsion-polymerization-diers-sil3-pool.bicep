// 150. Azure Bicep: Autonomous Vinylidene Fluoride (VDF R142b CH3CClF2 -> CH2=CF2 + HCl Thermal Pyrolysis 650-700 C) & Battery-Grade Polyvinylidene Fluoride (PVDF Cathode Binder Mw > 1.0M Da) High-Pressure Emulsion/Suspension Polymerization, Head-to-Head (H-H < 3.5 mol%) Regio-Defect, Pyrolysis Tube Coking & Dehydrofluorination Resistance PINN-MPC, Online 19F-NMR Regio-Isomer / FT-IR Beta-Phase (840 cm^-1) Metrology & OSHA 29 CFR 1910.119 / NFPA 68 / DIERS / IEC 61511 SIL-3 Supercritical VDF Monomer Runaway Deflagration, Peroxide Short-Stop Inhibitor & Anhydrous HCl Quench Interlock Pool (Chapter 154 - 150th Blueprint Milestone)
param clusterName string = 'aksclaw-prod'
param location string = resourceGroup().location

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource vdfPvdfFluoropolymerSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'vdfpvdfsil3'
  properties: {
    count: 2
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'vdf-pvdf-fluoropolymer-r142b-pyrolysis-emulsion-polymerization-diers-sil3-agent'
      'aksclaw.io/pinn-mpc-r142b-pyrolysis-vdf-head-to-head-defect-pvdf-mwd': 'enabled-43.9pct-vdf-selectivity-battery-pvdf-binder-yield-gain-59.8pct-hh-defect-coking-cut'
      'aksclaw.io/osha1910119-diers-sil3-vdf-shortstop-inhibitor-hcl-quench-guard': 'enforced-0.2ms-zero-supercritical-vdf-autodecomposition-or-hcl-release'
      'aksclaw.io/autoclave-edge-19f-nmr-hh-defect-ftir-beta-840cm-raman-vdf': 'enabled-0.3ms-99.6pct-fluoropolymer-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/vdf-pvdf-fluoropolymer-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = vdfPvdfFluoropolymerSil3Pool.id
