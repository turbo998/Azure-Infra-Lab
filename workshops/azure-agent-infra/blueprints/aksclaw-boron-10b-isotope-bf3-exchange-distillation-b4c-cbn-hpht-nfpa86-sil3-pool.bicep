// ============================================================================
// Blueprint #191: Autonomous Colemanite/Borax Acidulation to Boric Acid,
// Boron Trifluoride-Dimethyl Ether (BF3-DME) Chemical Exchange Distillation
// for Nuclear-Grade Enriched 10B (>96 at% 10B) & Semiconductor 11BF3,
// 2,400 C Carbothermic Boron Carbide (B4C) Smelting & HPHT Cubic Boron
// Nitride (cBN) Synthesis PINN-MPC & NFPA 86 / OSHA 1910.119 / IAEA SSG-2 /
// SEMI S2 / IEC 61511 SIL-3 Agent Pool
// ============================================================================
// Target: Azure Kubernetes Service (AKS) + Kata + Confidential Computing + FPGA
// Standards: NFPA 86 / OSHA 1910.119 / IAEA SSG-2 / SEMI S2 / IEC 61511 SIL-3
// Node SKU: Standard_NC40ads_H100_v5 (1x NVIDIA H100 NVL 94GB + InfiniBand)
// ============================================================================

@description('AKS cluster name hosting the Boron-10B / B4C / cBN PINN-MPC pool')
param clusterName string = 'aks-agent-infra-prod'

@description('Azure region for the Boron-10B & cBN HPHT agent node pool')
param location string = resourceGroup().location

@description('Dedicated GPU SKU for coupled BF3-DME 10B/11B chemical exchange distillation, 2400C B4C arc furnace & 5.5 GPa HPHT cBN PINN-MPC')
param vmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum node count for high-availability SIL-3 dual-redundant edge inference')
@minValue(2)
@maxValue(32)
param minCount int = 2

@description('Maximum node count for multi-column 10B enrichment cascade & HPHT press bays')
@minValue(2)
@maxValue(64)
param maxCount int = 12

@description('Maximum pods per node (sized for 10 kHz in-situ Raman 10B/11B isotope shift, TDLAS BF3/B2H6/CO & LIBS streams)')
param maxPods int = 32

@description('OS disk size in GB (ephemeral NVMe for zero-jitter PINN weights & isotope column state checkpoints)')
param osDiskSizeGB int = 512

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource boron10bB4cCbnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'b10cbnsil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    osType: 'Linux'
    osSKU: 'Ubuntu'
    osDiskType: 'Ephemeral'
    osDiskSizeGB: osDiskSizeGB
    maxPods: maxPods
    mode: 'User'
    type: 'VirtualMachineScaleSets'
    scaleSetPriority: 'Regular'
    enableEncryptionAtHost: true
    enableUltraSSD: true
    workloadRuntime: 'KataMshvVmIsolation'
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
      allowedUnsafeSysctls: [
        'net.core.rmem_max'
        'net.core.wmem_max'
      ]
    }
    linuxOSConfig: {
      transparentHugePageEnabled: 'always'
      transparentHugePageDefrag: 'defer+madvise'
      swapFileSizeMB: 0
    }
    nodeLabels: {
      'agent.infra/domain': 'boron-10b-isotope-bf3-exchange-distillation-b4c-cbn-hpht'
      'agent.infra/governance': 'pinn-mpc-bf3-dme-10b-exchange-b4c-arc-cbn-hpht-nfpa86-sil3'
      'agent.infra/safety-standard': 'nfpa-86-osha-1910-119-iaea-ssg-2-semi-s2-iec-61511-sil3'
      'agent.infra/telemetry-loop': '10khz-insitu-raman-10b-11b-tdlas-bf3-b2h6-co-libs-edge'
      'agent.infra/gpu-accelerator': 'nvidia-h100-nvl-94gb'
      'agent.infra/interlock-latency-ms': '0.27'
    }
    nodeTaints: [
      'agent.infra/boron-10b-b4c-cbn-sil3=dedicated:NoSchedule'
    ]
    tags: {
      workload: 'boron-10b-isotope-bf3-exchange-distillation-b4c-cbn-hpht-pinn-mpc'
      safetyStandard: 'NFPA-86-OSHA-1910.119-IAEA-SSG-2-SEMI-S2-IEC-61511-SIL-3'
      chapter: '195'
      blueprintNumber: '191'
      cycle: '190'
    }
  }
}

output poolName string = boron10bB4cCbnPool.name
output poolResourceId string = boron10bB4cCbnPool.id
output governanceMode string = 'pinn_mpc_bf3_dimethyl_ether_10b_exchange_distillation_b4c_arc_cbn_hpht_nfpa86_sil3_edge'
output sil3InterlockLatencyMs string = '0.27'
