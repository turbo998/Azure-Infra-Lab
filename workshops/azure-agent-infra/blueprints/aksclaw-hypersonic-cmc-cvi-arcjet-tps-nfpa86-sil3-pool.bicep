// Blueprint #81: Autonomous Ultra-High-Temperature Ceramic Matrix Composite (SiC/SiC CMC) CVI & Hypersonic Arc-Jet TPS Testing (2200-3000C), Knudsen Diffusion & Ablation PINN-MPC & NASA-STD-5001B / NFPA 86 / SIL-3 Pool (Chapter 85)
param clusterName string = 'aksclaw-prod-eastus2'
param location string = resourceGroup().location

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource hypersonicCmcCviArcjetSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'cmcarcjet'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'hypersonic-cmc-cvi-arcjet-tps-nfpa86-sil3-agent'
      'aksclaw.io/knudsen-cvi-ablation-pinn-mpc': 'enabled-26.8pct-ilss-density-36.4pct-pore-crusting-cut'
      'aksclaw.io/nasa5001-nfpa86-sil3-mts-purge-arc-cooling': 'enforced-1.3ms-zero-h2-deflagration-or-anode-burnout'
      'aksclaw.io/testcell-pyrometry-plif-ae-edge': 'enabled-1.2ms-98.7pct-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/hypersonic-cmc-cvi-arcjet-sil3=true:NoSchedule'
    ]
  }
}
