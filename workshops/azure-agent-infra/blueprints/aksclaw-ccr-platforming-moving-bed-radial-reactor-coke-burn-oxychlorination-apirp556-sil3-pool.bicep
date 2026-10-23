// blueprints/aksclaw-ccr-platforming-moving-bed-radial-reactor-coke-burn-oxychlorination-apirp556-sil3-pool.bicep
// Blueprint #175: Autonomous Continuous Catalytic Reforming (CCR Platforming) & Moving-Bed Radial-Flow Reactor 490-540 C / 0.35-0.85 MPa Naphtha Dehydrocyclization/Aromatization, Pt-Sn/Al2O3 Catalyst Regeneration Coke-Burn & Oxychlorination Redispersion PINN-MPC, Online 10 kHz FT-NIR Research Octane Number (RON) / Capacitance Catalyst Mass-Flux / Laser Screen Delta-P Metrology & API RP 556 / NFPA 85 / OSHA 1910.119 / IEC 61511 SIL-3 Regenerator Thermal Runaway, Catalyst Pinning & H2/O2 Lock-Hopper Purge Interlock Sandbox
targetScope = 'resourceGroup'

@description('Azure region for the CCR Platforming & Moving-Bed Radial-Flow Reactor edge-cloud cluster')
param location string = resourceGroup().location

@description('Environment name (prod-ccr-sil3 | staging-ccr-pinn)')
@allowed([
  'prod-ccr-sil3'
  'staging-ccr-pinn'
])
param environment string = 'prod-ccr-sil3'

@description('Prefix for AKS, Managed Lustre, Event Hubs, and Key Vault resources')
param namePrefix string = 'ccrpinn'

@description('Number of stacked/side-by-side radial-flow CCR reactors (R-101 to R-104) under autonomous WAIT/WABT & regeneration control')
@minValue(1)
@maxValue(8)
param ccrReactorCount int = 4

@description('Target reformate Research Octane Number (RON) across the CCR reactor train (98.0-104.5 RON)')
param targetReformateRon string = '102.5'

@description('Maximum permissible regenerator burn-zone peak temperature (degC) before API RP 556 / IEC 61511 SIL-3 oxygen trim & nitrogen quench interlock')
@minValue(540)
@maxValue(610)
param maxRegenBurnTempC int = 565

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
  name: 'ccr-ftnir-ron-pinning-coke-burn-10khz'
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
    workload: 'ccr-platforming-moving-bed-radial-reactor-coke-burn-oxychlorination-sil3'
    safetyStandard: 'API-RP-556-NFPA-85-OSHA-1910-119-IEC-61511-SIL3'
    ccrReactorCount: string(ccrReactorCount)
    targetReformateRon: targetReformateRon
    maxRegenBurnTempC: string(maxRegenBurnTempC)
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
        name: 'ccrrt'
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
          'agent.azure.com/role': 'ccr-pinning-lockhopper-purge-sil3-interlock'
          'agent.azure.com/realtime-kernel': 'linux-rt-preempt'
        }
        nodeTaints: [
          'dedicated=ccr-rt-sil3:NoSchedule'
        ]
      }
      {
        name: 'ccrpinn'
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
          'agent.azure.com/role': 'ccr-lumped-kinetics-coke-burn-oxychlorination-pinn-mpc'
          'agent.azure.com/gpu-accelerated': 'true'
        }
        nodeTaints: [
          'sku=gpu-ccr-pinn:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output telemetryEventHubId string = telemetryHub.id
output keyVaultUri string = keyVault.properties.vaultUri
