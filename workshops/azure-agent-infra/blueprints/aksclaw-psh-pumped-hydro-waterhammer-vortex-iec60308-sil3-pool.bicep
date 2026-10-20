@description('Azure region for the AKSClaw Pumped-Storage Hydropower (PSH) Reversible Pump-Turbine & Surge-Tank Water-Hammer Agent Sandbox cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Pumped-Storage Hydropower Variable-Speed Francis Pump-Turbine & Penstock Water-Hammer agent sandboxes')
param clusterName string = 'aksclaw-psh-hydro-sil3'

@description('VM size for 1D Method-of-Characteristics (MOC) Water-Hammer & 3D S-Region Vortex-Rope PINN-MPC')
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Minimum node count for 24x7 underground powerhouse DFIM pump-turbine & governor pods')
@minValue(2)
@maxValue(64)
param minCount int = 2

@description('Maximum node count for multi-cascade pumped-storage & hydro-wind-solar grid-balancing bursts')
@minValue(2)
@maxValue(128)
param maxCount int = 16

@description('Maximum allowable spiral-case penstock transient pressure rise in MPa before IEC 60308 / SIL-3 multi-stage wicket-gate Cushion-Law interlock')
param maxSpiralCasePressureMpa string = '9.80'

@description('Minimum allowable tailrace draft-tube pressure above vapor pressure in kPa before cavitation column-separation air-admission valve interlock')
param minDraftTubeSubmergenceKpa string = '45.0'

resource aksPshHydroPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  name: '${clusterName}/pshturbine'
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
      'agent.aksclaw.io/domain': 'psh-pumped-hydro-waterhammer-vortex-iec60308-sil3'
      'agent.aksclaw.io/physics-engine': 'allievi-moc-waterhammer-sregion-vortex-pinn-dfim-mpc'
      'agent.aksclaw.io/safety-interlock': 'ieee1020-iec60308-asme-ptc18-sil3-wicket-penstock'
      'agent.aksclaw.io/sensor-fabric': 'piezo-dynamic-pressure-shaft-orbit-acoustics-iec61850-edge'
    }
    nodeTaints: [
      'agent.aksclaw.io/psh-hydro=true:NoSchedule'
    ]
    tags: {
      workload: 'PSH-Pumped-Hydro-WaterHammer-Vortex-Agent-Sandbox'
      compliance: 'IEEE-1020-IEC-60308-ASME-PTC-18-SIL3'
      maxSpiralCasePressureMpa: maxSpiralCasePressureMpa
      minDraftTubeSubmergenceKpa: minDraftTubeSubmergenceKpa
    }
  }
}

output agentPoolId string = aksPshHydroPool.id
output isolationRuntime string = 'KataMshvVmIsolation'
output safetyCompliance string = 'IEEE-1020-IEC-60308-ASME-PTC-18-SIL3'
