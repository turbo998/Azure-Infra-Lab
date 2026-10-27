// blueprints/cos-carbonyl-sulfide-distillation-and-har-etch-pinn-mpc-sil3.bicep
// Cycle #234 (235-Blueprint Milestone!): Electronic-Grade Carbonyl Sulfide (5N5 COS >= 99.9995% for 3D NAND/DRAM HAR Contact Etching)
// Catalytic CO+S Synthesis, Disproportionation Suppression (2COS <-> CO2 + CS2), Cryogenic Fractional Distillation (222.95 K) &
// Trace Moisture Hydrolysis Prevention (COS + H2O <-> CO2 + H2S) PINN-MPC, In-Situ 10kHz Mid-IR QCL-TDLAS (4.85 um COS / 4.26 um CO2 /
// 6.51 um CS2 / 1.57 um H2S) & CRDS (1.39 um H2O) Metrology & SEMI C3 / NFPA 55 / ISO 11114-1 / IEC 61511 SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 5N5 Carbonyl Sulfide (COS) Cryogenic Distillation & HAR-RIE Etch Gas PINN-MPC & SIL-3 Interlock infrastructure')
param location string = resourceGroup().location

@description('Environment prefix (prod, staging, lab)')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('Target 5N5 COS purity fraction (default 0.999995 = 5N5)')
param targetCosPurityFraction string = '0.999995'

@description('Maximum allowable H2S hydrolysis impurity concentration (ppmv) before SEMI C3 / SIL-3 column reflux diversion')
param maxH2sImpurityPpmv string = '0.10'

@description('Maximum allowable CS2 disproportionation impurity concentration (ppmv) before catalytic quench adjustment')
param maxCs2ImpurityPpmv string = '0.20'

@description('Maximum liquefied COS cylinder fill density (kg/L) per NFPA 55 / CGA P-1 to prevent liquid-full hydrostatic rupture')
param maxCosFillDensityKgPerL string = '1.02'

var prefix = 'cos5n5-${environment}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.235.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-kata-cos-pinn-snet'
        properties: {
          addressPrefix: '10.235.1.0/24'
        }
      }
      {
        name: 'iot-qcl-tdlas-crds-edge-snet'
        properties: {
          addressPrefix: '10.235.2.0/24'
        }
      }
      {
        name: 'sil3-h2s-cos-scrubber-snet'
        properties: {
          addressPrefix: '10.235.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${prefix}-aksclaw'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${prefix}-aks'
    agentPoolProfiles: [
      {
        name: 'katavmpool'
        count: 4
        vmSize: 'Standard_D16s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${prefix}-ehns'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 16
  }
}

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'cos-qcl-tdlas-4850nm-crds-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 8
  }
}

resource safetyPolicyConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: '${prefix}-appcfg'
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
  }
}

resource cosPurityTargetKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'CosCryoDistillationPinnMpc$TargetCosPurityFraction'
  properties: {
    value: targetCosPurityFraction
    contentType: 'text/plain'
  }
}

resource maxH2sKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa55Sil3$MaxH2sImpurityPpmv'
  properties: {
    value: maxH2sImpurityPpmv
    contentType: 'text/plain'
  }
}

resource maxCs2Key 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa55Sil3$MaxCs2ImpurityPpmv'
  properties: {
    value: maxCs2ImpurityPpmv
    contentType: 'text/plain'
  }
}

resource maxFillDensityKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa55Sil3$MaxCosFillDensityKgPerL'
  properties: {
    value: maxCosFillDensityKgPerL
    contentType: 'text/plain'
  }
}

output aksClusterName string = aksCluster.name
output telemetryEventHubName string = telemetryHub.name
output safetyConfigEndpoint string = safetyPolicyConfig.properties.endpoint
