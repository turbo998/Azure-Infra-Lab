// Blueprint #207: Autonomous Gadolinium (Gd), Holmium (Ho) & Erbium (Er) Extraction-Distillation (5N),
// UO2-Gd2O3 Nuclear Burnable Poison Fuel Pellet Sintering, 20 K LH2 Magnetocaloric AMR (Gd5Si2Ge2/HoB2 PREP),
// Submarine C+L-Band EDFA MCVD Preform & 2.94 um Er:YAG / 2.1 um Ho:YAG Mid-IR Laser PINN-MPC + SIL-3 Pool (Cycle #206 · 215-Test Milestone!)

param clusterName string = 'aksclaw-gd-ho-er-nuclear-amr-edfa-sil3'
param location string = resourceGroup().location
param kubernetesVersion string = '1.30.6'
param gpuNodeCount int = 4
param realtimeSafetyNodeCount int = 3

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        mode: 'System'
      }
      {
        // PINN-MPC Pool: UO2-Gd2O3 Kirkendall Interdiffusion & O/M=2.000 Phase-Field,
        // Gd5Si2Ge2/HoB2 PREP Atomization & Magnetocaloric DeltaS_M, and MCVD Er3+/Al3+ Pair-Induced Quenching (PIQ) PINN
        name: 'gdhoerpinn'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'gd-ho-er-uo2-gd2o3-magnetocaloric-edfa-eryag-pinn-mpc'
          'agent.azure.com/metrology': '10khz-tims-icpms-xrf-and-edfa-osa-piq'
          'agent.azure.com/isolation': 'kata-vm'
        }
        nodeTaints: [
          'gpu-pinn-workload=true:NoSchedule'
        ]
      }
      {
        // Deterministic 10 CFR 50 / NFPA 484 / OSHA 1910.1000 / SEMI S2 / IEC 61511 SIL-3 Interlock Pool (0.24 ms response)
        name: 'gdhoersil3'
        count: realtimeSafetyNodeCount
        vmSize: 'Standard_F16s_v2'
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        enableUltraSSD: true
        nodeLabels: {
          'agent.azure.com/workload': 'cfr50-nfpa484-semis2-sil3-uo2-gd2o3-mcvd-prep-interlock'
          'agent.azure.com/safety-standard': '10cfr50-nfpa484-osha19101000-semis2-iec61511-sil3'
          'agent.azure.com/interlock-budget-ms': '0.24'
        }
        nodeTaints: [
          'sil3-safety-critical=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
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

output clusterResourceId string = aksCluster.id
output pinnNodePoolSku string = 'Standard_NC24ads_A100_v4'
output safetyInterlockBudgetMs string = '0.24'
