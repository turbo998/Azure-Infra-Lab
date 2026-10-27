// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #238 (Cycle #237)
// Electronic-Grade Diethoxymethylsilane (6N DEMS HSi(CH3)(OC2H5)2 >= 99.9999%)
// & Octamethylcyclotetrasiloxane (6N OMCTS / D4 [(CH3)2SiO]4 >= 99.9999%) +
// Alpha-Terpinene (6N ATRP C10H16 Sacrificial Porogen) 2nm/A14 BEOL Mesoporous
// Ultra-Low-k (k <= 2.05-2.18, E >= 8.2 GPa) Vacuum Fractional Distillation,
// Dual-LFC Vaporizer & 172/254 nm UV-Thermal Cure PINN-MPC + SEMI S2 SIL-3
// ============================================================================

@description('Deployment Azure region for the DEMS/OMCTS/ATRP porous Ultra-Low-k edge-cloud hybrid control plane.')
param location string = resourceGroup().location

@description('Environment identifier (prod, staging, lab).')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('Unique facility code for resource naming.')
param facilityCode string = 'dems237'

@description('Maximum allowable triethoxymethylsilane (MTES) & cyclic D3/D5 oligomer impurity in 6N DEMS/OMCTS (ppmv).')
param maxMtesAndCyclicD3D5Ppmv int = 1

@description('Maximum allowable terpinene hydroperoxide & p-cymene oxidation byproduct in 6N ATRP porogen (ppmv).')
param maxAtrpPeroxideCymenePpmv int = 1

@description('Maximum allowable liquid mass-flow vaporizer (LFC) wall temperature before SIL-3 thermal gelation & peroxide runaway trip (degC).')
param maxLfcVaporizerWallTempC int = 165

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
  name: 'qcl-tdlas-ep-ellipsometry-icpms-stream'
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
          'process.semi/precursor': '6n-dems-omcts-atrp-porous-ulk-uv-cure'
          'safety.iec61511/sil-tier': 'sil3-2oo3-lfc-gelation-peroxide-interlock'
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
  maxMtesAndCyclicD3D5Ppmv: maxMtesAndCyclicD3D5Ppmv
  maxAtrpPeroxideCymenePpmv: maxAtrpPeroxideCymenePpmv
  maxLfcVaporizerWallTempC: maxLfcVaporizerWallTempC
  interlockStandard: 'SEMI C3 / SEMI S2 / NFPA 30 / IEC 61511 SIL-3'
}
