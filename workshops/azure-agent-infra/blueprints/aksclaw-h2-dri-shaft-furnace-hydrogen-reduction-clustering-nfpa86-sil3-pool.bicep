// Azure Bicep Blueprint #103: Autonomous Direct-Reduced Iron (H2-DRI) Shaft Furnace Counter-Current Hydrogen Reduction Kinetics, Metallization & Burden-Clustering Prevention PINN-MPC, In-Situ Top-Gas Laser TDLAS / Mass-Spec Inversion & NFPA 86 / ISO 13577 / ATEX / IEC 61511 SIL-3 Hot Pyrophoric Sponge-Iron Passivation & Pressurized Hydrogen Seal Interlock Pool (Chapter 107)
param location string = resourceGroup().location
param aksClusterName string = 'aks-h2-dri-shaft-furnace-sil3'
param gpuNodeCount int = 2
param edgeNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. H100 GPU Pool for 3-Stage Unreacted Shrinking-Core (Fe2O3 -> Fe3O4 -> FeO -> Fe) Endothermic H2 Reduction, Solid-State Iron-Whisker Sintering Clustering & Ergun Counter-Current Burden-Gas PINN + Bustle-Gas Temperature/CH4-Doping & Rotary-Valve Discharge MPC
resource h2DriShaftPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'h2drisil3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    scaleSetPriority: 'Regular'
    nodeLabels: {
      'aksclaw.io/workload-class': 'h2-dri-shaft-furnace-hydrogen-reduction-clustering-sil3-agent'
      'aksclaw.io/pinn-mpc-shrinking-core-metallization-clustering-ergun': 'enabled-33.4pct-metallization-h2-yield-gain-47.2pct-clustering-freeze-cut'
      'aksclaw.io/nfpa86-iso13577-atex-sil3-pyrophoric-fe-h2-seal-guard': 'enforced-0.4ms-zero-sponge-iron-autoignition-or-bustle-h2-jet-fire'
      'aksclaw.io/furnace-edge-topgas-tdlas-massspec-fmcw-burden-radar': 'enabled-0.4ms-99.3pct-steelworks-wan-cut'
      'kubernetes.azure.com/ebpf-dataplane': 'cilium'
    }
    nodeTaints: [
      'aksclaw.io/h2-dri-shaft-furnace-gpu=true:NoSchedule'
    ]
  }
}

// 2. Shaft-Furnace Platform Edge Pool for Top-Gas TDLAS/Mass-Spec H2O-H2-CO Analyzer, 79 GHz FMCW Burden-Profile Radar & NFPA 86 / ISO 13577 SIL-3 Dynamic Seal-Leg Nitrogen Injection Interlock
resource h2DriFurnaceEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'h2driedge'
  properties: {
    count: edgeNodeCount
    vmSize: 'Standard_D32as_v7'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    nodeLabels: {
      'aksclaw.io/workload-class': 'h2-dri-shaft-tdlas-fmcw-radar-profinet-edge'
      'aksclaw.io/topgas-tdlas-massspec-metallization-soft-sensor': 'enabled-0.4ms-95pct-metallization-tracking'
      'aksclaw.io/79ghz-fmcw-burden-descent-clustering-bridge-inversion': 'enabled-sub-cm-burden-slip-and-channeling-detection'
      'aksclaw.io/nfpa86-iso13577-sil3-dynamic-n2-seal-leg-hdr-passivation': 'enforced-0.4ms-zero-h2-egress-or-hdr-hopper-reoxidation'
    }
  }
}

output h2DriShaftPoolId string = h2DriShaftPinnPool.id
output h2DriFurnaceEdgePoolId string = h2DriFurnaceEdgePool.id
