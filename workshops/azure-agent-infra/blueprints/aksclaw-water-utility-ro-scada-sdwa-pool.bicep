// Blueprint #54: Autonomous Municipal Water Treatment, Desalination Reverse-Osmosis (RO)
// Membrane Fouling MPC, Acoustic Leak Triage & EPA SDWA Chemical Dosing Interlock Agent Pool
targetScope = 'resourceGroup'

@description('AKS cluster name for municipal water treatment & RO desalination agents')
param clusterName string = 'aksclaw-water-utility-ro-sdwa'

@description('Azure region for sovereign regional deployment')
param location string = resourceGroup().location

@description('Daily municipal & desalination water capacity in Megaliters per Day (MLD)')
@minValue(50)
@maxValue(5000)
param dailyWaterCapacityMld int = 500

@description('VM SKU for EPANET hydraulic PINN & RO transmembrane pressure optimization')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

var gpuNodeCount = max(2, (dailyWaterCapacityMld + 124) / 125)

resource aksWaterUtilityPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/watersdwa'
  properties: {
    count: gpuNodeCount
    vmSize: gpuNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    nodeLabels: {
      'agent.azure.com/domain': 'municipal-water-ro-scada-sdwa'
      'agent.azure.com/ro-mpc': 'transmembrane-fouling-sec'
      'agent.azure.com/epa-sdwa-gate': 'chlorine-0.2-to-4.0-mg-l-clamped'
      'agent.azure.com/acoustic-edge': 'hydrophone-cross-correlation'
    }
    nodeTaints: [
      'water.azure.com/epa-sdwa-scada=true:NoSchedule'
    ]
  }
}

output waterUtilityGpuNodeCount int = gpuNodeCount
output epaSdwaChlorineClampRangeMgL string = '0.2-4.0'
output maxFinishedWaterTurbidityNtu string = '0.3'
