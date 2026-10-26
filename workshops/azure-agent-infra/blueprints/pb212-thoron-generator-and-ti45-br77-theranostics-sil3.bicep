// blueprints/pb212-thoron-generator-and-ti45-br77-theranostics-sil3.bicep
// Blueprint #230 (230-Blueprint Milestone!): Autonomous Lead-212 / Bismuth-212 In-Vivo Alpha Generator (228Th/224Ra -> 220Rn Thoron Emanation / Pb-Spec Extraction & TCMC/DOTAM Chelation) & Titanium-45 / Bromine-76/77 Positron/Meitner-Auger Theranostic Pair (45Sc(p,n)45Ti Microfluidic Non-Hydrolytic Trapping & Enriched 76/77Se-Cu2Se Dry Thermal Distillation) PINN-MPC & USP <823> / 10 CFR 35.1000 / ISO 17873 / SIL-3 Sandbox
targetScope = 'resourceGroup'

@description('Azure region for the Lead-212/Bismuth-212 & Titanium-45/Bromine-76/77 Theranostic Digital Twin enclave')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'pb212br77s3'

@description('AKS Kubernetes version for hybrid edge-cloud radiochemistry orchestration')
param kubernetesVersion string = '1.31.2'

@description('Thorium-228 / Radium-224 generator inventory activity (GBq) for 220Rn/212Pb production')
param th228Ra224GeneratorInventoryGbq int = 185

@description('Cyclotron proton beam energy (MeV, scaled x10) for 45Sc(p,n)45Ti & 76/77Se(p,n)76/77Br reactions')
param cyclotronProtonEnergyMevX10 int = 142

@description('Maximum permissible 228Th / 224Ra long-lived parent breakthrough ratio (ppb)')
param maxParentBreakthroughPpb int = 10

@description('Maximum permissible 208Tl 2.615 MeV hot-cell exterior dose rate (uSv/h, scaled x10)')
param maxTl208ExteriorDoseRateUsvPerHrX10 int = 25

@description('Maximum permissible 220Rn (Thoron) exhaust stack activity concentration (Bq/m3)')
param maxThoronRn220StackBqPerM3 int = 40

var aksClusterName = '${envPrefix}-aks-theranostic-twin'
var iotHubName = '${envPrefix}-iothub-labr3-hpge-10khz'
var adxClusterName = '${envPrefix}adxradionuclide'
var keyVaultName = '${envPrefix}-kv-usp823-sil3'

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
    name: 'Standard_E8ads_v5'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: false
  }
}

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: 'Pb212ThoronAndTi45Br77TelemetryDb'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P3650D'
    hotCachePeriod: 'P90D'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
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
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcgpu'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'pb212-ti45-br77-pinn-mpc'
          'safety/standard': 'usp823-10cfr35-iso17873-sil3'
        }
      }
      {
        name: 'sil3plcgate'
        count: 3
        vmSize: 'Standard_F8s_v2'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'thoron-cryo-trap-and-cu2se-crowbar-sil3'
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

output aksClusterResourceId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output adxClusterUri string = adxCluster.properties.uri
output safetyInterlockSpec object = {
  blueprintMilestone: 230
  standard: 'USP <823> / 10 CFR 35.1000 / ISO 17873 / IEC 61508 SIL-3'
  th228Ra224GeneratorInventoryGbq: th228Ra224GeneratorInventoryGbq
  cyclotronProtonEnergyMev: cyclotronProtonEnergyMevX10 / 10
  maxParentBreakthroughPpb: maxParentBreakthroughPpb
  maxTl208ExteriorDoseRateUsvPerHr: maxTl208ExteriorDoseRateUsvPerHrX10 / 10
  maxThoronRn220StackBqPerM3: maxThoronRn220StackBqPerM3
  hardwiredInterlockAction: 'ISOLATE_PB_SPEC_COLUMN_LOCK_MINUS90C_THORON_SILVER_ZEOLITE_TRAP_AND_CROWBAR_CU2SE_RF_FURNACE_UNDER_1_2MS'
}
