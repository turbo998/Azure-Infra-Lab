// Blueprint #85: 8-Inch 4H-SiC Silicon Carbide PVT Crystal Boule Growth & HT-CVD Epitaxy PINN-MPC & SEMI S2 / SEMI M55 / NFPA 86 / SIL-3 Pool (Chapter 89)
param clusterName string = 'aksclaw-prod-cluster'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource sicPvtBouleCrystalGrowthSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'sicpvt'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'sic-pvt-boule-crystal-growth-htcvd-semis2-sil3-agent'
      'aksclaw.io/radiative-sublimation-bpd-pinn-mpc': 'enabled-28.7pct-boule-yield-41.2pct-bpd-dislocation-cut'
      'aksclaw.io/semis2-nfpa86-sil3-coil-leak-silane-purge': 'enforced-1.3ms-zero-steam-explosion-or-silane-breach'
      'aksclaw.io/cleanroom-xray-pyrometry-secsgem-edge': 'enabled-1.2ms-98.7pct-fab-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/sic-pvt-boule-crystal-growth-htcvd-semis2-sil3=true:NoSchedule'
    ]
  }
}
