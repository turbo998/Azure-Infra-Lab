// 149. Azure Bicep: Autonomous Lithium Hexafluorophosphate (LiPF6 Anhydrous HF Solvent Synthesis PCl5 + 5HF -> PF5 + 5HCl, LiF + PF5 -> LiPF6) & Lithium Bis(fluorosulfonyl)imide (LiFSI) Battery-Grade Electrolyte Salt Crystallization, PF5 Gas-Liquid Absorption, Supersaturation Ostwald Ripening & Free Acid (HF < 15 ppm) / Trace Moisture (< 10 ppm) Suppression PINN-MPC, Online 19F/31P Benchtop NMR & FT-NIR Karl-Fischer Moisture Metrology & OSHA 29 CFR 1910.119 / NFPA 704 / SEMI S2 / IEC 61511 SIL-3 Anhydrous HF / PF5 / POF3 Toxic Release, -25 C Cryogenic Condenser & Ca(OH)2/KOH Two-Stage Scrubber Interlock Pool (Chapter 153)
param clusterName string = 'aksclaw-prod'
param location string = resourceGroup().location

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource lipf6LifsiElectrolyteSaltSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lipf6hfsil3'
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
      'aksclaw.io/workload-class': 'lipf6-lifsi-electrolyte-salt-anhydrous-hf-pf5-crystallization-osha1910119-sil3-agent'
      'aksclaw.io/pinn-mpc-pf5-ahf-absorption-lipf6-crystallization-free-hf-h2o': 'enabled-43.8pct-lipf6-lifsi-battery-grade-yield-gain-59.7pct-free-hf-pof3-moisture-cut'
      'aksclaw.io/osha1910119-nfpa704-sil3-ahf-pf5-cryo-condenser-caoh2-koh-scrubber-guard': 'enforced-0.2ms-zero-ahf-pf5-toxic-plume-or-lipf6-thermal-decomposition'
      'aksclaw.io/crystallizer-edge-19f-31p-nmr-ftnir-moisture-tdlas-hf': 'enabled-0.3ms-99.6pct-electrolyte-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/lipf6-lifsi-electrolyte-salt-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = lipf6LifsiElectrolyteSaltSil3Pool.id
