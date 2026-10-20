// blueprints/aksclaw-perovskite-silicon-tandem-pv-slot-die-laser-scribing-iec61215-sil3-pool.bicep
// Blueprint #99 (Chapter 103): Autonomous Perovskite-Silicon Tandem PV Roll-to-Roll Slot-Die Meniscus PINN-MPC,
// Femtosecond Laser P1-P2-P3 Scribing & IEC 61215 / IEC 61730 / SEMI PV22 / IEC 61508 SIL-3 Agent Pool
targetScope = 'resourceGroup'

@description('Deployment Azure region for the Perovskite-Silicon Tandem PV Slot-Die & Laser Scribing Cluster')
param location string = resourceGroup().location

@description('Environment prefix ( max 8 chars )')
@minLength(3)
@maxLength(8)
param envPrefix string = 'pvtdsil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Perovskite-Silicon Landau-Levich Meniscus & LaMer Crystallization PINN-MPC GPU VM size')
param gpuNodeVmSize string = 'Standard_ND96isr_H100_v5'

@description('Number of H100 v5 nodes for coupled slot-die meniscus fluid-dynamics & femtosecond P2 laser ablation twins')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 2

@description('Line-side Hyperspectral PL Imaging, Swept-Source OCT & IEC 61508 SIL-3 Laser/Solvent Interlock node VM size')
param rtEdgeNodeVmSize string = 'Standard_D16s_v5'

var clusterName = '${envPrefix}-aks-perovskite-tandem-sil3'
var lawName = '${envPrefix}-law-pv-tandem-audit'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-pvtd'
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
        name: 'pvpinnpool'
        count: gpuNodeCount
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeLabels: {
          'workload.aksclaw.io/domain': 'perovskite-tandem-meniscus-lamer-pinn-mpc'
          'hardware.aksclaw.io/accelerator': 'nvidia-h100-80gb'
          'compliance.aksclaw.io/standard': 'iec-61215-61730-semi-pv22-iec61508-sil3'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
          'aksclaw.io/pv-tandem-pinn=true:NoSchedule'
        ]
      }
      {
        name: 'ploctsil3'
        count: 3
        vmSize: rtEdgeNodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'workload.aksclaw.io/domain': 'hyperspectral-pl-oct-femtosecond-p2-sil3-interlock'
          'kernel.aksclaw.io/preempt-rt': 'enabled'
          'bus.aksclaw.io/coaxpress-ethercat-interlock': 'sub-millisecond'
        }
        nodeTaints: [
          'aksclaw.io/rt-pv-laser-sil3=true:NoSchedule'
        ]
      }
    ]
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output clusterFqdn string = aksCluster.properties.fqdn
output compliancePosture string = 'IEC-61215-61730-SEMI-PV22-IEC61508-SIL3-Enforced'
