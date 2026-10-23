// ============================================================================
// Blueprint #178: AKSClaw Autonomous Tin Ausmelt/IsaSmelt Top-Submerged Lance
// (TSL) Bath Smelting (1,180-1,320 C), Fuming Furnace SnS Volatilization,
// Multi-Stage Vacuum Distillation Pb/Bi/As Removal (1,150 C, 5-15 Pa) &
// Fluorosilicic Acid Electrolytic Refining 4N 99.99% Sn PINN-MPC &
// NFPA 86 / OSHA 1910.1018 / ASME BPVC VIII / IEC 61511 SIL-3 Pool (Cycle #177)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the AKSClaw Tin TSL Bath Smelting & Vacuum Distillation cluster')
param location string = resourceGroup().location

@description('Environment prefix for Tin TSL & Vacuum Distillation PINN-MPC pool')
param envPrefix string = 'tintslpinn'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

var clusterName = '${envPrefix}-aksclaw-tin-tsl-sil3'
var pinnPoolName = 'tintslpinn'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: pinnPoolName
        count: 4
        minCount: 4
        maxCount: 16
        enableAutoScaling: true
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'workload-tier': 'tin-tsl-ausmelt-bath-smelting-vacuum-distillation-pinn-mpc'
          'interlock-standard': 'nfpa-86-osha-1910-1018-asme-bpvc-viii-iec-61511-sil3'
          'metrology-bus': 'lance-ae-slag-freeze-libs-sno-qcl-tdlas-so2-as2o3-co-10khz'
          'smelting-stage': 'tsl-1280c-reduction-sns-fuming-1150c-5pa-vacuum-distillation-4n-sn'
        }
        nodeTaints: [
          'dedicated=tintslpinn:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
    }
  }
}

output clusterResourceId string = aksCluster.id
output pinnNodePoolName string = pinnPoolName
