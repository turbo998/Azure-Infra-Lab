// ============================================================================
// Blueprint #65: Autonomous Geothermal EGS Hydraulic Stimulation, Induced-Seismicity
// Traffic-Light System (TLS), Supercritical CO2 Binary Turbine & IEC 61511 SIL-3 Pool
// Target: Azure Kubernetes Service (AKS) + Borehole DAS/DTS Edge + SIL-3 Wellhead PLC
// ============================================================================

@description('Azure region for the Geothermal EGS & Induced-Seismicity Control Plane')
param location string = resourceGroup().location

@description('Environment prefix for Geothermal EGS Agent resources')
param envPrefix string = 'aksclaw-geothermal-egs'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('GPU node count for Coupled THM Fracture PINN & Microseismic Moment-Tensor Inversion')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 4

@description('Minimum induced-seismicity moment magnitude (Mw * 10) triggering TLS amber/red bleed-off')
param tlsTriggerMwTimes10 int = 21

@description('Maximum IEC 61511 SIL-3 wellhead bleed-off & H2S isolation latency budget in milliseconds')
param maxSil3WellheadBleedoffMs int = 3

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource egsAks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: '${envPrefix}-aks'
  location: location
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
        AvailabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'thmmsigpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        enableEncryptionAtHost: true
        nodeLabels: {
          'agent.azure.com/workload': 'geothermal-egs-thm-tls-pinn'
          'agent.azure.com/borehole-das-dts': 'enabled'
        }
        nodeTaints: [
          'geothermal.azure.com/gpu=true:NoSchedule'
        ]
      }
      {
        name: 'wellheadkata'
        count: 4
        vmSize: 'Standard_D16s_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        enableEncryptionAtHost: true
        nodeLabels: {
          'agent.azure.com/workload': 'wellhead-sil3-tls-interlock-sandbox'
          'runtime.azure.com/isolation': 'kata-mshv'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
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

output aksClusterName string = egsAks.name
output tlsTriggerMwTimes10Out int = tlsTriggerMwTimes10
output maxSil3WellheadBleedoffMsOut int = maxSil3WellheadBleedoffMs
