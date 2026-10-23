// blueprints/aksclaw-ilmenite-dc-eaf-titania-slag-smelting-freeze-lining-boilover-nfpa86-sil3-pool.bicep
// Blueprint #177: DC-EAF Ilmenite Smelting (1,650-1,750 C High-Titania Slag 85-90% TiO2 & Pig Iron Bath),
// Open-Arc / Foaming-Slag Freeze-Lining Heat-Flux & FeO-Activity PINN-MPC, Online 10 kHz OES / Acoustic Arc Metrology &
// NFPA 86 / ISO 13577 / OSHA 1910.119 / IEC 61511 SIL-3 Slag Boilover, Freeze-Lining Breakout & Water-Cooled Roof Explosion Interlock Pool

targetScope = 'resourceGroup'

@description('Azure region for the DC-EAF Ilmenite Smelting & High-Titania Slag Freeze-Lining PINN-MPC AKS cluster')
param location string = resourceGroup().location

@description('AKS cluster name for autonomous DC-EAF ilmenite smelting & freeze-lining digital twin')
param clusterName string = 'aksclaw-ilmenite-dceaf-tio2-slag-nfpa86-sil3'

@description('Kubernetes version')
param kubernetesVersion string = '1.30.6'

@description('Furnace DC arc power rating (MW)')
@minValue(25)
@maxValue(95)
param dcArcPowerMw int = 72

@description('Target TiO2 grade in tapped titania slag (wt%)')
param targetSlagTio2Pct string = '87.5'

@description('Minimum freeze-lining solid crust thickness on magnesia brick wall (mm)')
@minValue(45)
@maxValue(160)
param minFreezeLiningThicknessMm int = 75

@description('Maximum allowable copper cooler heat flux before SIL-3 arc power step-down (kW/m2)')
@minValue(40)
@maxValue(120)
param maxWallHeatFluxKwM2 int = 65

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${clusterName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'ilmenite-dc-eaf-titania-slag-smelting-freeze-lining-pinn-mpc'
    safetyStandard: 'NFPA-86-ISO-13577-OSHA-1910.119-IEC-61511-SIL3'
    dcArcPowerMw: string(dcArcPowerMw)
    targetSlagTio2Pct: targetSlagTio2Pct
    minFreezeLiningThicknessMm: string(minFreezeLiningThicknessMm)
    maxWallHeatFluxKwM2: string(maxWallHeatFluxKwM2)
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
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
        name: 'tiopinn'
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
          'agent.azure.com/workload': 'ilmenite-dc-eaf-titania-slag-freeze-lining-pinn-mpc'
          'agent.azure.com/metrology': '10khz-oes-acoustic-arc-thermocouple-freeze-lining'
          'agent.azure.com/safety-interlock': 'nfpa86-iso13577-osha1910119-iec61511-sil3-breakout-boilover'
        }
        nodeTaints: [
          'dedicated=tiopinn:NoSchedule'
        ]
      }
      {
        name: 'sil3plc'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/workload': 'sil3-thyristor-rectifier-anthracite-lance-offgas-interlock'
          'agent.azure.com/ptp-sync': 'ieee1588v2-sub-microsecond'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
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

output clusterResourceId string = aksCluster.id
output pinnNodePoolName string = 'tiopinn'
output sil3InterlockProfile string = 'NFPA-86-ISO-13577-OSHA-1910.119-IEC-61511-SIL3-Slag-Boilover-Freeze-Lining-Breakout-Water-Leak'
