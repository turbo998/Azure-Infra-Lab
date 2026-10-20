// Blueprint #84: Deepwater FPSO Turret-Mooring Weathervaning, Subsea Riser Severe-Slugging & Topside Anti-Surge PINN-MPC & API RP 14C / DNV-OS-E301 / SIL-3 Pool (Chapter 88)
param clusterName string = 'aksclaw-prod-cluster'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource fpsoTurretMooringRiserSluggingSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'fpsoturret'
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
      'aksclaw.io/workload-class': 'fpso-turret-mooring-riser-slugging-apirp14c-sil3-agent'
      'aksclaw.io/riser-slugging-turret-pinn-mpc': 'enabled-25.6pct-throughput-39.1pct-slug-oscillation-cut'
      'aksclaw.io/apirp14c-dnv-sil3-hipps-eqd-esd1': 'enforced-1.2ms-zero-separator-carryover-or-mooring-breach'
      'aksclaw.io/topside-mpfm-das-antisurge-edge': 'enabled-1.1ms-98.9pct-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/fpso-turret-mooring-riser-slugging-apirp14c-sil3=true:NoSchedule'
    ]
  }
}
