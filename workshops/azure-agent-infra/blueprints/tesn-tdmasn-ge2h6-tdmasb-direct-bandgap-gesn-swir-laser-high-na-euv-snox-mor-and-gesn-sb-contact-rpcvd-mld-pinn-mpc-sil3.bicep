// ============================================================================
// Azure AI Agent Infrastructure Blueprint #290 (Cycle #289 — 290-Blueprint Milestone!)
// Electronic-Grade 6N5 TESn (Tetraethyltin) & 6N5 TDMASn (Tetrakis(dimethylamino)tin)
// + 6N5 Ge2H6 / GeH4 (Digermane / Germane) + 6N5 TDMASb (Tris(dimethylamino)antimony)
// Direct-Bandgap Ge1-xSnx (Sn = 12.5 at.%) SWIR/MWIR CMOS-Monolithic Silicon Photonic
// Laser & High-NA (0.55 NA) EUV Tin-Oxide Molecular Photoresist (SnOx EUV-MOR) MLD/PEALD
// + n+-GeSn:Sb Ohmic Contact RP-CVD PINN-MPC + IEC 61511 SIL-3 Safety Interlock
// ============================================================================

@description('Azure region for the TESn / TDMASn / Ge2H6 / TDMASb GeSn SWIR Laser & High-NA EUV SnOx MOR Digital Twin cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'gesn-snox-euv-sil3'

@description('Target substitutional tin fraction x in strained direct-bandgap Ge1-xSnx active quantum wells (at.%)')
param targetGeSnSubstitutionalTinPct int = 12

@description('Maximum allowable High-NA (0.55 NA) EUV SnOx molecular photoresist line-width roughness 3-sigma LWR (pm)')
param maxEuvSnoxMorLwrPm int = 1250

@description('OSHA PEL / NIOSH REL ceiling for pyrophoric Germane GeH4 / Digermane Ge2H6 exhaust (ppbv)')
param maxGermaneExhaustPpbv int = 200

@description('OSHA PEL ceiling for Organotin (TESn / TDMASn as Sn, 0.1 mg/m3) & Stibine SbH3 (100 ppbv) exhaust equivalent (ppbv)')
param maxOrganotinStibineExhaustPpbv int = 15

@description('AKS System Pool VM SKU for deterministic SIL-3 safety interlock & RHEED/ellipsometry edge processing')
param systemNodeSku string = 'Standard_D16s_v5'

@description('AKS GPU Pool VM SKU for Fourier Neural Operator (FNO) GeSn non-equilibrium Sn segregation + EUV SnOx MOR MLD PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var aksClusterName = '${envPrefix}-aks'
var iotHubName = '${envPrefix}-iothub'
var adxClusterName = '${envPrefix}adx'
var adxDatabaseName = 'GeSnSwirLaserAndHighNaEuvSnoxMorTelemetry'
var keyVaultName = '${ replace(envPrefix, '-', '') }kv290'

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
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E16d_v5'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: true
  }
}

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: adxDatabaseName
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
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
        name: 'sil3sys'
        count: 3
        vmSize: systemNodeSku
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcgpu'
        count: 2
        vmSize: gpuNodeSku
        osType: 'Linux'
        mode: 'User'
        nodeLabels: {
          'workload-tier': 'gesn-swir-laser-and-high-na-euv-snox-mor-pinn-mpc'
          'safety-integrity-level': 'iec-61511-sil3'
          'SubstitutionalTinTargetPct': string(targetGeSnSubstitutionalTinPct)
          'MaxEuvSnoxMorLwrPm': string(maxEuvSnoxMorLwrPm)
          'MaxGermaneExhaustPpbv': string(maxGermaneExhaustPpbv)
          'MaxOrganotinStibineExhaustPpbv': string(maxOrganotinStibineExhaustPpbv)
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

output aksClusterId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output adxClusterUri string = adxCluster.properties.uri
output blueprintMilestone string = 'Blueprint #290 (Cycle #289 — 290-Blueprint Milestone!): 6N5 TESn/TDMASn + Ge2H6/GeH4 + TDMASb Direct-Bandgap Ge1-xSnx SWIR Laser & High-NA EUV SnOx MOR PINN-MPC + SIL-3'
