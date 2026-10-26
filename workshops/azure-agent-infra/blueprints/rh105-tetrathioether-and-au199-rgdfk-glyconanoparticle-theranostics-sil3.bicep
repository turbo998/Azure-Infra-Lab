// ============================================================================
// Azure Bicep Blueprint #233 (Cycle #232)
// Rhodium-105 (105Rh, t1/2=35.36h) Tetrathioether ([16]aneS4-diol) Radiotheranostics
// & Gold-199 (199Au, t1/2=3.139d) Cyclic RGDfK Glyconanoparticle Targeted Radiotherapy
// (RuO4 Distillation & Crown-Ether Au Extraction PINN-MPC + USP <823> / ISO 17873 / SIL-3 Interlocks)
// ============================================================================

targetScope = 'resourceGroup'

@description('Azure region for regional control plane and digital twin resources')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param envPrefix string = 'rh105au199trt'

@description('AKS Kubernetes version for radiochemical hot-cell edge-cloud orchestration')
param kubernetesVersion string = '1.31.2'

@description('Maximum volatile RuO4 vapor concentration in hot-cell exhaust before SIL-3 alkaline NaOH/NaHSO3 scrubber & hypochlorite quench hard lockout (mg/m3)')
param maxRuO4ExhaustVaporMgPerM3 string = '0.02'

@description('Maximum 198Au (t1/2=2.695d, 411.8 keV gamma) double-neutron-capture breakthrough ratio in 199Au eluate before SIL-3 quarantine lockout (%)')
param maxAu198BreakthroughPct string = '0.08'

@description('Maximum AuNP plasmonic red-shift / hydrodynamic diameter before SIL-3 aggregation embolism lockout (nm)')
param maxAuNpHydrodynamicDiameterNm string = '35.0'

var clusterName = '${envPrefix}-aks-aksclaw'
var acrName = replace('${envPrefix}acr233', '-', '')
var keyVaultName = '${envPrefix}-kv-233'
var logWorkspaceName = '${envPrefix}-law-233'
var iotHubName = '${envPrefix}-iothub-233'
var eventHubNamespaceName = '${envPrefix}-ehns-233'
var cosmosAccountName = '${envPrefix}-cosmos-233'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
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
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    minTlsVersion: '1.2'
    disableLocalAuth: true
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 16
    minimumTlsVersion: '1.2'
    zoneRedundant: true
  }
}

resource telemetryEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'rh105-319kev-au199-158kev-hpge-uvvis-spr-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 8
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

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'katapool'
        count: 4
        vmSize: 'Standard_D16s_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv-vm-isolation'
          'theranostics.azure.com/domain': 'rh105-tetrathioether-au199-rgdfk-au-np'
        }
      }
      {
        name: 'pinnpool'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'agent.azure.com/accelerator': 'nvidia-a100'
          'theranostics.azure.com/workload': 'ruo4-distillation-au199-spr-pinn-mpc'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
       networkDataplane: 'cilium'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterName string = aksCluster.name
output sil3SafetyThresholds object = {
  maxRuO4ExhaustVaporMgPerM3: maxRuO4ExhaustVaporMgPerM3
  maxAu198BreakthroughPct: maxAu198BreakthroughPct
  maxAuNpHydrodynamicDiameterNm: maxAuNpHydrodynamicDiameterNm
  standardCompliance: 'USP <823> / ISO 17873 / IEC 61511 SIL-3'
}
