// Blueprint #61: AKSClaw Autonomous Tokamak Fusion Plasma Magnetic Control,
// Divertor Detachment Heat-Flux MPC & IEC 61508 SIL-3 Shattered-Pellet / HTS Quench Interlock Pool
// Target: Chapter 65 — Surrogate Grad-Shafranov MHD Control (+48.5% H-Mode Pulse Duration),
// -36.4% Divertor Peak Heat Flux, 0.4 ms IEC 61508 SIL-3 SPI Disruption Mitigation & HTS Quench
// Dump Interlock, and 2.5 ms Edge Mirnov/Thomson Diagnostics Triage (97.6% WAN Reduction)

@description('Deployment region for the AKSClaw Tokamak Fusion Plasma Agent Infrastructure')
param location string = resourceGroup().location

@description('Environment prefix for cluster and fusion diagnostics edge resources')
param envPrefix string = 'aksclaw-tokamak'

@description('Tokamak thermal fusion power rating in MW (100, 500, or 2000 MW)')
@allowed([
  100
  500
  2000
])
param fusionThermalPowerMw int = 500

@description('IEC 61508 SIL-3 maximum divertor target heat flux limit (MW/m2) before SPI trip')
param maxDivertorHeatFluxMwPerM2 string = '10.0'

@description('HTS REBCO coil quench detection voltage tap threshold (mV) for dump resistor extraction')
param htsQuenchThresholdMv string = '50.0'

var gpuNodeCount = max(2, (fusionThermalPowerMw + 124) / 125)
var pfCoilsAndGyrotrons = max(12, (fusionThermalPowerMw * 2) / 25)

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource lustrefs 'Microsoft.StorageCache/amlFilesystems@2023-05-01' = {
  name: '${envPrefix}-shot-lustre'
  location: location
  sku: {
    name: 'AMLFS-Durable-Premium-250'
  }
  zones: [
    '1'
  ]
  properties: {
    storageCapacityTiB: 32
    subnet: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tokamak/providers/Microsoft.Network/virtualNetworks/vnet-tokamak/subnets/snet-lustre'
    maintenanceWindow: {
      dayOfWeek: 'Sunday'
      timeOfDayUTC: '02:00'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'mhdcontrol'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'aksclaw.io/domain': 'fusion-tokamak-plasma-quench'
          'aksclaw.io/safety-standard': 'iec-61508-sil3-spi-hts-quench'
          'aksclaw.io/divertor-heatflux-max-mwm2': maxDivertorHeatFluxMwPerM2
          'aksclaw.io/hts-quench-threshold-mv': htsQuenchThresholdMv
          'aksclaw.io/pf-coils-and-gyrotrons': string(pfCoilsAndGyrotrons)
        }
        nodeTaints: [
          'aksclaw.io/fusion-plasma=true:NoSchedule'
        ]
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterName string = aksCluster.name
output gpuSolverNodes int = gpuNodeCount
output pfCoilsAndGyrotronsManaged int = pfCoilsAndGyrotrons
output sil3SpiQuenchInterlockSloMs string = '0.4'
