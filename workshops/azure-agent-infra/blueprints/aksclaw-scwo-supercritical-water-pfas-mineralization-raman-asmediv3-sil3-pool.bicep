// blueprints/aksclaw-scwo-supercritical-water-pfas-mineralization-raman-asmediv3-sil3-pool.bicep
// Blueprint #121: Supercritical Water Oxidation (SCWO 374-650 C, 22.1-30.0 MPa) PFAS Complete Mineralization Reactor,
// Transcritical Salt Precipitation & Transpiration-Wall PINN-MPC, In-Line High-Pressure Raman & ASME Div. 3 / EPA PFAS / SIL-3 Interlock Pool
targetScope = 'resourceGroup'

@description('Azure region for the SCWO PFAS Mineralization cluster')
param location string = resourceGroup().location

@description('Environment name')
@allowed(['prod-scwo-sil3', 'staging-scwo-twin', 'epa-pfas-destruction'])
param environment string = 'prod-scwo-sil3'

@description('AKS cluster name for SCWO PFAS PINN-MPC & High-Pressure Raman pods')
param aksClusterName string = 'aks-scwo-pfas-sil3'

@description('Target Destruction and Removal Efficiency (DRE) for C-F bond mineralization (%)')
param targetPfasDrePct string = '99.9999'

@description('Maximum supercritical reactor pressure (MPa) before ASME Div. 3 SIL-3 letdown quench')
param maxReactorPressureMpa string = '28.5'

@description('Minimum subcritical transpiration water film thickness (mm) to prevent salt plugging and HF wall attack')
param minTranspirationFilmMm string = '1.25'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource scwoPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'scwopinn'
  properties: {
    count: 4
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableUltraSSD: true
    availabilityZones: ['1', '2', '3']
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-mshv'
      'agent.aksclaw.io/domain': 'scwo-pfas-transpiration-wall-pinn-mpc'
      'epa.pfas/dre-target': 'six-nines-99.9999pct'
      'safety.iec61511/sil-rating': 'SIL-3'
    }
    nodeTaints: [
      'scwo.aksclaw.io/pfas-pinn=true:NoSchedule'
    ]
    tags: {
      blueprintId: '121'
      cycleId: '120'
      chapter: '125'
      targetPfasDrePct: targetPfasDrePct
      maxReactorPressureMpa: maxReactorPressureMpa
      minTranspirationFilmMm: minTranspirationFilmMm
      safetyStandard: 'ASME-SecVIII-Div3-EPA-PFAS-SIL3'
    }
  }
}

resource scwoSil3EdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'scwosil3'
  properties: {
    count: 3
    vmSize: 'Standard_D16ds_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    availabilityZones: ['1', '2', '3']
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-mshv'
      'agent.aksclaw.io/domain': 'scwo-hf-quench-asmediv3-sil3'
      'safety.asmediv3/letdown-interlock': 'enabled'
    }
    nodeTaints: [
      'safety.aksclaw.io/sil3-interlock=true:NoSchedule'
    ]
  }
}

output blueprintId int = 121
output scwoPinnPoolId string = scwoPinnPool.id
output scwoSil3EdgePoolId string = scwoSil3EdgePool.id
