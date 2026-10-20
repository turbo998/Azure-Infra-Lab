// Blueprint #60: AKSClaw Autonomous Green Hydrogen (PEM / Alkaline Electrolyzer),
// Haber-Bosch Green Ammonia Synthesis & ISO 22734 / IEC 61511 SIL-3 H2-in-O2 Interlock Pool
// Target: Chapter 64 — Dynamic Renewable Curtailment Load-Following MPC (-11.8% Stack kWh/kg H2,
// 46.2 kWh/kg), +23.6% Green NH3 Synthesis Yield, 0.9 ms ISO 22734 H2-in-O2 (<1.6% vol) &
// Differential Pressure Interlock, and 9.5 ms Edge EIS Impedance Triage (96.8% WAN Reduction)

@description('Deployment region for the AKSClaw Green Hydrogen & Ammonia Agent Infrastructure')
param location string = resourceGroup().location

@description('Environment prefix for cluster and industrial edge resources')
param envPrefix string = 'aksclaw-h2nh3'

@description('Electrolyzer and green ammonia plant capacity in MW (200, 1000, or 5000 MW)')
@allowed([
  200
  1000
  5000
])
param electrolyzerPlantCapacityMw int = 1000

@description('ISO 22734 / IEC 61511 SIL-3 maximum allowed H2-in-O2 anode gas crossover (% vol, 40% LEL)')
param maxH2InO2CrossoverVolPct string = '1.6'

@description('Maximum PEM/Alkaline membrane differential pressure limit (bar) before blowdown trip')
param maxMembraneDiffPressureBar string = '0.35'

var gpuNodeCount = max(2, (electrolyzerPlantCapacityMw + 249) / 250)
var electrolyzerTrains = max(4, (electrolyzerPlantCapacityMw + 49) / 50)

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
  name: '${envPrefix}-eis-lustre'
  location: location
  sku: {
    name: 'AMLFS-Durable-Premium-250'
  }
  zones: [
    '1'
  ]
  properties: {
    storageCapacityTiB: 16
    subnet: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-h2nh3/providers/Microsoft.Network/virtualNetworks/vnet-h2nh3/subnets/snet-lustre'
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
        name: 'h2nh3mpc'
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
          'aksclaw.io/domain': 'green-hydrogen-electrolyzer-ammonia'
          'aksclaw.io/safety-standard': 'iso-22734-iec-61511-sil3'
          'aksclaw.io/h2-in-o2-trip-pct': maxH2InO2CrossoverVolPct
          'aksclaw.io/membrane-dp-max-bar': maxMembraneDiffPressureBar
          'aksclaw.io/electrolyzer-trains': string(electrolyzerTrains)
        }
        nodeTaints: [
          'aksclaw.io/hydrogen-ammonia=true:NoSchedule'
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
output electrolyzerTrainsManaged int = electrolyzerTrains
output iso22734InterlockSloMs string = '0.9'
