// =============================================================================
// Blueprint #250 (250-Blueprint Milestone!): Electronic-Grade Dimethylzinc
// (6N DMZn Zn(CH3)2 >= 99.9999%, b.p. 46.0 C, m.p. -42.0 C, v.p. 124 Torr @ 0 C,
// Cd <= 0.05 ppmw, Pb <= 0.02 ppmw, RZnI <= 0.10 ppmw) & Electronic-Grade Diethylzinc
// (6N DEZn Zn(C2H5)2 >= 99.9999%, b.p. 117.6 C, v.p. 15.0 Torr @ 20 C, Cl/I <= 0.05 ppmw)
// + Electronic-Grade Bis(cyclopentadienyl)iron / Ferrocene (6N Cp2Fe Fe(C5H5)2 >= 99.9999%)
// High-NA EUV Zn-Oxo Cluster Photoresist (EUV MOR), InP/InGaAsP p-Type Zn Acceptor MOCVD
// & 2D MoS2/WS2 Channel CVD Adduct-Purification Rectification PINN-MPC,
// 10 kHz QCL-TDLAS / FTIR (615 cm^-1 / 562 cm^-1 / 705 cm^-1) + HR-ICP-MS + 1H/13C-NMR
// Metrology & SEMI S2 / NFPA 704 (4-3-3 W) / IEC 61511 SIL-3 Extreme Pyrophoric Hard Interlock
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for the 6N DMZn & 6N DEZn + 6N Cp2Fe High-NA EUV Zn-Oxo MOR & InP MOCVD digital twin')
param location string = resourceGroup().location

@description('Environment name (prod, staging, lab)')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('DMZn adduct-dissociation rectification boiler temperature setpoint in Celsius (nominal 46.0 C, range 35.0 - 58.0 C)')
param dmznRectificationTempC int = 46

@description('DEZn vacuum fractional distillation column temperature setpoint in Celsius (nominal 62.0 C @ 30 Torr, range 48.0 - 78.0 C)')
param deznVacuumDistillationTempC int = 62

@description('DMZn MOCVD cryo-thermostat bubbler bath temperature setpoint in Celsius (nominal -10.0 C, range -25.0 to +10.0 C)')
param dmznBubblerBathTempC int = -10

@description('InP / InGaAsP p-type Zn-doped MOCVD reactor susceptor temperature setpoint in Celsius (nominal 630 C, range 560 - 690 C)')
param inpMocvdSusceptorTempC int = 630

var prefix = 'dmzn-dezn-cp2fe-${environment}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-aks-identity'
  location: location
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${prefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${prefix}-iothub'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 8
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: replace('${prefix}adx', '-', '')
  location: location
  sku: {
    name: 'Standard_D14_v2'
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
  name: 'DmznDeznCp2feEuvMorInpMocvdTelemetry'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: '${prefix}-aks'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: '${prefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpcgpu'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/pinn-mpc': 'dmzn-dezn-cp2fe-euv-mor-inp-mocvd'
          'safety/iec61511-sil': 'sil-3'
        }
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

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take(replace('${prefix}-kv', '-', ''), 24)
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
  }
}

output aksClusterName string = aksCluster.name
output iotHubHostname string = iotHub.properties.hostName
output adxClusterUri string = adxCluster.properties.uri
output safetyInterlockSpec object = {
  standard: 'SEMI S2 / SEMI C3 / NFPA 704 (4-3-3 W) / IEC 61511 SIL-3'
  dmznRectificationTempSetpointC: dmznRectificationTempC
  deznVacuumDistillationTempSetpointC: deznVacuumDistillationTempC
  dmznBubblerBathTempSetpointC: dmznBubblerBathTempC
  inpMocvdSusceptorTempSetpointC: inpMocvdSusceptorTempC
  sil3TripConditions: {
    maxGloveboxOxygenPpmv: 1
    maxLineMoisturePpbv: 10
    maxCabinetAlkaneLelPct: 10
    maxExhaustFilterDeltaPKpa: 18
    maxDeznPotTempBeforeBetaEliminationC: 95
  }
}
