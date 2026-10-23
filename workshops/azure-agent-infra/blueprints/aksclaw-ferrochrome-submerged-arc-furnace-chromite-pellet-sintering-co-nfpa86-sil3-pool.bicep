// ============================================================================
// Blueprint #179: AKSClaw Autonomous Closed Submerged Arc Furnace (SAF 75 MVA
// Soderberg Self-Baking Electrodes) High-Carbon Ferrochrome (HC-FeCr 1,650-1,750 C)
// & Steel-Belt Chromite Pellet Sintering, Soderberg 480 C Baking Isotherm,
// Coke-Bed Conductivity & MgO-Al2O3-SiO2 Slag PINN-MPC & NFPA 86 / OSHA 1910.1026
// / ISO 13577 / IEC 61511 SIL-3 Soft-Break & CO-H2 Hood Interlock Pool (Cycle #178)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the AKSClaw Ferrochrome SAF & Chromite Sintering cluster')
param location string = resourceGroup().location

@description('Environment prefix for Ferrochrome SAF PINN-MPC pool')
param envPrefix string = 'fecrsafpinn'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

var clusterName = '${envPrefix}-aksclaw-fecr-saf-sil3'
var pinnPoolName = 'fecrsafpinn'

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
          'workload-tier': 'ferrochrome-saf-soderberg-electrode-coke-bed-chromite-pinn-mpc'
          'interlock-standard': 'nfpa-86-osha-1910-1026-iso-13577-iec-61511-sil3'
          'metrology-bus': 'electrode-harmonic-casing-ae-tdlas-co-o2-h2-libs-cr-fe-10khz'
          'smelting-stage': '75mva-closed-saf-1700c-soderberg-480c-baking-zone-hc-fecr'
        }
        nodeTaints: [
          'dedicated=fecrsafpinn:NoSchedule'
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
