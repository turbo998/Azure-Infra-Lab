// blueprints/hcds-hexachlorodisilane-vacuum-distillation-and-ald-pinn-mpc-sil3.bicep
// Cycle #235 (235-Cycle & 235-Simulator Double Milestone!): Electronic-Grade Hexachlorodisilane (6N HCDS Si2Cl6 >= 99.9999%) &
// Octachlorotrisilane (OCTS Si3Cl8) Low-Temperature 3D NAND / 2nm GAA Atomic Layer Deposition (SiN/SiCN/SiO2 Spacer & Liner ALD)
// Vacuum Fractional Distillation (45-52 C at 15-25 Torr Suppressing Si2Cl6 -> SiCl4 + [:SiCl2]n Disproportionation),
// Hexachlorodisiloxane (Cl3Si-O-SiCl3 HCDOS <= 0.5 ppmv) Suppression & Heated Ampoule/Bubbler Vapor-Pressure Delivery PINN-MPC,
// Online 10 kHz High-Temperature FTIR/QCL-TDLAS (1080 cm-1 Si-O-Si / 2210 cm-1 Si-H) + Raman (408 cm-1 Si-Si) + Piezo-Sonic Metrology &
// SEMI C3 / NFPA 704 / CGA P-1 / IEC 61511 SIL-3 Shock-Sensitive Explosive Siloxane Hydrolysis & Line Condensation Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 6N Hexachlorodisilane (HCDS Si2Cl6) Vacuum Distillation & Low-Temp ALD PINN-MPC & SIL-3 Interlock infrastructure')
param location string = resourceGroup().location

@description('Environment prefix (prod, staging, lab)')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('Target 6N HCDS (Si2Cl6) purity fraction (default 0.999999 = 6N)')
param targetHcdsPurityFraction string = '0.999999'

@description('Maximum allowable Hexachlorodisiloxane (Cl3Si-O-SiCl3 HCDOS) impurity concentration (ppmv) before SEMI C3 / SIL-3 column diversion')
param maxHcdosSiloxaneImpurityPpmv string = '0.50'

@description('Maximum allowable Vacuum Distillation Reboiler skin temperature (C) to prevent thermal disproportionation (Si2Cl6 -> SiCl4 + [:SiCl2]n)')
param maxReboilerSkinTempC string = '92.0'

@description('Minimum heated ALD vapor delivery manifold trace temperature (C) to prevent HCDS liquid condensation')
param minManifoldTraceTempC string = '65.0'

var prefix = 'hcds6n-${environment}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.236.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-kata-hcds-pinn-snet'
        properties: {
          addressPrefix: '10.236.1.0/24'
        }
      }
      {
        name: 'iot-ftir-raman-piezosonic-edge-snet'
        properties: {
          addressPrefix: '10.236.2.0/24'
        }
      }
      {
        name: 'sil3-hydrolysis-n2-purge-snet'
        properties: {
          addressPrefix: '10.236.3.0/24'
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
  name: 'hcds-ftir-1080cm1-raman-408cm1-10khz'
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

resource hcdsPurityTargetKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'HcdsVacuumDistillationPinnMpc$TargetHcdsPurityFraction'
  properties: {
    value: targetHcdsPurityFraction
    contentType: 'text/plain'
  }
}

resource maxHcdosSiloxaneKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa704Sil3$MaxHcdosSiloxaneImpurityPpmv'
  properties: {
    value: maxHcdosSiloxaneImpurityPpmv
    contentType: 'text/plain'
  }
}

resource maxReboilerSkinTempKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa704Sil3$MaxReboilerSkinTempC'
  properties: {
    value: maxReboilerSkinTempC
    contentType: 'text/plain'
  }
}

resource minManifoldTraceTempKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = {
  parent: safetyPolicyConfig
  name: 'SemiC3Nfpa704Sil3$MinManifoldTraceTempC'
  properties: {
    value: minManifoldTraceTempC
    contentType: 'text/plain'
  }
}

output aksClusterName string = aksCluster.name
output telemetryEventHubName string = telemetryHub.name
output safetyConfigEndpoint string = safetyPolicyConfig.properties.endpoint
