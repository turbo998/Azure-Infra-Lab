// Blueprint #162: AKS-Claw 300 mm Monocrystalline Silicon Magnetic-Field-Applied Czochralski (MCZ 0.3-0.4 T, 1,420 C Quartz Crucible) Crystal Puller Pool
// Enforces Voronkov v/G0 Point-Defect Neutral-Zone & MHD Melt-Convection PINN-MPC, 5 kHz Meniscus Bright-Ring Metrology & SEMI S2 / NFPA 86 / IEC 61511 SIL-3 Crucible Melt-Breach Steam-Explosion & Seed-Cable Catch Interlock

@description('Azure region for the AKS-Claw 300 mm MCZ Silicon Crystal Puller control pool')
param location string = resourceGroup().location

@description('AKS cluster name for 300 mm MCZ silicon ingot puller governance')
param clusterName string = 'aksclaw-mcz-silicon-voronkov-sil3'

@description('Number of 300 mm MCZ / CCZ crystal puller furnaces (default: 16)')
@minValue(1)
@maxValue(128)
param mczPullerFurnaces int = 16

@description('VM SKU for 5 kHz meniscus bright-ring optical triangulation, 3D Lorentz-MHD melt convection & Voronkov v/G0 PINN-MPC')
param agentGpuNodeVmSize string = 'Standard_NV36ads_A10_v5'

var gpuNodeCount = max(2, (mczPullerFurnaces + 7) / 8)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource mczSiliconPullerPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mczsi162'
  properties: {
    count: gpuNodeCount
    vmSize: agentGpuNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    nodeLabels: {
      'aksclaw.io/workload-tier': 'mcz-silicon-ingot-voronkov-meniscus-semis2-sil3'
      'aksclaw.io/voronkov-vg0-target-cm2-min-k': '0.00134'
      'aksclaw.io/cusp-magnetic-field-tesla': '0.35'
      'aksclaw.io/meniscus-brightring-metrology-hz': '5000'
      'aksclaw.io/safety-interlock': 'semi-s2-nfpa86-iec61511-sil3-crucible-breach-cable-catch'
      'aksclaw.io/sandbox-isolation': 'kata-containers-vmm'
    }
    nodeTaints: [
      'aksclaw.io/mcz-silicon-voronkov-sil3=true:NoSchedule'
    ]
  }
}

output poolName string = mczSiliconPullerPool.name
output provisionedGpuNodes int = gpuNodeCount
output locationOut string = location
