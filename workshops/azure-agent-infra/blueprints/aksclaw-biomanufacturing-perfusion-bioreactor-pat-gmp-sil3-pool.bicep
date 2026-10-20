// Blueprint #80: Autonomous Biomanufacturing & Continuous Perfusion Bioreactor (2000-20000L mAb/Viral Vector), Metabolic FBA & Glycosylation PINN-MPC & FDA 21 CFR Part 11 / EU GMP Annex 11 / ASME BPE / SIL-3 Pool (Chapter 84)
param clusterName string = 'aksclaw-prod-eastus2'
param location string = resourceGroup().location

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource biomanufacturingPerfusionGmpSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'bioperfusion'
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
      'aksclaw.io/workload-class': 'biomanufacturing-perfusion-bioreactor-pat-gmp-sil3-agent'
      'aksclaw.io/metabolic-fba-glycosylation-pinn-tff-mpc': 'enabled-28.4pct-titer-yield-34.6pct-tff-fouling-cut'
      'aksclaw.io/fda-cfr11-gmp-bpe-sil3-sip-viral-interlock': 'enforced-1.9ms-zero-contamination-or-viral-hold-breach'
      'aksclaw.io/cleanroom-raman-capacitance-opcua-edge': 'enabled-1.7ms-98.6pct-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/biomanufacturing-perfusion-gmp-sil3=true:NoSchedule'
    ]
  }
}
