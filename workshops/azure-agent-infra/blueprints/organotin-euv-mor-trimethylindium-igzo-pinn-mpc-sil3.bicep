// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #239 (Cycle #238)
// Electronic-Grade Organotin EUV Metal-Oxide Photoresist (6N Sn12-MOR
// [(R)SnO(OAc)]6 / R-Sn(NMe2)3 >= 99.9999%) & Trimethylindium (6N TMI
// In(CH3)3 >= 99.9999%) + Diethylzinc (6N DEZ) High-NA EUV (0.55 NA, 13.5 nm)
// Dry/Track Lithography & 2nm/A14 Monolithic 3D BEOL a-IGZO (2T0C DRAM)
// Sublimation-Zone Purification, Piezocon Carrier Stabilization PINN-MPC &
// SEMI S2 / OSHA Organotin PEL / NFPA 30 / IEC 61511 SIL-3 Hard Interlock
// ============================================================================

@description('Deployment Azure region for the Organotin EUV MOR & Trimethylindium a-IGZO edge-cloud hybrid control plane.')
param location string = resourceGroup().location

@description('Environment identifier (prod, staging, lab).')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('Unique facility code for resource naming.')
param facilityCode string = 'snmor238'

@description('Maximum allowable dialkyltin (R2SnX2) & trialkyltin (R3SnX) disproportionation impurity in 6N Sn12-MOR (ppmw).')
param maxDialkylTrialkylTinPpmw int = 1

@description('Maximum allowable toxic organotin vapor concentration in exhaust/enclosure before SIL-3 lockout (ppbv as Sn).')
param maxOrganotinExhaustPpbv int = 10

@description('Maximum allowable Trimethylindium (TMI) solid/solution sublimator jacket temperature before SIL-3 melt-runaway trip (degC, below m.p. 88.4 C).')
param maxTmiSublimatorTempC int = 82

var resourcePrefix = 'ai-agent-${facilityCode}-${environment}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${resourcePrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take('${replace(resourcePrefix, '-', '')}kv', 24)
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${resourcePrefix}-iothub'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    minTlsVersion: '1.2'
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 8
      }
    }
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: '${resourcePrefix}-ehns'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 12
    minimumTlsVersion: '1.2'
  }
}

resource metrologyEventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: 'qcl-tdlas-piezocon-sp-icp-tof-ms-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 8
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${resourcePrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${resourcePrefix}-dns'
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
        name: 'pinnmpcpool'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'OCIContainer'
        nodeLabels: {
          'agent.azure.com/accelerator': 'nvidia-a100'
          'process.semi/precursor': '6n-organotin-euv-mor-tmi-igzo'
          'safety.iec61511/sil-tier': 'sil3-2oo3-tmi-melt-organotin-interlock'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
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

output aksClusterName string = aksCluster.name
output metrologyStreamEndpoint string = metrologyEventHub.name
output sil3SafetyThresholds object = {
  maxDialkylTrialkylTinPpmw: maxDialkylTrialkylTinPpmw
  maxOrganotinExhaustPpbv: maxOrganotinExhaustPpbv
  maxTmiSublimatorTempC: maxTmiSublimatorTempC
  interlockStandard: 'SEMI C3 / SEMI S2 / OSHA Organotin PEL / IEC 61511 SIL-3'
}
