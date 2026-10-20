// Blueprint #95: Autonomous Long-Duration Pumped Thermal Electricity Storage (PTES / Carnot Battery)
// Reversible Brayton Turbocompressor Surge-Margin, Packed-Bed Thermocline PINN-MPC & ASME/API 670/IEC 61511 SIL-3 Pool
targetScope = 'resourceGroup'

@description('Azure region for the PTES Carnot Battery & Brayton Turbocompressor Agent AKS cluster')
param location string = resourceGroup().location

@description('Environment prefix for PTES Brayton turbocompressor & thermocline resources')
param envPrefix string = 'ptessil3'

@description('AKS Kubernetes version with Kata VM + GPU Operator support')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM SKU')
param systemVmSize string = 'Standard_D8s_v5'

@description('GPU simulation node pool VM SKU for Brayton turbocompressor CFD & packed-bed thermocline PINN twins')
param gpuSimVmSize string = 'Standard_ND96isr_H100_v5'

@description('Initial GPU node count for PTES Brayton turbocompressor & thermocline digital twins')
@minValue(1)
@maxValue(32)
param gpuNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: '${envPrefix}-aksclaw-cluster'
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
    dnsPrefix: '${envPrefix}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
     securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        logAnalyticsWorkspaceResourceId: ''
        securityMonitoring: {
          enabled: false
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
      }
    ]
  }
}

resource gpuPtesSimPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'ptessim'
  properties: {
    count: gpuNodeCount
    vmSize: gpuSimVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 1
    maxCount: 32
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-gpu-ptes-carnot-battery-brayton-turbocompressor-sil3'
      'agent.aksclaw.io/domain': 'ptes-carnot-battery-brayton-thermocline-asme-api670-sil3'
      'agent.aksclaw.io/safety-standard': 'asme-ptc10-api670-iec61511-sil3-antisurge'
      'agent.aksclaw.io/edge-link': 'highfreq-dynamic-pressure-dts-fiber-magnetic-bearing-azure-local'
    }
    nodeTaints: [
      'aksclaw.io/ptes-carnot-gpu=true:NoSchedule'
    ]
  }
}

output clusterName string = aksCluster.name
output gpuPoolName string = gpuPtesSimPool.name
output isolationClass string = 'kata-qemu-sev-snp-gpu-ptes-carnot-battery-sil3'
