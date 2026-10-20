// Blueprint #93: Autonomous High-Altitude Airborne Wind Energy (AWE Crosswind Rigid-Wing Tethered Kite & Ground-Gen Pumping Cycle) & IEC 61400-30 / EASA SC-AWES SIL-3 Pool (Chapter 97)
param aksClusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource aweCrosswindKiteSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'awekitesil3'
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
      'aksclaw.io/workload-class': 'airborne-wind-energy-crosswind-kite-tether-sil3-agent'
      'aksclaw.io/pinn-mpc-crosswind-figure8-catenary-pumping-cycle': 'enabled-34.5pct-capacity-factor-gain-41.8pct-tether-snapload-fatigue-cut'
      'aksclaw.io/iec61400-30-easa-sc-awes-faa-sil3-winch-adsb-interlock': 'enforced-0.6ms-zero-tether-rupture-or-ground-stall-impact'
      'aksclaw.io/ground-station-doppler-lidar-fbg-tether-adsb-edge': 'enabled-0.5ms-99.2pct-offshore-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/airborne-wind-energy-crosswind-kite-tether-sil3-agent=true:NoSchedule'
    ]
  }
}
