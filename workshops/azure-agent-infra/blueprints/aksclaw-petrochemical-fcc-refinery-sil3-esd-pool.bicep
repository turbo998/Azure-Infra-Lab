// Blueprint #68: Petrochemical Refinery Fluid Catalytic Cracking (FCC), Reactor-Regenerator Coke Burnoff & API RP 554 / IEC 61511 SIL-3 Catalyst-Reversal ESD Pool
// Workload: Coupled Riser-Reactor / Regenerator Fluidization MPC + Online NIR/Raman Octane Soft-Sensor + 1.6ms API RP 554 / IEC 61511 SIL-3 Slide-Valve ΔP Interlock

param clusterName string = 'aksclaw-petro-fcc-sil3-pool'
param location string = resourceGroup().location
param nodeVmSize string = 'Standard_NC24ads_A100_v4'
param nodeCount int = 2

resource aksPetroFccPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/petrofccpool'
  properties: {
    count: nodeCount
    vmSize: nodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'agent.infra/workload': 'petrochemical-fcc-refinery-sil3-esd-sandbox'
      'agent.infra/isolation': 'kata-mshv-vm'
      'agent.infra/refinery-protocol': 'opcua-pubsub-modbus-tcp-raman-nir-chemometrics'
      'agent.infra/safety-interlock': 'api-rp-554-iec-61511-sil3-slide-valve-dp-esd'
    }
    nodeTaints: [
      'agent.infra/petro-fcc-sil3=true:NoSchedule'
    ]
  }
}

output poolName string = aksPetroFccPool.name
output isolationRuntime string = 'KataMshvVmIsolation'
output safetyStandard string = 'API-RP-554-IEC-61511-SIL3-Slide-Valve-Catalyst-Reversal-ESD'
