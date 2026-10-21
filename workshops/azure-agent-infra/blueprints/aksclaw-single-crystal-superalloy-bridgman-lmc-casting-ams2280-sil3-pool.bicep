// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #108 (Cycle #107 / Ch. 112)
// Autonomous Single-Crystal Superalloy Directional Solidification & Liquid-Metal
// Cooling (Bridgman-LMC) Turbine Blade Investment Casting, Mushy-Zone Thermal
// Gradient (G/R) & Freckle Defect Suppression PINN-MPC, Real-Time High-Energy
// X-Ray Radioscopy / Neutron Diffraction PDAS Tomography & AMS 2280 / NADCAP /
// NFPA 86 / IEC 61511 SIL-3 Vacuum Induction Melt Pour-Abort & Liquid-Tin
// Quench Bath Interlock Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Deployment region for the Single-Crystal Superalloy Bridgman-LMC Investment Casting Agent Pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the Kata Pod VM single-crystal turbine blade casting sandboxes')
param aksClusterName string = 'aks-sx-superalloy-bridgman-lmc-sil3'

@description('Number of active single-crystal vacuum induction Bridgman-LMC furnaces (1 to 128)')
@minValue(1)
@maxValue(128)
param sxBridgmanFurnaces int = 16

@description('VM SKU for Mushy-Zone G/R & Freckle Defect PINN-MPC and High-Energy X-Ray Radioscopy PDAS Tomography')
param gpuNodeVmSize string = 'Standard_NV36ads_A10_v5'

var gpuNodeCount = max(2, (sxBridgmanFurnaces + 7) / 8)

resource existingAks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource sxSuperalloyBridgmanPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: existingAks
  name: 'sxbridgpool'
  properties: {
    count: gpuNodeCount
    vmSize: gpuNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'agent.azure.com/domain': 'single-crystal-superalloy-bridgman-lmc-turbine-casting'
      'agent.azure.com/physics-engine': 'pinn-mpc-mushy-zone-gr-pdas-rayleigh-freckle-suppression'
      'agent.azure.com/ndt-metrology': 'high-energy-xray-radioscopy-laue-misorientation-tomography'
      'agent.azure.com/safety-interlock': 'ams2280-nadcap-nfpa86-iec61511-sil3-vim-pour-lmc-tin-quench'
      'agent.azure.com/furnaces': string(sxBridgmanFurnaces)
    }
    nodeTaints: [
      'sku=sx-superalloy-bridgman-lmc-sil3:NoSchedule'
    ]
  }
}

output poolResourceId string = sxSuperalloyBridgmanPool.id
output configuredGpuNodes int = gpuNodeCount
output safetyStandard string = 'AMS 2280 / NADCAP AC7114 / NFPA 86 / IEC 61511 SIL-3 Vacuum Induction Melt & Liquid-Tin LMC Quench Hard Interlock (0.4 ms)'
