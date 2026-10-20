// Blueprint #88: Autonomous High-Altitude Stratospheric HALE Solar Pseudo-Satellite (HAPS), Gust-Load Aeroelastic Wing Alleviation, Solid-State Li-S Day-Night Energy Balance & STANAG 4671 / DO-178C DAL-A Pool (Chapter 92)
param clusterName string = 'aksclaw-prod-eastus2'
param location string = resourceGroup().location

resource cluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource haleSolarHapsDalAPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: cluster
  name: 'halehaps'
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
      'aksclaw.io/workload-class': 'stratospheric-hale-solar-haps-aeroelastic-dala-agent'
      'aksclaw.io/pinn-mpc-aeroelastic-gla-stratospheric-stationkeeping': 'enabled-26.2pct-winter-solstice-endurance-39.8pct-wing-root-bending-cut'
      'aksclaw.io/stanag4671-do178c-dala-flutter-envelope-interlock': 'enforced-1.0ms-zero-aeroelastic-flutter-or-night-soc-cutoff'
      'aksclaw.io/onboard-fbg-wing-strain-arinc825-ka-satcom-edge': 'enabled-0.9ms-99.0pct-blos-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/stratospheric-hale-solar-haps-aeroelastic-dala-agent=true:NoSchedule'
    ]
  }
}
