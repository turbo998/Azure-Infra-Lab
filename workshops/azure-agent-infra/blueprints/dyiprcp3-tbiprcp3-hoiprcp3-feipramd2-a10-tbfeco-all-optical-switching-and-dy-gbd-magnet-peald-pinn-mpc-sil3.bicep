// ============================================================================
// Azure AI Agent Infrastructure Blueprint #301
// (Cycle #300 — 300-Cycle & 300-Simulator Double Milestone!)
// Electronic-Grade 6N5 Dy(iPrCp)3 & 6N5 Tb(iPrCp)3 + 6N5 Ho(iPrCp)3 + 6N5 Fe/Co(iPr-AMD)2
// Sub-Angstrom 10A (A10) / A7 Ferrimagnetic Compensation-Point Tb0.22Fe0.68Co0.10 / Dy0.24Co0.76
// 3.2ps Single-Shot All-Optical Helicity-Independent Switching (AO-HITS) Photonic-Spintronic Memory,
// Vapor Dy/Tb Grain-Boundary Diffusion (Dy/Tb-GBD) High-Coercivity Nd2Fe14B Cryo-Circulator Magnet &
// Single-Atom Ho/MgO(100) Surface Spin Memory PEALD / MBE PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the Sovereign Edge-Cloud AI Fab')
param location string = resourceGroup().location

@description('Environment identifier (prod-fab-edge, staging, validation)')
param environment string = 'prod-fab-edge'

@description('Number of parallel 300mm A10 TbFeCo/DyCo All-Optical Switching & Dy/Tb-GBD Magnet PEALD / MBE reactor trains')
@minValue(1)
@maxValue(64)
param reactorTrains int = 8

@description('Target 6N5 Dy(iPrCp)3 / Tb(iPrCp)3 / Ho(iPrCp)3 / Fe(iPr-AMD)2 trace impurity ceiling in pptw')
param targetTraceMetalCeilingPptw int = 1

@description('Target Tb0.22Fe0.68Co0.10 angular-momentum compensation temperature TA in K (305.0 K ± 0.5 K) and switching time in ps (<= 3.2 ps)')
param targetCompensationTempKAndAosPs string = '305.0K-3.2ps'

@description('Target Dy/Tb-GBD Nd2Fe14B intrinsic coercivity Hcj in kOe (>= 34.5 kOe) and domain-wall velocity in km/s (>= 5.4 km/s)')
param targetCoercivityKoeAndVdwKms string = '34.5kOe-5.4km/s'

@description('SIL-3 emergency interlock maximum latency in microseconds')
param sil3InterlockLatencyUs int = 100

var clusterName = 'aks-dyipr-tbfeco-aos-gbd-${environment}'
var iotHubName = 'iot-dyipr-tbfeco-aos-${ uniqueString(resourceGroup().id) }'
var eventHubNamespace = 'eh-dyipr-tbfeco-aos-${ uniqueString(resourceGroup().id) }'
var cosmosAccountName = 'cosmos-dyipr-tbfeco-${ uniqueString(resourceGroup().id) }'
var keyVaultName = 'kv-dyiprtbf-${ take(uniqueString(resourceGroup().id), 10) }'

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
  name: 'qcl-crds-10khz-dyipr-tbipr-feamd-tr-moke-xmcd-sp-stm-stream'
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
          'workload/type': 'pinn-mpc-dyiprcp3-tbiprcp3-hoiprcp3-feipramd2-tbfeco-aos-dy-gbd'
          'safety/tier': 'semi-s2-nfpa704-sil3-pyrophoric-heavy-lanthanide-fe-co-amidinato'
          'metrology/loop': 'qcl-crds-10khz-2971-2974-1628cm1-tr-moke-xmcd-sp-stm'
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
      cycle: '300'
      milestone: '300-Cycle-and-300-Simulator-Double-Milestone'
      precursorPurity: '6N5-DyiPrCp3-TbiPrCp3-HoiPrCp3-FeiPrAMD2'
      targetTraceMetalPptw: string(targetTraceMetalCeilingPptw)
      targetCompensationTempKAndAosPs: targetCompensationTempKAndAosPs
      targetCoercivityKoeAndVdwKms: targetCoercivityKoeAndVdwKms
      sil3LatencyUs: string(sil3InterlockLatencyUs)
    }
  }
}

output aksClusterId string = aksCluster.id
output telemetryEventHubId string = telemetryStream.id
output controlTopology string = 'pinn_mpc_dyiprcp3_tbiprcp3_hoiprcp3_feipramd2_a10_tbfeco_all_optical_switching_and_dy_gbd_magnet_peald_sil3_edge'
