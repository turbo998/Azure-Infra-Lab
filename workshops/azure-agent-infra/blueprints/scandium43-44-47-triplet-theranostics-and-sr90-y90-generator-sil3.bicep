// ============================================================================
// Blueprint #231 (Cycle #230 — 230-Cycle & 230-Simulator Double Milestone!):
// Autonomous Element-Identical Scandium Triplet Theranostics (n.c.a. Sc-43 /
// Sc-44g / Sc-47 via Enriched Ca-43/44 Cyclotron & Ti-48(gamma,p)Sc-47
// Photonuclear DGA/UTEVA Chromatography) & Pure-Beta Yttrium-90 (Sr-90/Y-90
// Dual-Stage Sr-Spec Generator <10^-8 Breakthrough & TARE Microspheres)
// PINN-MPC, Online 10 kHz HPGe + Cherenkov/Beta Spectroscopy & USP <823> /
// 10 CFR 35.1000 / EU GMP Annex 3 / ISO 17873 / IEC 61511 SIL-3 Interlock
// ============================================================================

@description('Deployment Azure region for Scandium-43/44g/47 & Sr-90/Y-90 Theranostics Agent Infra')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'sc47y90s3'

@description('AKS Kata confidential compute node VM size for PINN-MPC & 10 kHz HPGe/Cherenkov edge')
param aksNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Maximum USP <823> / ISO 17873 / SIL-3 Sr-90 breakthrough, Sc-46 quarantine & CaO target crowbar trip latency (ms)')
param sil3MaxSr90Sc46AndCaOTargetTripMs string = '0.15'

@description('Maximum allowed bone-seeking Sr-90 parent breakthrough in Y-90 eluate (fraction)')
param maxSr90ParentBreakthroughFraction string = '1e-8'

@description('Maximum allowed long-lived Sc-46 (83.79 d) radionuclide impurity in Sc-47 product (%)')
param maxSc46ImpurityPct string = '0.01'

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
  name: '${envPrefix}-aksclaw-kata'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-aks'
    agentPoolProfiles: [
      {
        name: 'katapool'
        count: 3
        vmSize: aksNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'System'
        nodeLabels: {
          'agent.azure.com/domain': 'sc43-44-47-triplet-and-sr90-y90-generator-theranostics'
          'agent.azure.com/pinn-mpc': 'ca43-44-p-n-ti48-gamma-p-dga-uteva-and-sr90-y90-srspec'
          'agent.azure.com/safety-interlock': 'usp823-10cfr35-iso17873-sil3-0.15ms'
          'agent.azure.com/edge-metrology': '10khz-hpge-cherenkov-plastic-beta-and-arsenazo-iii'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub-10khz'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 8
      }
    }
  }
}

output clusterName string = aksCluster.name
output sil3TripSloMs string = sil3MaxSr90Sc46AndCaOTargetTripMs
output sr90BreakthroughLimit string = maxSr90ParentBreakthroughFraction
output sc46ImpurityLimitPct string = maxSc46ImpurityPct
