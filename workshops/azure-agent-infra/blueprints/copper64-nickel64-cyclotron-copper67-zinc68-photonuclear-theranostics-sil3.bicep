// =============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #225 (Cycle #224 · 225-Blueprint Milestone!)
// Chapter 229: Autonomous Copper-64 / Copper-67 (n.c.a. 64Cu / 67Cu True Chemical-Identical
//              Theranostic Pair: 64Cu T1/2=12.70h beta+ PET via 12.0 MeV Proton Electroplated
//              Enriched Nickel-64 64Ni >=99.5% Gold-Backed Target 64Ni(p,n)64Cu & AG 1-X8
//              Anion-Exchange Chromatography + >99.5% 64Ni Recovery, and 67Cu T1/2=61.83h
//              beta-/gamma 184.6 keV Radioimmunotherapy via 40 MeV Electron-Linac Bremsstrahlung
//              Photonuclear 68Zn(gamma,p)67Cu on Enriched Zinc-68 68Zn >=99.2% Target &
//              Ultra-Trace Cold-Cu2+/Zn2+ <0.1 ppb Separation for >150 GBq/umol Molar Activity)
//              PINN-MPC, Online 10 kHz HPGe Gamma, TETA/Sar Titration Molar-Activity &
//              Bremsstrahlung Converter Metrology & USP <823> / 10 CFR 35 / EU GMP Annex 3 /
//              ISO 17873 / IEC 61511 SIL-3 Interlock
// =============================================================================

@description('Deployment Azure region for the Copper-64 / Copper-67 Theranostic Cyclotron & Photonuclear Linac AKS + Kata Pod VM cluster')
param location string = resourceGroup().location

@description('Environment prefix')
param environmentName string = 'prod-cu64-cu67-theranostics-sil3'

@description('Kubernetes version for the AKS cluster')
param kubernetesVersion string = '1.31.2'

@description('GPU node count for 12MeV 64Ni(p,n)64Cu AG1-X8 Chromatography & 40MeV e-Linac Bremsstrahlung 68Zn(gamma,p)67Cu PINN-MPC (Standard_NC24ads_A100_v4)')
@minValue(1)
@maxValue(32)
param gpuNodeCount int = 4

@description('Real-time deterministic node count for USP <823> / 10 CFR 35 / ISO 17873 / SIL-3 Tantalum Converter Burnthrough, Cold-Metal Quarantine & 64Ni Salvage Interlock (Standard_F16s_v2)')
@minValue(2)
@maxValue(32)
param rtSil3NodeCount int = 4

@description('Minimum molar activity floor for n.c.a. 64Cu / 67Cu Sarcophagine/DOTA radiolabeling in GBq/umol')
param minMolarActivityGbqPerUmol int = 150

var clusterName = 'aks-${environmentName}'
var identityName = 'id-${environmentName}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: environmentName
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
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
        osSKU: 'AzureLinux'
        enableAutoScaling: false
      }
      {
        name: 'cu64c224s3'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'cu64-ni64-cyclotron-cu67-zn68-photonuclear-pinn-mpc'
          'agent.azure.com/metrology': '10khz-hpge-gamma-teta-titration-molar-activity-linac-converter'
          'agent.azure.com/isolation': 'kata-mshv-vm-isolation'
        }
      }
      {
        name: 'cu64c224rt'
        count: rtSil3NodeCount
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'usp823-iso17873-sil3-ta-converter-cold-metal-ni64-salvage-interlock'
          'agent.azure.com/molar-activity-floor-gbq-umol': string(minMolarActivityGbqPerUmol)
          'agent.azure.com/latency-target': 'sub-0.16ms'
        }
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output pinnMpcNodePool string = 'cu64c224s3'
output sil3InterlockNodePool string = 'cu64c224rt'
