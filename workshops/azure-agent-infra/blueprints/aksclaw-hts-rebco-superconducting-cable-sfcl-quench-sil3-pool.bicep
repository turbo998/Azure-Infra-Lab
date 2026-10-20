// Blueprint #91: AKSClaw Grid-Scale High-Temperature Superconducting (HTS REBCO 2G) Fault-Current Limiter (SFCL) & Subcooled LN2 (65–77 K) Triaxial Superconducting Cable Agent Pool
// Chapter 95 — E-J Power-Law AC Loss & Normal-Zone Propagation Velocity (NZPV) Quench PINN-MPC, Subcooled LN2 (65 K, 1.5 MPa) Reverse-Brayton Cryo-Hydraulic Balancing & IEEE C37.302 / IEC 62814 / IEC 61508 SIL-3 High-Speed Bypass Vacuum Interrupter Interlock

@description('AKS cluster name for HTS REBCO Superconducting Cable & SFCL SIL-3 Agent Pool')
param clusterName string = 'aksclaw-hts-rebco-sfcl-sil3'

@description('Azure region for sovereign metropolitan grid superconducting corridor control plane')
param location string = resourceGroup().location

@description('VM SKU for E-J power-law AC loss / NZPV quench PINN-MPC & subcooled LN2 cryo-hydraulic control')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for HA urban gigawatt superconducting cable & SFCL loops')
@minValue(2)
@maxValue(32)
param minCount int = 2

@description('Maximum node count for multi-substation HTS REBCO transmission corridors')
@minValue(2)
@maxValue(64)
param maxCount int = 12

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource htsRebcoSfclPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'htsrebcosil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableUltraSSD: true
    maxPods: 32
    nodeLabels: {
      'aksclaw.io/workload-tier': 'hts-rebco-superconducting-cable-sfcl-quench-sil3'
      'aksclaw.io/cryo-telemetry': 'rayleigh-bofda-fbg-quench-voltage-tap-ln2-65k'
      'aksclaw.io/quench-solver': 'pinn-mpc-ej-powerlaw-nzpv-reverse-brayton-ln2'
      'aksclaw.io/safety-interlock': 'ieee-c37-302-iec-62814-sil3-fast-bypass-relief'
      'aksclaw.io/edge-fabric': 'iec61850-9-2le-cryostat-azure-local-substation-edge'
    }
    nodeTaints: [
      'aksclaw.io/hts-rebco-sfcl-sil3=true:NoSchedule'
    ]
    tags: {
      chapter: '95'
      blueprint: '91'
      domain: 'hts-rebco-superconducting-cable-sfcl-quench-sil3'
      safetyStandard: 'IEEE-C37-302-IEC-62814-IEC-61508-SIL-3'
    }
  }
}

output agentPoolId string = htsRebcoSfclPool.id
output agentPoolName string = htsRebcoSfclPool.name
output isolationRuntime string = htsRebcoSfclPool.properties.workloadRuntime
