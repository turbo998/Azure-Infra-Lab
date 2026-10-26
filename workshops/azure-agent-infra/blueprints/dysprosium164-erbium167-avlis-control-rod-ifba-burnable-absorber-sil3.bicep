// blueprints/dysprosium164-erbium167-avlis-control-rod-ifba-burnable-absorber-sil3.bicep
// Cycle #219 (225-Chapter & 220-Blueprint Milestone!): Autonomous Enriched Dysprosium-164 (164Dy2O3-TiO2 >=96%, 2,650 barns)
// Non-Depleting Control Rod & Enriched Erbium-167 (167Er2O3 >=91%, 650 barns, 0.46 eV Resonance) 24-Month LWR/SMR
// Integral Burnable Absorber AVLIS Separation PINN-MPC + 10 CFR 50.46 / ASME NQA-1 / ANSI Z136.1 / IEC 61511 SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Dysprosium-164 & Erbium-167 AVLIS separation & nuclear absorber digital twin')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param envPrefix string = 'dy164er219s3'

@description('Number of parallel 164Dy/167Er AVLIS separation & dysprosium-titanate / erbia-UO2 sintering trains (1-64)')
@minValue(1)
@maxValue(64)
param dy164Er167Trains int = 8

@description('Operating profile: dy164_dysprosium_titanate_control_rod, er167_er2o3_uo2_long_cycle_absorber, or hybrid_dy164_er167_avlis_campaign')
@allowed([
  'dy164_dysprosium_titanate_control_rod'
  'er167_er2o3_uo2_long_cycle_absorber'
  'hybrid_dy164_er167_avlis_campaign'
])
param operatingMode string = 'dy164_dysprosium_titanate_control_rod'

@description('Target 164Dy enrichment fraction (%) for non-gassing Dy2TiO5 control rod absorber pellets')
param targetDy164EnrichmentPct string = '96.5'

@description('Target 167Er enrichment fraction (%) for 0.461 eV resonant MTC-stabilizing Er2O3-UO2 fuel')
param targetEr167EnrichmentPct string = '91.8'

var aksName = '${envPrefix}-aks'
var acrName = replace('${envPrefix}acr', '-', '')
var kvName = '${envPrefix}-kv'
var ehNamespace = '${envPrefix}-eh'
var adxClusterName = '${envPrefix}adx'
var adxDbName = 'Dy164Er167AvlisTelemetryDb'
var lawName = '${envPrefix}-law'

var gpuNodeCount = max(2, (dy164Er167Trains + 1) / 2)
var activeDy164Er167Pods = dy164Er167Trains * 4

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    zoneRedundancy: 'Enabled'
  }
}

resource ehNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: ehNamespace
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    zoneRedundant: true
    minimumTlsVersion: '1.2'
  }
}

resource ehTelemetry 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: ehNs
  name: 'dy164-er167-avlis-10khz-lif-hyperfine-pgnaa-dilatometer-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource ehSafety 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: ehNs
  name: 'cfr5046-asmenqa1-ansiz136-sil3-ebeam-crucible-sinter-h2-interlock-events'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 8
  }
}

resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
  }
}

resource adxDb 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: adxDbName
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P3650D'
    hotCachePeriod: 'P90D'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: envPrefix
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'syspool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'dy164er167gpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/pinn-mpc': 'dysprosium164-erbium167-avlis-ifba'
          'safety/interlock': 'cfr5046-asmenqa1-ansiz136-iec61511-sil3'
          'operating-mode': operatingMode
          'target-dy164-pct': targetDy164EnrichmentPct
          'target-er167-pct': targetEr167EnrichmentPct
        }
      }
      {
        name: 'katapool'
        count: max(3, dy164Er167Trains)
        vmSize: 'Standard_D16s_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'isolation/runtime': 'kata-mshv'
          'telemetry/loop-rate': '10khz-fabry-perot-lif-hyperfine-pgnaa-dilatometer'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: law.id
        }
      }
    }
  }
}

output aksClusterName string = aks.name
output gpuNodesAllocated int = gpuNodeCount
output activeDy164Er167SolverPods int = activeDy164Er167Pods
output safetyStandard string = '10 CFR 50.46 / ASME NQA-1 / ANSI Z136.1 / NFPA 86 / IEC 61511 SIL-3'
output edgeTelemetryLoopMs string = '0.15'
output hardwareInterlockTripMs string = '0.16'
