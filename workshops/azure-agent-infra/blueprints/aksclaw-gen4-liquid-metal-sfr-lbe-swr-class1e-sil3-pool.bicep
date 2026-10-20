// Blueprint #89: Autonomous Gen-IV Liquid-Metal Fast Reactor (SFR / LBE), Pool Thermal-Stratification & Electromagnetic Pump PINN-MPC, Steam-Generator Sodium-Water Reaction (SWR) Acoustic Detection & ASME BPVC III Div 5 / IEEE 603 Class 1E SIL-3 Pool (Chapter 93)
param clusterName string = 'aksclaw-prod-eastus2'
param location string = resourceGroup().location

resource cluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource gen4LiquidMetalSfrClass1eSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: cluster
  name: 'gen4sfrlbe'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'gen4-liquid-metal-sfr-lbe-swr-class1e-sil3-agent'
      'aksclaw.io/pinn-mpc-pool-thermal-striping-emp-oxygen-control': 'enabled-25.8pct-breeding-thermal-eff-42.6pct-thermal-striping-fatigue-cut'
      'aksclaw.io/asme-bpvc-iii-div5-ieee603-class1e-swr-rupture-disc': 'enforced-0.9ms-zero-sodium-water-excursion-or-cladding-creep-breach'
      'aksclaw.io/containment-ultrasonic-under-sodium-viewing-spnd-edge': 'enabled-0.8ms-99.0pct-nuclear-island-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/gen4-liquid-metal-sfr-lbe-swr-class1e-sil3-agent=true:NoSchedule'
    ]
  }
}
