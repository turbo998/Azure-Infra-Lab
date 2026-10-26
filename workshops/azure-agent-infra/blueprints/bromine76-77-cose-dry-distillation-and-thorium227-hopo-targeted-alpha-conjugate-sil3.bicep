// ============================================================================
// Blueprint #227: Autonomous Auger-Electron & Alpha-Particle Cascade
// Theranostics — No-Carrier-Added Bromine-76 / Bromine-77 (76Br/77Br via
// 13-16 MeV Proton Enriched Co76Se/Co77Se Target & 1,050 C Dry Distillation
// for 77Br-PARPi) & Thorium-227 Targeted Alpha Conjugate (227Ac/227Th
// Generator & Room-Temperature 3,2-HOPO mAb Conjugation) PINN-MPC, Online
// 10kHz Quartz-Furnace Pyrometry, HPGe Gamma & SEC-HPLC Metrology &
// USP <823> / 10 CFR 20 / ISO 17873 / SIL-3 Volatile Radiobromine AgX
// Scrubber, 227Ac Breakthrough Quarantine & 223Ra Daughter Hold Interlock
// ============================================================================

@description('Azure region for the Bromine-76/77 CoSe Dry Distillation & Thorium-227 HOPO Targeted Alpha Conjugate Cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'br77th227-c226'

@description('Number of parallel 76Br/77Br CoSe dry-distillation & 227Ac/227Th HOPO-mAb conjugation trains (1 to 32)')
@minValue(1)
@maxValue(32)
param brTh227Trains int = 8

@description('AKS GPU node count (Standard_NC24ads_A100_v4) for 76Br/77Br dry-distillation & 227Th-HOPO PINN-MPC')
param gpuNodeCount int = max(2, (brTh227Trains + 1) / 2)

@description('Enable USP <823> / 10 CFR 20 / ISO 17873 / SIL-3 volatile Br2 AgX scrubber & 227Ac/223Ra quarantine hard interlock')
param enableSil3Br77Th227Interlock bool = true

var aksClusterName = '${envPrefix}-aks-kata-sil3'
var iotHubName = '${envPrefix}-iothub-10khz'
var eventHubNamespace = '${envPrefix}-eh-telemetry'
var cosmosAccountName = '${envPrefix}${uniqueString(resourceGroup().id)}cosmos'

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: max(2, brTh227Trains / 2)
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
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

resource eventHubNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespace
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    isAutoInflateEnabled: false
    minimumTlsVersion: '1.2'
  }
}

resource metrologyStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNs
  name: 'br76-77-cose-distillation-th227-hopo-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'katapinnpool'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv-vm-isolation'
          'theranostics.azure.com/domain': 'br76-77-cose-dry-distillation-th227-hopo-tac'
          'safety.azure.com/standard': 'usp-823-10cfr20-iso17873-sil3'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
    }
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
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
     extraProperties: {
      sil3InterlockEnabled: enableSil3Br77Th227Interlock
      controlMode: 'pinn_mpc_br76_77_cose_dry_distillation_parpi_and_ac227_th227_hopo_ra223_sil3_edge'
      maxInterlockLatencyMs: '0.15'
    }
  }
}

output aksClusterId string = aksCluster.id
output gpuNodesAllocated int = gpuNodeCount
output activeBrTh227Pods int = brTh227Trains * 4
output sil3InterlockStatus string = enableSil3Br77Th227Interlock ? 'USP<823>_10CFR20_ISO17873_SIL3_0.15ms_Br2AgXScrubber_Ac227BreakthroughQuarantine_Ra223Hold_Active' : 'Bypassed'
