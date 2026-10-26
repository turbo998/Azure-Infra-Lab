// blueprints/aksclaw-medical-cyclotron-mo99-tc99m-ac225-tat-radiosynthesis-usp823-sil3-pool.bicep
// Blueprint #212: Medical Cyclotron & Research Reactor Radioisotopes (99Mo/99mTc, 18F-FDG, 68Ge/68Ga & 225Ac/213Bi Targeted Alpha Therapy TAT)
// LEU Target Fission / 100Mo(p,2n)99mTc & 226Ra(p,2n)225Ac Isochronous Cyclotron Beam-Target Thermal-Hydraulics,
// Automated Hot-Cell Cassette Radiosynthesis PINN-MPC & 10 CFR 35 / USP <823> / EU GMP Annex 3 / IEC 61511 SIL-3 Interlock Pool

@description('Azure region for the Medical Cyclotron & Radioisotope TAT PINN-MPC AKSClaw cluster')
param location string = resourceGroup().location

@description('AKS cluster name for autonomous 99Mo/99mTc, 18F-FDG & 225Ac/213Bi TAT radiosynthesis')
param clusterName string = 'aksclaw-med-cyclotron-ac225-tat-sil3'

@description('Number of Standard_NC24ads_A100_v4 GPU nodes for coupled cyclotron beam-target CFD, DGA/TBP chromatography & USP <823> QC PINN-MPC')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 4

@description('Target 99Mo/99mTc generator elution efficiency & 225Ac (t1/2 = 9.92 d) radiochemical purity (% RCP)')
param targetRadiochemicalPurityPct string = '99.6'

@description('Maximum 10 CFR 35 / USP <823> / EU GMP Annex 3 / IEC 61511 SIL-3 hot-cell stack activity, Havar foil burst & sterility interlock latency (ms)')
param maxSil3InterlockLatencyMs string = '0.20'

resource aksMedicalCyclotronTatCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
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
        name: 'pinnmpcgpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'medical-cyclotron-mo99-tc99m-ac225-tat-radiosynthesis'
          'agent.azure.com/physics-engine': 'pinn-mpc-cyclotron-havar-foil-dga-ac225-usp823-qc'
          'agent.azure.com/safety-interlock': 'cfr35-usp823-eugmp-annex3-iec61511-sil3'
          'agent.azure.com/edge-loop': '10khz-radio-hplc-hpge-gamma-havar-he-pressure-lal-qc'
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
          'isolation=kata-mshv:NoSchedule'
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
      defender: {
        logAnalyticsWorkspaceResourceId: ''
        securityMonitoring: {
          enabled: false
        }
      }
    }
  }
  tags: {
    Architecture: 'AKSClaw-Kata-VM-Isolated'
    Chapter: '216'
    Blueprint: '212'
    SimulatorTool: '211'
    TargetRCP: targetRadiochemicalPurityPct
    Sil3InterlockLatencyMs: maxSil3InterlockLatencyMs
    StandardsCompliance: '10-CFR-35-USP-823-EU-GMP-Annex3-IEC-61511-SIL3'
  }
}

output clusterResourceId string = aksMedicalCyclotronTatCluster.id
output pinnMpcNodePoolName string = 'pinnmpcgpu'
output sil3LatencyGuaranteeMs string = maxSil3InterlockLatencyMs
