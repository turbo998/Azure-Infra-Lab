@description('Azure region for the AKSamaritan Subsea Cable Laying, Plough Trenching & OTDR/DAS Fault Localization Agent Sandbox cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Subsea HVDC / Submarine Fiber-Optic Cable Laying & Plough Trenching agent sandboxes')
param clusterName string = 'aksclaw-subsea-cablelay-sil3'

@description('VM size for Catenary Touchdown Point (TDP) Tension PINN, Subsea Plough Soil-Cutting MPC & Coherent OTDR/DAS Strain Localization')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for 24x7 Cable-Lay Vessel (CLV) DP-3 Catenary & Plough Trenching agent pods')
@minValue(2)
@maxValue(64)
param minCount int = 2

@description('Maximum node count for multi-vessel subsea interconnector & transoceanic fiber campaign bursts')
@minValue(2)
@maxValue(128)
param maxCount int = 16

@description('Minimum allowable cable bending radius (MBR) in meters before DNV-ST-F101 / CIGRE TB 610 chute interlock')
param minBendingRadiusMeters string = '3.5'

@description('Maximum allowable subsea plough tow tension in kilonewtons (kN) before IEC 61508 SIL-3 tow-winch render & jetting override')
param maxPloughTowTensionKn string = '850.0'

resource aksCableLayPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  name: '${clusterName}/cablelay'
  properties: {
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    scaleSetPriority: 'Regular'
    nodeLabels: {
      'agent.aksclaw.io/runtime': 'kata-cc-snr'
      'agent.aksclaw.io/domain': 'subsea-cable-lay-plough-otdr-das-dnv-sil3'
      'agent.aksclaw.io/physics-engine': 'catenary-tdp-plough-soil-pinn-cotdr-das-mpc'
      'agent.aksclaw.io/safety-interlock': 'dnv-st-f101-cigre-tb610-imca-m103-dp3-sil3'
      'agent.aksclaw.io/sensor-fabric': 'cotdr-das-brillouin-botda-tensioner-lcell-usbl-edge'
    }
    nodeTaints: [
      'agent.aksclaw.io/subsea-cablelay=true:NoSchedule'
    ]
    tags: {
      workload: 'Subsea-Cable-Lay-Plough-OTDR-DAS-Agent-Sandbox'
      compliance: 'DNV-ST-F101-CIGRE-TB610-IMCA-M103-DP3-SIL3'
      minBendingRadiusMeters: minBendingRadiusMeters
      maxPloughTowTensionKn: maxPloughTowTensionKn
    }
  }
}

output agentPoolId string = aksCableLayPool.id
output isolationRuntime string = 'KataMshvVmIsolation'
output safetyCompliance string = 'DNV-ST-F101-CIGRE-TB610-IMCA-M103-DP3-SIL3'
