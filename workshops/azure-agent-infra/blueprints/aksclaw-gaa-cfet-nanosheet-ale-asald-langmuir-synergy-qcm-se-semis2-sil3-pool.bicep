// ============================================================================
// AKSClaw Sub-2nm GAA Nanosheet & CFET Atomic Layer Etching (ALE) & Area-Selective
// Atomic Layer Deposition (AS-ALD) Langmuir Self-Limiting Synergy Window, SiGe/Si
// Inner-Spacer Cavity Selectivity & Ion-Energy Angular Distribution (IEAD) PINN-MPC,
// Online 20 kHz Spectroscopic Ellipsometry (SE) / Quartz Crystal Microbalance (QCM)
// / Retarding-Field Energy Analyzer (RFEA) Metrology & SEMI S2 / S8 / NFPA 318 /
// IEC 61511 SIL-3 Pyrophoric Precursor (TMA/WF6/BCl3) Purge & RF Arc Interlock (#169)
// ============================================================================

@description('Azure region for the AKSClaw Sub-2nm GAA/CFET ALE & AS-ALD cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Sub-2nm GAA/CFET ALE & AS-ALD PINN-MPC & 20 kHz SE/QCM/RFEA edge')
param clusterName string = 'aksclaw-gaa-cfet-ale-asald-sil3'

@description('Kubernetes version for AKSClaw control plane and node pools')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC & 20 kHz In-Situ SE / QCM / RFEA Edge GPU VM size')
param pinnGpuVmSize string = 'Standard_NV36ads_A10_v5'

@description('Kata-isolated SEMI S2 / NFPA 318 / SIL-3 Pyrophoric TMA/BCl3 Purge & RF Arc Interlock VM size')
param safetyKataVmSize string = 'Standard_D16s_v5'

@description('Target ALE synergy factor (> 95% self-limiting monolayer etch accuracy)')
param targetAleSynergyPct int = 96

@description('Target SiGe:Si selective isotropic cavity etch selectivity ratio')
param targetSigeSiSelectivityRatio int = 180

@description('SIL-3 pyrophoric precursor isolation & RF bias arc crowbar latency (ms)')
param sil3InterlockLatencyMs string = '0.3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'gaa-cfet-nanosheet-ale-asald-langmuir-synergy-qcm-se-semis2-sil3'
    industryStandard: 'SEMI-S2-SEMI-S8-NFPA-318-IEC-61511-SIL3'
    pinnModel: 'langmuir-chemisorption-iead-sputter-synergy-sige-cavity-asald-nucleation-pinn'
    edgeMetrology: '20khz-in-situ-se-qcm-rfea-ion-energy-metrology'
    blueprintIndex: '169'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
      outboundType: 'userDefinedRouting'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'alepinn'
        count: 4
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        enableAutoScaling: true
        minCount: 2
        maxCount: 8
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'aksclaw.io/workload-tier': 'gaa-cfet-ale-asald-langmuir-iead-pinn-mpc-gpu'
          'aksclaw.io/edge-metrology': '20khz-spectroscopic-ellipsometry-qcm-rfea'
          'aksclaw.io/ale-synergy-pct': string(targetAleSynergyPct)
          'aksclaw.io/sige-si-selectivity': string(targetSigeSiSelectivityRatio)
        }
        nodeTaints: [
          'aksclaw.io/gpu-pinn=true:NoSchedule'
        ]
      }
      {
        name: 'alesil3'
        count: 3
        vmSize: safetyKataVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'aksclaw.io/isolation': 'kata-mshv-vm'
          'aksclaw.io/safety-standard': 'SEMI-S2-SEMI-S8-NFPA-318-IEC-61511-SIL3'
          'aksclaw.io/interlock-target': 'pyrophoric-tma-wf6-bcl3-double-block-purge-rf-crowbar'
          'aksclaw.io/sil3-latency-ms': sil3InterlockLatencyMs
        }
        nodeTaints: [
          'aksclaw.io/sil3-interlock=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output pinnNodePoolName string = 'alepinn'
output safetyKataPoolName string = 'alesil3'
output safetyComplianceProfile string = 'SEMI-S2_SEMI-S8_NFPA-318_IEC-61511-SIL3_${sil3InterlockLatencyMs}ms'
