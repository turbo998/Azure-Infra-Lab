// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #226 (Cycle #225)
// 225-Cycle & 225-Simulator Double Milestone!
// Terbium Quartet (149Tb Alpha / 152Tb PET / 155Tb SPECT / 161Tb Beta+Auger)
// ISOL Electromagnetic Mass Separation, 160Gd(n,g)161Gd->161Tb LN/TK211 Resin
// Chromatography & 224Ra/212Pb Generator TCMC Chelation PINN-MPC, 10 kHz
// Magnetic Mass-Slit / HPGe / Radon-220 Telemetry & USP <823> / ISO 17873 /
// SIL-3 Thoron Containment and Beam-Dump Interlock Sandbox
// ============================================================================

@description('Azure region for Terbium Quartet (149Tb/152Tb/155Tb/161Tb) & 224Ra/212Pb Theranostics Radiopharmaceutical Edge-Cloud Sandbox')
param location string = resourceGroup().location

@description('Environment prefix for Terbium Quartet ISOL/Reactor & 224Ra/212Pb Generator PINN-MPC deployment')
param environmentPrefix string = 'tb161c225s3'

@description('Number of parallel Terbium Quartet ISOL/LN-Resin & 224Ra/212Pb TCMC Radiochemistry Trains (1-32)')
@minValue(1)
@maxValue(32)
param tbPb212Trains int = 8

@description('AKS GPU node count for PINN-MPC Isobaric Mass-Separation, α-HIBA Elution & 212Bi Recoil Re-chelation (Standard_NC24ads_A100_v4)')
@minValue(1)
@maxValue(16)
param gpuNodeCount int = 4

@description('SIL-3 USP <823> / ISO 17873 Gaseous 220Rn Thoron Charcoal Trap, 224Ra Breakthrough & ISOL Beam-Dump Interlock Budget (ms)')
param sil3ThoronBeamDumpBudgetMs string = '0.15'

@description('Edge 10 kHz ISOL Dipole Mass-Slit Faraday Cup, HPGe Gamma & Capillary Electrophoresis Closed-Loop Budget (ms)')
param edgeIsolHpgeLoopBudgetMs string = '0.14'

var aksClusterName = '${environmentPrefix}-aks-tb161-pb212-sil3'
var iotHubName = '${environmentPrefix}-iothub-10khz-isol-hpge'
var eventHubNamespaceName = '${environmentPrefix}-ehns-tbquartet-pb212'
var cosmosAccountName = '${environmentPrefix}-cosmos-usp823-ledger'
var keyVaultName = '${environmentPrefix}-kv-sil3-thoron'

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 32
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1M'
    }
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    isAutoInflateEnabled: false
    zoneRedundant: true
    minimumTlsVersion: '1.2'
  }
}

resource telemetryEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'isol-mass-slit-lnresin-ra224-pb212-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: cosmosAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Strong'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
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
        name: 'pinnmpcgpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/Accelerator': 'nvidia-a100-80gb'
          'agent.azure.com/Domain': 'terbium-quartet-149-152-155-161-lead212-theranostics-sil3'
          'agent.azure.com/SafetyStandard': 'USP-823-ISO-17873-IEC-61511-SIL3'
          'agent.azure.com/Cycle': '225'
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
          'safety=sil3-radiopharma:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
     tags: {
      blueprintId: '226'
      cycleId: '225'
      tbPb212Trains: string(tbPb212Trains)
      sil3ThoronBeamDumpBudgetMs: sil3ThoronBeamDumpBudgetMs
      edgeIsolHpgeLoopBudgetMs: edgeIsolHpgeLoopBudgetMs
    }
  }
}

output aksClusterResourceId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output eventHubStream string = telemetryEventHub.name
output sil3InterlockTargetMs string = sil3ThoronBeamDumpBudgetMs
output edgeClosedLoopTargetMs string = edgeIsolHpgeLoopBudgetMs
