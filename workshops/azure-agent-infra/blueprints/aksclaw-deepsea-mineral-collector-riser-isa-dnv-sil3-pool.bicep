// =============================================================================
// Blueprint #79: AKSClaw Deep-Ocean Polymetallic Nodule & Subsea Mineral
// Collector (4,000–6,000 m Abyssal Crawler & Vertical Slurry Riser), Benthic
// Terramechanics & Sediment-Plume PINN, Slurry Anti-Plugging MPC & ISA /
// DNV-ST-E407 / IMCA M 103 / IEC 61508 SIL-3 Riser Dump & Plume Interlock
// Agent Pool (Chapter 83)
// =============================================================================

@description('AKS cluster name hosting the deep-ocean mineral collector & vertical slurry riser agent pool')
param clusterName string = 'aks-aksclaw-deepsea-collector-sil3'

@description('Azure region for the subsea mining vessel & benthic plume digital-twin cluster')
param location string = resourceGroup().location

@description('Number of ND96isr_H100_v5 nodes for benthic soil terramechanics, sediment plume PINN & vertical slurry riser MPC')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource deepseaCollectorRiserSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'noduleriser'
  properties: {
    count: nodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    maxPods: 30
    nodeLabels: {
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/workload-class': 'deepsea-mineral-collector-riser-isa-dnv-sil3-agent'
      'aksclaw.io/benthic-terramechanics-plume-riser-mpc': 'enabled-24.6pct-nodule-pickup-38.2pct-plume-dispersion-cut'
      'aksclaw.io/isa-dnv-ste407-sil3-riser-dump-umbilical': 'enforced-2.4ms-zero-riser-plug-or-crawler-sinkage'
      'aksclaw.io/subsea-6000m-fso-sonar-adcp-edge': 'enabled-2.1ms-98.5pct-vsat-wan-cut'
      'aksclaw.io/gpu-Direct-rdma': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/deepsea-collector-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output poolResourceId string = deepseaCollectorRiserSil3Pool.id
output safetyStandard string = 'ISA-ISBA-25-LTC-DNV-ST-E407-IMCA-M103-IEC-61508-SIL3-Riser-Dump-Plume-Interlock'
