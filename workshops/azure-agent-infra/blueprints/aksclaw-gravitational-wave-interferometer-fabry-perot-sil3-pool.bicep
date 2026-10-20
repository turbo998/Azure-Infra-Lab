// blueprints/aksclaw-gravitational-wave-interferometer-fabry-perot-sil3-pool.bicep
// Blueprint #87: Autonomous Gravitational-Wave Laser Interferometer, Fabry-Perot Arm Cavity Locking,
// Newtonian Seismic Feedforward Cancellation & Squeezed-Vacuum IEC 61508 SIL-3 Agent Pool (Standard_ND96isr_H100_v5)

@description('Name of the existing AKS cluster hosting the gravitational-wave interferometer control agent pool')
param clusterName string

@description('Azure region for the gravitational-wave interferometer PINN-RL node pool')
param location string = resourceGroup().location

@description('VM SKU for coupled Fabry-Perot cavity locking RL & Newtonian seismic gravity-gradient PINN pods')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for warm gravitational-wave detector site digital-twin pods')
@minValue(2)
param minCount int = 2

@description('Maximum node count for burst multi-messenger GCN alert & teleseismic lock-recovery sweeps')
@maxValue(32)
param maxCount int = 12

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource gwInterferometerPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'gwinterfero'
  properties: {
    mode: 'User'
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    enableAutoScaling: true
    minCount: minCount
    maxCount: maxCount
    count: minCount
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'gravitational-wave-interferometer-fabry-perot-sil3'
      'agent.infra/domain': 'astrophysics-laser-interferometry-quantum-squeezing'
      'agent.infra/safety-interlock': 'iec61508-sil3-ansi-z136-class4-laser-quad-pendulum'
      'agent.infra/telemetry-bus': 'ligo-cds-dolphin-pcie-rfm-epics-pva-gwf'
      'agent.infra/gpu-topology': 'nd96isr-h100-v5-nvlink4'
    }
    nodeTaints: [
      'agent.infra/gravitational-wave-interferometer=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolName string = gwInterferometerPool.name
output poolResourceId string = gwInterferometerPool.id
output safetyInterlockStandard string = 'IEC-61508-SIL3-ANSI-Z136-1-Class4-Intracavity-Laser-Quad-Suspension-Latch'
