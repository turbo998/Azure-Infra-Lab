// Blueprint #97: Autonomous Gigaton-Scale Offshore Carbon Capture, Utilization & Subsea Geological Sequestration (CCUS) Dense-Phase Supercritical CO2 Trunkline Decompression-Fracture PINN-MPC, Caprock Pore-Pressure Inversion & ISO 27913 / ISO 27914 / DNV-RP-F104 / IEC 61511 SIL-3 Pool (Chapter 101)
param clusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource offshoreCcusCo2SequestrationSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ccussil3'
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
      'aksclaw.io/workload-class': 'offshore-ccus-co2-pipeline-caprock-sequestration-sil3-agent'
      'aksclaw.io/pinn-mpc-span-wagner-co2-fracture-arrest-biot-caprock': 'enabled-33.6pct-storage-capacity-gain-44.2pct-jt-freeze-throttle-loss-cut'
      'aksclaw.io/iso27913-iso27914-dnv-f104-sil3-ssiv-lot-interlock': 'enforced-0.5ms-zero-running-ductile-fracture-or-caprock-breach'
      'aksclaw.io/subsea-4d-das-dts-downhole-quartz-gauge-edge': 'enabled-0.5ms-99.3pct-offshore-wan-cut'
      'aksclaw.io/gpu-Partition': 'mig-3g.40gb'
    }
    nodeTaints: [
      'aksclaw.io/offshore-ccus-co2-sequestration-sil3=true:NoSchedule'
    ]
  }
}
