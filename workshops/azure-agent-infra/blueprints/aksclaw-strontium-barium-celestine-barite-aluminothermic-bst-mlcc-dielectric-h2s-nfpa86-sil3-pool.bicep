// ============================================================================
// Blueprint #190: Autonomous Celestine (SrSO4) & Barite (BaSO4) Rotary-Kiln
// Carbothermic Black-Ash Reduction (SrS/BaS), Vacuum Aluminothermic Metallic
// Sr/Ba Distillation & Sub-80nm Hydrothermal Tetragonal Barium Strontium
// Titanate (Ba(1-x)Sr(x)TiO3, BT/BST) AI-GPU Multi-Layer Ceramic Capacitor
// (MLCC) Dielectric & 87Sr Optical-Lattice Clock Dispenser PINN-MPC, Online
// 10kHz In-Situ UV-Raman Tetragonal c/a Ratio, LIBS Ti/(Ba+Sr) Stoichiometry
// & TDLAS H2S/CO Metrology & NFPA 86 / NFPA 652 / OSHA 1910.119 / IEC 61511
// SIL-3 Lethal Hydrogen Sulfide (H2S) Scrubber, Pyrophoric Sr/Ba Vacuum Retort
// Argon Quench & Soluble Barium Containment Interlock Pool (Cycle #189)
// ============================================================================

@description('Azure region for the Strontium/Barium Aluminothermic Distillation & Sub-80nm BST MLCC Dielectric AKSClaw cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Sr/Ba Vacuum Retort, Hydrothermal BST/MLCC & 87Sr Atomic-Clock PINN-MPC')
param clusterName string = 'aksclaw-sr-ba-aluminothermic-bst-mlcc-sil3'

@description('Kubernetes version for AKS control plane and Kata Pod VM / GPU node pools')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC GPU node pool VM size (NVIDIA H100 NVL for carbothermic kiln & hydrothermal BST nucleation PINN)')
param pinnGpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Deterministic edge node pool VM size for 0.28ms NFPA 86/OSHA 1910.119/SIL-3 H2S scrubber & vacuum retort argon quench interlock')
param sil3EdgeVmSize string = 'Standard_F16s_v2'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'srbapinnpool'
        count: 4
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        enableEncryptionAtHost: true
        nodeLabels: {
          'agent.azure.com/workload': 'sr-ba-celestine-barite-aluminothermic-bst-mlcc-pinn-mpc'
          'alkaline.earth.domain/process': 'srso4-baso4-black-ash-aluminothermic-sr-hydrothermal-bst-mlcc'
          'alkaline.earth.domain/metrology': '10khz-insitu-uv-raman-ca-libs-ti-ba-sr-tdlas-h2s-co'
        }
        nodeTaints: [
          'dedicated=srbaPinnGpu:NoSchedule'
        ]
        availabilityZones: [
          '1'
          '2'
        ]
      }
      {
        name: 'sil3h2ssrbapool'
        count: 3
        vmSize: sil3EdgeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        enableUltraSSD: true
        nodeLabels: {
          'agent.azure.com/safety-tier': 'nfpa86-nfpa652-osha1910119-iec61511-sil3'
          'alkaline.earth.domain/interlock': 'lethal-h2s-naoh-h2o2-scrubber-vacuum-retort-argon-quench-ba-containment'
          'alkaline.earth.domain/latency-target-ms': '0.28'
        }
        nodeTaints: [
          'safety.sil3/interlock=true:NoExecute'
        ]
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output pinnNodePoolSku string = pinnGpuVmSize
output safetyStandard string = 'NFPA-86-NFPA-652-OSHA-1910.119-IEC-61511-SIL-3'
output targetInterlockLatencyMs string = '0.28'
output targetEdgeTelemetryLoopMs string = '0.20'
