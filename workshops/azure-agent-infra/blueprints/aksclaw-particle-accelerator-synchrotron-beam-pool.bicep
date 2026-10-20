// =============================================================================
// Blueprint #62: AKSClaw Synchrotron Light Source & XFEL Particle Accelerator
// Fast Orbit Feedback, SRF Cryomodule Microphonics MPC & IEC 61508 SIL-3 MPS Beam-Dump Pool
// =============================================================================

@description('AKS cluster name hosting the synchrotron & XFEL accelerator agent pool')
param clusterName string = 'aksclaw-accelerator-xfel-prod'

@description('Location for the accelerator control agent pool')
param location string = resourceGroup().location

@description('Node count for the Standard_NC24ads_A100_v4 accelerator beamline control pool')
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource acceleratorBeamPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'xfelbeam'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'particle-accelerator-synchrotron-beam-agent'
      'aksclaw.io/fofb-srf-microphonics-mpc': 'enabled-42.8pct-emittance-stability-34.5pct-rf-power-cut'
      'aksclaw.io/iec61508-sil3-mps-beam-dump': 'enforced-0.05ms-blm-kicker-zero-undulator-demagnetization'
      'aksclaw.io/epics-pvaccess-xray-detector-edge': 'enabled-1.8ms-97.9pct-wan-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/particle-accelerator=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '33%'
    }
  }
}

output poolLocation string = location
output acceleratorBeamPoolResourceId string = acceleratorBeamPool.id
