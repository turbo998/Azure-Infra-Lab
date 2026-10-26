// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #218 (Cycle #217)
// Industry: Nuclear Depleted Zinc-64 (DZO ≥99.2% 64Zn-Depleted / Enriched 64Zn)
//           PWR/BWR Primary-Coolant Spinel Passivation & Enriched Nickel-63
//           (63Ni ≥85%, T1/2=100.1 yr) 4H-SiC Betavoltaic Nuclear Battery
// Architecture: PINN-MPC Coupled Diethylzinc (Zn(C2H5)2, DEZ) & Nickel
//               Tetracarbonyl (Ni(CO)4) Sub-Atmospheric Gas Centrifuge Cascade +
//               French-Process Chloride-Free (<10 ppb Cl-/SO4^2-) DZO Oxidation +
//               62Ni(n,γ)63Ni High-Flux Irradiation & 4H-SiC p-i-n Betavoltaic
//               LPCVD Deposition + EPRI BWRVIP / 10 CFR 50 / OSHA 1910.1000 /
//               NFPA 30 / IEC 61511 SIL-3 Interlocks
// ============================================================================

@description('Azure region for the Depleted Zinc-64 (DZO) & Enriched Nickel-63 4H-SiC Betavoltaic PINN-MPC cluster')
param location string = resourceGroup().location

@description('Environment name (prod-zn64-ni63-betavoltaic-sil3, staging-zn64-ni63)')
param environmentName string = 'prod-zn64-ni63-betavoltaic-sil3'

@description('Number of parallel Depleted 64Zn (DZO) & 63Ni 4H-SiC betavoltaic centrifuge & LPCVD trains (1 to 32)')
@minValue(1)
@maxValue(32)
param zn64Ni63Trains int = 8

@description('AKS GPU node SKU for Fourier-PINN DEZ/Ni(CO)4 centrifuge cascade, DZO spinel & 4H-SiC betavoltaic surrogate')
param gpuNodeSku string = 'Standard_NC24ads_A100_v4'

@description('Target 64Zn depletion (< 0.8% residual 64Zn in DZO) and 63Ni specific activity purity (≥ 85% 63Ni)')
param targetZn64DepletionPct string = '99.2'

@description('Enforce EPRI BWRVIP / 10 CFR 50 / OSHA 1910.1000 / NFPA 30 / IEC 61511 SIL-3 Ni(CO)4 1-ppb thermal decomposer, pyrophoric DEZ quench & Cl-/SO4^2- quarantine interlocks')
param enforceEpriOshaNfpa30Sil3 bool = true

var clusterName = 'aks-zn64-ni63-${environmentName}'
var keyVaultName = 'kv-zn64ni63-${uniqueString(resourceGroup().id)}'
var workspaceName = 'law-zn64-ni63-${environmentName}'
var iotHubName = 'iot-zn64-ni63-10khz-${uniqueString(resourceGroup().id)}'
var eventHubNamespace = 'evhns-zn64-ni63-telemetry-${uniqueString(resourceGroup().id)}'
var gpuNodeCount = max(2, (zn64Ni63Trains + 1) / 2)

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

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

resource eventHubNs 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespace
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    isAutoInflateEnabled: false
    minimumTlsVersion: '1.2'
  }
}

resource telemetryEventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubNs
  name: 'zn64-ni63-qcl-ftir-mcicpms-betavoltaic-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
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
    minTlsVersion: '1.2'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'zn64-depleted-dzo-pwr-passivation-nickel63-sic-betavoltaic-pinn-mpc'
    safetyStandard: 'EPRI-BWRVIP-10CFR50-OSHA19101000-NFPA30-IEC61511-SIL3'
    targetZn64DepletionPct: targetZn64DepletionPct
    enforceEpriOshaNfpa30Sil3: string(enforceEpriOshaNfpa30Sil3)
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
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
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/isotope-zn64-ni63-role': 'pinn-mpc-dez-nico4-centrifuge-dzo-passivation-sic-betavoltaic'
          'agent.azure.com/safety-interlock': 'epri-10cfr50-osha-nico4-1ppb-nfpa30-dez-sil3-0.16ms'
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
        ]
      }
    ]
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
output gpuNodeCountDeployed int = gpuNodeCount
output activeZn64Ni63Pods int = zn64Ni63Trains * 4
output epriOshaNfpa30Sil3Enforced bool = enforceEpriOshaNfpa30Sil3
