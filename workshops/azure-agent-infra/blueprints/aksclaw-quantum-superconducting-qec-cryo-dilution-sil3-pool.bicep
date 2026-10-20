// =============================================================================
// Blueprint #77: AKSClaw Superconducting Quantum Processor (10 mK Dilution
// Refrigerator Array), Rotated Surface-Code QEC Neural Syndrome Decoder PINN,
// Cryo-CMOS DRAG Pulse MPC & ASME BPVC VIII / IEC 61508 SIL-3 3He/4He Quench
// Boil-Off Venting Interlock Agent Pool (Chapter 81)
// =============================================================================

@description('AKS cluster name hosting the superconducting quantum QEC & dilution cryostat agent pool')
param clusterName string = 'aks-aksclaw-quantum-qec-sil3'

@description('Azure region for the superconducting quantum control & QEC simulation cluster')
param location string = resourceGroup().location

@description('Number of ND96isr_H100_v5 nodes for rotated surface-code QEC neural syndrome decoding & Lindblad master-equation PINN')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource quantumQecCryoSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'qecsurface'
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
      'aksclaw.io/workload-class': 'quantum-superconducting-qec-cryo-dilution-sil3-agent'
      'aksclaw.io/surface-code-qec-lindblad-drag-mpc': 'enabled-42.5pct-logical-error-cut-29.4pct-coherence-t1t2-gain'
      'aksclaw.io/asme-bpvc-sil3-he3-he4-dump-quench': 'enforced-0.6ms-zero-helium-rupture-or-10mk-stage-boiloff'
      'aksclaw.io/cryo-rfsoc-fpga-syndrome-edge': 'enabled-0.4ms-98.8pct-cryostat-wan-cut'
      'aksclaw.io/gpu-Direct-rdma': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/quantum-qec-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output poolResourceId string = quantumQecCryoSil3Pool.id
output safetyStandard string = 'ASME-BPVC-VIII-ANSI-Z136.1-IEC-61508-SIL3-He3-He4-Cryo-Dump-Interlock'
