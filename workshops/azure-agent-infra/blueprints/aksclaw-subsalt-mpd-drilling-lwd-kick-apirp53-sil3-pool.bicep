// Blueprint #90: AKSClaw Ultra-Deep Subsalt Managed-Pressure Drilling (MPD), Wired-Drill-Pipe LWD, Kick-Influx Early Detection & API RP 53 / IEC 61511 SIL-3 BOP Agent Pool
// Chapter 94 — Subsalt narrow pore-pressure/fracture-gradient (PP-FG < 0.4 ppg) equivalent circulating density (ECD) PINN-MPC, Coriolis delta-flow kick detection, stick-slip mitigation & API RP 53 / IEC 61511 SIL-3 Automated Choke / Blind-Shear Ram BOP Interlock

@description('AKS cluster name for Subsalt MPD Drilling & API RP 53 SIL-3 Agent Pool')
param clusterName string = 'aksclaw-subsalt-mpd-sil3'

@description('Azure region for sovereign offshore drilling control-tower deployment')
param location string = resourceGroup().location

@description('VM SKU for downhole ECD multiphase hydraulics PINN-MPC & Coriolis delta-flow kick inference')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for HA ultra-deepwater drillship MPD loops')
@minValue(2)
@maxValue(32)
param minCount int = 2

@description('Maximum node count for multi-rig subsalt drilling campaigns')
@minValue(2)
@maxValue(64)
param maxCount int = 12

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource subsaltMpdPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mpdsil3'
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
      'aksclaw.io/workload-tier': 'subsalt-mpd-drilling-lwd-kick-apirp53-sil3'
      'aksclaw.io/downhole-telemetry': 'wired-drill-pipe-intelliserv-mud-pulse-lwd'
      'aksclaw.io/hydraulics-solver': 'pinn-mpc-ecd-coriolis-delta-flow-stick-slip'
      'aksclaw.io/safety-interlock': 'api-rp-53-iec-61511-sil3-mpd-choke-bop-bsr'
      'aksclaw.io/edge-fabric': 'witsml-opc-ua-azure-local-drillship-edge'
    }
    nodeTaints: [
      'aksclaw.io/subsalt-mpd-sil3=true:NoSchedule'
    ]
    tags: {
      chapter: '94'
      blueprint: '90'
      domain: 'subsalt-mpd-drilling-lwd-kick-apirp53-sil3'
      safetyStandard: 'API-RP-53-API-16D-IEC-61511-SIL-3'
    }
  }
}

output agentPoolId string = subsaltMpdPool.id
output agentPoolName string = subsaltMpdPool.name
output isolationRuntime string = subsaltMpdPool.properties.workloadRuntime
