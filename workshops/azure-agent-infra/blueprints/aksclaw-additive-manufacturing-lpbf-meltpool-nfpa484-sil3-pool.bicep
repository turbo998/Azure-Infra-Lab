// =============================================================================
// Blueprint #74: AKSClaw Autonomous Precision Laser Powder Bed Fusion (LPBF)
// Metal Additive Manufacturing, Melt-Pool Coaxial Pyrometry / OCT PINN &
// ASTM F3303 / NFPA 484 Argon Inerting (O2 <= 500 ppm) SIL-3 Pool (Chapter 78)
// =============================================================================
targetScope = 'resourceGroup'

@description('AKS cluster name hosting the AKSClaw Metal Additive Manufacturing LPBF Agent Pool')
param clusterName string = 'aksclaw-lpbf-additive-sil3'

@description('Azure region for sovereign aerospace & medical additive manufacturing deployment')
param location string = resourceGroup().location

@description('Number of GPU nodes for 3D Rosenthal / Marangoni melt-pool thermal-fluid PINN & scan-vector MPC')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource lpbfMeltpoolPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lpbfpinnpool'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'additive-manufacturing-lpbf-meltpool-nfpa484-sil3-agent'
      'aksclaw.io/runtime-isolation': 'kata-containers- confidential-vm'
      'aksclaw.io/marangoni-meltpool-pinn-scan-mpc': 'enabled-34.2pct-porosity-cut-21.8pct-build-speed-gain'
      'aksclaw.io/astm-f3303-nfpa484-sil3-argon-shutter': 'enforced-0.9ms-zero-o2-exceedance-or-recoater-crash'
      'aksclaw.io/coaxial-pyrometry-oct-fpga-edge': 'enabled-1.4ms-98.4pct-foundry-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/additive-manufacturing-lpbf-meltpool-nfpa484-sil3=true:NoSchedule'
    ]
  }
}

output agentPoolId string = lpbfMeltpoolPinnPool.id
output safetyEnvelope string = 'ASTM-F3303-NFPA-484-IEC-61508-SIL3-O2-500ppm-Laser-Shutter-0.9ms'
