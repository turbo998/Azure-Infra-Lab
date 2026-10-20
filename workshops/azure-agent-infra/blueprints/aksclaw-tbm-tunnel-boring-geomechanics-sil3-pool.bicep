// ============================================================================
// Blueprint #67: AKSClaw Subterranean Tunnel Boring Machine (TBM) Geomechanics,
// GPR Ahead-of-Face Karst Inversion, EPB Chamber MPC & ISO 19296 / SIL-3 Pool
// ============================================================================
// Provisions an Azure Kubernetes Service (AKS) hybrid node pool for autonomous
// Tunnel Boring Machine (TBM) geomechanics digital twins, 3D Ground-Penetrating
// Radar (GPR) & seismic ahead-of-face karst/fault full-waveform inversion,
// Earth-Pressure-Balance (EPB) / slurry chamber pressure MPC, and ISO 19296 /
// IEC 61508 SIL-3 cutterhead over-torque & surface settlement interlocks.
// ============================================================================

@description('Target Azure region for the TBM geomechanics control plane')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aksclaw-tbm-geomechanics-prod'

@description('VM SKU for 3D GPR full-waveform inversion and EPB face-pressure MPC')
param tbmVmSize string = 'Standard_NC24ads_A100_v4'

@description('Initial node count for the TBM geomechanics pool')
@minValue(1)
@maxValue(32)
param nodeCount int = 2

@description('Maximum cutterhead torque stall ratio before SIL-3 thrust/rotation interlock')
param maxCutterheadTorqueRatio string = '0.92'

@description('Maximum surface InSAR / inclinometer settlement (mm) before EPB chamber boost')
param maxSurfaceSettlementMm string = '10.0'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource tbmGeomechanicsPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'tbmsil3pool'
  properties: {
    count: nodeCount
    vmSize: tbmVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 1
    maxCount: 32
    maxPods: 30
    nodeLabels: {
      'agent.infra/workload': 'tbm-tunnel-boring-geomechanics-sil3'
      'agent.infra/physics-engine': 'gpr-fwi-epb-chamber-mpc'
      'agent.infra/safety-interlock': 'iso-19296-iec-61508-sil3-plc'
      'agent.infra/max-torque-ratio': maxCutterheadTorqueRatio
      'agent.infra/max-settlement-mm': maxSurfaceSettlementMm
    }
    nodeTaints: [
      'agent.infra/tbm-geomechanics=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolName string = tbmGeomechanicsPool.name
output poolResourceId string = tbmGeomechanicsPool.id
output safetyEnvelope string = 'ISO-19296-SIL3:Torque<=${maxCutterheadTorqueRatio};Settlement<=${maxSurfaceSettlementMm}mm;Interlock<=1.7ms'
