// Blueprint #94: Autonomous Ultra-High-Speed 600 km/h EMS/EDS Superconducting Maglev Linear Synchronous Motor (LSM) Section-Switching, Air-Gap Levitation Flutter PINN-MPC & EN 50128 / EN 50129 SIL-4 Pool (Chapter 98)
param aksClusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource maglevLsmAirgapSil4Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'maglevsil4'
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
      'aksclaw.io/workload-class': 'maglev-eds-ems-lsm-levitation-airgap-sil4-agent'
      'aksclaw.io/pinn-mpc-airgap-girder-resonance-lsm-stator-handover': 'enabled-32.4pct-airgap-stability-gain-39.2pct-lsm-thrust-ripple-power-cut'
      'aksclaw.io/en50128-en50129-sil4-eddy-current-brake-skid-guard': 'enforced-0.4ms-zero-guideway-pole-strike-or-overturn-breach'
      'aksclaw.io/wayside-38ghz-mmwave-eddy-gap-tsn-edge': 'enabled-0.4ms-99.3pct-rail-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/maglev-eds-ems-lsm-levitation-airgap-sil4-agent=true:NoSchedule'
    ]
  }
}
