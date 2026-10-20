// ============================================================================
// Blueprint #51: AKSClaw Autonomous Mining AHS, ISO 21815 Collision-Avoidance,
// Ore-Grade XRF Kriging Blending & Geotechnical Slope-Radar Interlock Pool
// Chapter 55 Reference Implementation (Azure Local Mine-Rim Edge + NC24ads_A100_v4)
// ============================================================================

@description('Deployment region for the Autonomous Mining AHS & Slope-Radar Agent Pool')
param location string = resourceGroup().location

@description('AKS cluster name for mining AHS cuOpt dispatch & georadar interlock')
param clusterName string = 'aks-aksclaw-mining-ahs-iso21815'

@description('Active autonomous haul trucks (30 / 120 / 480 320-ton Ultra-Class AHS trucks)')
@minValue(10)
@maxValue(2000)
param autonomousHaulTrucks int = 120

@description('VM SKU for cuOpt truck-shovel-crusher MILP & 3D block-model Kriging')
param solverVmSize string = 'Standard_NC24ads_A100_v4'

var solverNodeCount = max(2, (autonomousHaulTrucks + 29) / 30)

resource miningAhsAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  name: '${clusterName}/miningahs'
  properties: {
    count: solverNodeCount
    vmSize: solverVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-tier': 'mining-ahs-iso21815-georadar'
      'aksclaw.io/cuopt-haul-dispatch-target-sec': '4.2'
      'aksclaw.io/iso21815-emesrt-level9-interlock-ms': '2.2'
      'aksclaw.io/ssr-insar-slope-triage-ms': '18.0'
      'aksclaw.io/xrf-grade-variance-reduction-pct': '64.0'
    }
    nodeTaints: [
      'aksclaw.io/mining-ahs=true:NoSchedule'
    ]
  }
}

output miningSolverNodes int = solverNodeCount
output targetHaulDispatchSec string = '4.2'
output iso21815CollisionInterlockMs string = '2.2'
output slopeRadarTriageMs string = '18.0'
