// blueprints/cobalt55-58m-theranostics-and-copper-atsm-hypoxia-redox-trapping-sil3.bicep
// Cycle #227 — Chapter 232 / Blueprint #228
// Autonomous Cobalt-55 / Cobalt-58m Auger-PET Matched-Pair Theranostics (54Fe(d,n)55Co & 58Fe(p,n)58mCo Enriched Iron Targetry & DGA/AG1-X8 Fe3+ Partitioning) & Hypoxia-Selective Copper-ATSM Redox-Trapping PINN-MPC + USP <823> / 10 CFR 20 / ISO 17873 / IEC 61511 SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Co-55/58m Theranostics & Cu-ATSM Hypoxia Radiopharmacy Sandbox Cluster')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'co5558mcuatsmc227s3'

@description('Number of Co-55/58m enriched Fe-54/58 cyclotron & Cu-ATSM microfluidic trains')
@minValue(1)
@maxValue(64)
param coCuAtsmTrains int = 8

@description('AKS GPU node count (Standard_NC24ads_A100_v4) for 54Fe/58Fe Cross-Section, DGA/AG1-X8 Fe/Co Partitioning & Cu-ATSM Hypoxia Redox PINN-MPC')
param gpuNodeCount int = max(2, (coCuAtsmTrains + 1) / 2)

@description('USP <823> / 10 CFR 20 / ISO 17873 / IEC 61511 SIL-3 56Co/58gCo Impurity Quarantine, Cold Fe3+ Lockout & Target Delamination Crowbar Trip Target (ms)')
param sil3InterlockTargetMs string = '0.15'

var aksClusterName = '${envPrefix}-aksclaw-co55-58m-cuatsm'
var iotOpsNamespaceName = '${envPrefix}-iotops-hpge-ferrozine-cv-10khz'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
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
        name: 'co58mpinn'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/Accelerator': 'nvidia-a100-80gb'
          'agent.azure.com/Domain': 'cobalt55-58m-theranostics-and-copper-atsm-hypoxia-redox-trapping-sil3'
          'agent.azure.com/PinnModel': 'fe54-fe58-co55-co58m-dga-ag1x8-and-cu-atsm-hypoxia-redox-pinn-mpc'
          'agent.azure.com/SafetyStandard': 'USP-823-10CFR20-EU-GMP-Annex3-ISO17873-IEC61511-SIL3'
          'agent.azure.com/Sil3TripTargetMs': sil3InterlockTargetMs
          'agent.azure.com/EdgeTelemetry': '10kHz-BeWindow-HPGe-Ferrozine-UVVis-MicroCV-Redox'
        }
        nodeTaints: [
          'sku=gpu-co55-58m-cuatsm-sil3:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
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

output aksClusterResourceId string = aksCluster.id
output iotOpsEdgeNamespace string = iotOpsNamespaceName
output configuredCoCuAtsmTrains int = coCuAtsmTrains
output sil3Co5658gQuarantineFe3LockoutAndTargetCrowbarMs string = sil3InterlockTargetMs
