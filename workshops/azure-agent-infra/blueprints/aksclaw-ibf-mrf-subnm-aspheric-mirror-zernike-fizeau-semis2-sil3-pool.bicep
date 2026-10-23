@description('Azure region for the AKSClaw Sub-Nanometer IBF & MRF Aspheric/Freeform Ultra-Low-Expansion Optical Mirror Polishing, Tikhonov-Richardson-Lucy Dwell-Time Deconvolution & Phase-Shifting Fizeau CGH Null Interferometry Agent Pool')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the Sub-Nanometer IBF/MRF Optical Mirror PINN-MPC & SEMI S2/SIL-3 pool')
param aksClusterName string

@description('VM SKU for GPU-accelerated Tikhonov-Richardson-Lucy dwell-time deconvolution, Tool-Influence-Function (TIF) thermal footprint PINN-MPC, and 37-term Zernike + PSD mid-spatial frequency wavefront reconstruction')
param vmSize string = 'Standard_NV36ads_A10_v5'

@description('Minimum node count for high-availability IBF/MRF optical polishing cell twins')
param minCount int = 2

@description('Maximum node count for multi-cell EUV/astronomical mirror figuring campaigns')
param maxCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource ibfMrfOpticsPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ibfmrfsil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'agent.infra/domain': 'ibf-mrf-subnm-aspheric-mirror-zernike-fizeau'
      'agent.infra/physics-kernel': 'pinn-mpc-tikhonov-richardson-lucy-dwell-tif-zernike'
      'agent.infra/metrology-loop': '10khz-rf-ion-grid-and-fizeau-cgh-null-interferometry'
      'agent.infra/safety-interlock': 'semi-s2-iso-10110-ansi-z136-iec61511-sil3'
    }
    nodeTaints: [
      'agent.infra/ibf-mrf-optics-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = ibfMrfOpticsPool.id
output isolationRuntime string = ibfMrfOpticsPool.properties.workloadRuntime
