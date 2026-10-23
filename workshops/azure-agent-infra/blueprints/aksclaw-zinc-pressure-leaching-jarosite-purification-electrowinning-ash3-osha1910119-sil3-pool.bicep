// blueprints/aksclaw-zinc-pressure-leaching-jarosite-purification-electrowinning-ash3-osha1910119-sil3-pool.bicep
// Blueprint #176 (175-Cycle & 175-Simulator Milestone!): Autonomous Zinc Oxygen Pressure Leaching (OPL 150 C / 1.3 MPa Sphalerite Autoclave ZnS + H2SO4 + 1/2 O2 -> ZnSO4 + S0 + H2O), Jarosite/Goethite Iron Precipitation, Zn-Dust Cementation Purification (Co/Ni/Cd/Ge Removal) & Giant Cellhouse Zinc Electrowinning PINN-MPC, Online 10 kHz IR Cathode-Busbar Short-Circuit Thermography / XRF-Voltammetry Trace Co-Ge-Sb / TDLAS Arsine-Stibine (AsH3/SbH3) Metrology & NFPA 70E / OSHA 1910.119 / ASME BPVC VIII / IEC 61511 SIL-3 Lethal Arsine/Stibine (<50 ppbv) Gas Evolution, Molten-Sulfur Autoclave Exotherm & Cellhouse H2-Acid-Mist Deflagration Interlock Sandbox
targetScope = 'resourceGroup'

@description('Azure region for the Zinc Pressure Leaching, Purification & Electrowinning Cellhouse edge-cloud cluster')
param location string = resourceGroup().location

@description('Environment name (prod-zinc-sil3 | staging-zinc-pinn)')
@allowed([
  'prod-zinc-sil3'
  'staging-zinc-pinn'
])
param environment string = 'prod-zinc-sil3'

@description('Prefix for AKS, Managed Lustre, Event Hubs, and Key Vault resources')
param namePrefix string = 'zincpinn'

@description('Number of Zinc OPL Autoclave & Electrowinning Cellhouse lines under autonomous PINN-MPC governance')
@minValue(1)
@maxValue(16)
param zincHydrometLines int = 8

@description('Maximum permissible Arsine/Stibine (AsH3/SbH3) concentration in purification hood (ppbv) before OSHA 1910.119 / IEC 61511 SIL-3 zinc-dust halt & KMnO4 scrubber interlock')
@minValue(10)
@maxValue(50)
param maxArsineStibinePpbv int = 35

@description('Maximum permissible OPL autoclave temperature (degC) before elemental sulfur viscosity-lock & sulfide oxidation runaway trip (155-162 C)')
@minValue(152)
@maxValue(162)
param maxAutoclaveTempC int = 158

var clusterName = '${namePrefix}-${environment}-aks'
var kvName = '${take(namePrefix, 8)}${uniqueString(resourceGroup().id)}kv'
var ehNamespaceName = '${namePrefix}-${environment}-eh'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
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

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: ehNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'zinc-opl-ash3-tdlas-ir-cellhouse-10khz'
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
  tags: {
    workload: 'zinc-pressure-leaching-jarosite-purification-electrowinning-ash3-sil3'
    safetyStandard: 'NFPA-70E-OSHA-1910-119-ASME-VIII-IEC-61511-SIL3'
    zincHydrometLines: string(zincHydrometLines)
    maxArsineStibinePpbv: string(maxArsineStibinePpbv)
    maxAutoclaveTempC: string(maxAutoclaveTempC)
  }
  properties: {
    dnsPrefix: '${namePrefix}-${environment}'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
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
        name: 'zincrt'
        count: 4
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/role': 'zinc-ash3-stibine-autoclave-cellhouse-sil3-interlock'
          'agent.azure.com/realtime-kernel': 'linux-rt-preempt'
        }
        nodeTaints: [
          'dedicated=zinc-rt-sil3:NoSchedule'
        ]
      }
      {
        name: 'zincpinn'
        count: 4
        vmSize: 'Standard_NV36ads_A10_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/role': 'zinc-opl-lignosulfonate-purification-electrowinning-pinn-mpc'
          'agent.azure.com/gpu-accelerated': 'true'
        }
        nodeTaints: [
          'sku=gpu-zinc-pinn:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output telemetryEventHubId string = telemetryHub.id
output keyVaultUri string = keyVault.properties.vaultUri
