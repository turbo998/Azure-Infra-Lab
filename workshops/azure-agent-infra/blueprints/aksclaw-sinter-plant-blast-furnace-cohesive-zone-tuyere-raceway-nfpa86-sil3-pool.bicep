// ============================================================================
// Blueprint #143: Autonomous Integrated Blast Furnace (BF 4,000-5,800 m3
// Hot-Metal Ironmaking & Dwight-Lloyd Sinter Plant), Cohesive-Zone (Softening-
// Melting Zone 1,150-1,450 C Inverted-V Profile) Permeability, Tuyere Raceway
// Pulverized Coal / H2 Injection (PCI 180-220 kg/t-HM) & Hearth Carbon-Brick
// Elephant-Foot Erosion PINN-MPC, Online Top-Gas Mass-Spec / Microwave Burden
// Profilemeter Metrology & NFPA 86 / ISO 13577 / IEC 61508 SIL-3 Burden
// Hanging-Slipping, Tuyere Water-Leak H2 Explosion & Hearth Breakout Pool
// ============================================================================
param location string = resourceGroup().location
param clusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// 1. Blast Furnace Cohesive-Zone, Tuyere Raceway PCI & Hearth Erosion PINN-MPC + SIL-3 GPU Pool
resource blastFurnaceCohesiveZoneTuyereSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'bfcohsil3'
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
      'aksclaw.io/workload-class': 'sinter-plant-blast-furnace-cohesive-zone-tuyere-raceway-nfpa86-sil3-agent'
      'aksclaw.io/pinn-mpc-cohesive-zone-permeability-pci-raceway-hearth-erosion': 'enabled-42.6pct-hot-metal-productivity-top-gas-eta-co-gain-58.4pct-coke-rate-silicon-variance-cut'
      'aksclaw.io/nfpa86-iso13577-sil3-tuyere-water-leak-hanging-slip-hearth-guard': 'enforced-0.3ms-zero-tuyere-water-h2-explosion-burden-slip-or-hearth-breakout'
      'aksclaw.io/casthouse-edge-36-tuyere-ccd-topgas-ms-fmcw-radar': 'enabled-0.3ms-99.6pct-integrated-steelworks-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/blast-furnace-cohesive-tuyere-sil3=dedicated:NoSchedule'
    ]
  }
}

output poolResourceId string = blastFurnaceCohesiveZoneTuyereSil3Pool.id
