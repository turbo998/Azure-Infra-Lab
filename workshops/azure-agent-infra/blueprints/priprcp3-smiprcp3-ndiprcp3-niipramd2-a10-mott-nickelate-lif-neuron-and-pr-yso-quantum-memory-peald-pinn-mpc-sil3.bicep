// ============================================================================
// Azure AI Agent Infrastructure Blueprint #300 (Cycle #299 — 300-Blueprint Milestone!)
// Electronic-Grade 6N5 Pr(iPrCp)3 & 6N5 Sm(iPrCp)3 + 6N5 Nd(iPrCp)3 + 6N5 Ni(iPr-AMD)2
// Sub-Angstrom 10A (A10) / A7 Correlated-Electron Rare-Earth Nickelate (Sm1-xNdxNiO3)
// Mott-Transition Leaky-Integrate-and-Fire (LIF) Neuromorphic Spiking Neuron,
// Telecom/Visible Pr3+:Y2SiO5 (Pr:YSO) Solid-State AFC Quantum Repeater Memory &
// High-k Pr2O3/PrTiO3 Gate Dielectric PEALD / Oxide-MBE PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the Sovereign Edge-Cloud AI Fab')
param location string = resourceGroup().location

@description('Environment identifier (prod-fab-edge, staging, validation)')
param environment string = 'prod-fab-edge'

@description('Number of parallel 300mm A10 Sm1-xNdxNiO3 Mott-LIF Neuromorphic & Pr:YSO Quantum Memory PEALD / Oxide-MBE reactor trains')
@minValue(1)
@maxValue(64)
param reactorTrains int = 8

@description('Target 6N5 Pr(iPrCp)3 / Sm(iPrCp)3 / Nd(iPrCp)3 / Ni(iPr-AMD)2 trace heavy-metal impurity ceiling in pptw')
param targetTraceMetalCeilingPptw int = 1

@description('Target Sm0.55Nd0.45NiO3 Mott insulator-to-metal transition (IMT) temperature window in K (335 K ± 0.4 K)')
param targetMottImtTempK string = '335.0'

@description('Target LIF spiking neuron energy per spike in fJ/spike (<= 0.42 fJ/spike) and Pr3+:Y2SiO5 AFC spin-wave storage time in ms (>= 120 ms)')
param targetNeuronEnergyFjAndAfcmemMs string = '0.42fJ-120ms'

@description('SIL-3 emergency interlock maximum latency in microseconds')
param sil3InterlockLatencyUs int = 100

var clusterName = 'aks-pripr-smni-mott-lif-qmem-${environment}'
var iotHubName = 'iot-pripr-smni-mott-lif-${ uniqueString(resourceGroup().id) }'
var eventHubNamespace = 'eh-pripr-smni-mott-lif-${ uniqueString(resourceGroup().id) }'
var cosmosAccountName = 'cosmos-pripr-smni-mott-${ uniqueString(resourceGroup().id) }'
var keyVaultName = 'kv-priprsmni-${ take(uniqueString(resourceGroup().id), 10) }'

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

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: max(1, reactorTrains / 4)
  }
  properties: {
    minTlsVersion: '1.2'
    disableLocalAuth: true
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
    minimumTlsVersion: '1.2'
    isAutoInflateEnabled: false
    zoneRedundant: true
  }
}

resource telemetryStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNs
  name: 'qcl-crds-10khz-pripr-smipr-niamd-rheed-xas-xmcd-sfg-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.30'
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [ '1', '2', '3' ]
      }
      {
        name: 'pinnmpch100'
        count: max(2, (reactorTrains + 1) / 2)
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        availabilityZones: [ '1', '2', '3' ]
        nodeLabels: {
          'workload/type': 'pinn-mpc-priprcp3-smiprcp3-ndiprcp3-niipramd2-mott-lif-pr-yso'
          'safety/tier': 'semi-s2-nfpa704-sil3-pyrophoric-lanthanide-high-pressure-ozone'
          'metrology/loop': 'qcl-crds-10khz-2964-2968-1632cm1-rheed-xas-xmcd-sfg-se'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
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
    tags: {
      cycle: '299'
      milestone: '300-Blueprint-Milestone'
      precursorPurity: '6N5-PriPrCp3-SmiPrCp3-NdiPrCp3-NiiPrAMD2'
      targetTraceMetalPptw: string(targetTraceMetalCeilingPptw)
      targetMottImtTempK: targetMottImtTempK
      targetNeuronEnergyFjAndAfcmemMs: targetNeuronEnergyFjAndAfcmemMs
      sil3LatencyUs: string(sil3InterlockLatencyUs)
    }
  }
}

output aksClusterId string = aksCluster.id
output telemetryEventHubId string = telemetryStream.id
output controlTopology string = 'pinn_mpc_priprcp3_smiprcp3_ndiprcp3_niipramd2_a10_mott_nickelate_lif_neuron_and_pr_yso_quantum_memory_peald_sil3_edge'
