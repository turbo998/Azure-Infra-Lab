@description('Azure region for the AKSClaw Chlor-Alkali Ion-Exchange Membrane Electrolyzer & Euro Chlor GEST / SIL-3 Cl2-in-H2 Interlock Pool')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the Chlor-Alkali Membrane Electrolyzer & Zero-Gap Cell Room Digital Twin control plane')
param aksClusterName string = 'aks-agent-infra-chloralkali'

@description('VM size for the Nernst-Donnan Bilayer Membrane Transport, Differential-Pressure & TDLAS H2-in-Cl2 PINN-MPC pool')
param vmSize string = 'Standard_F16s_v2'

@description('Minimum node count for deterministic bipolar electrolyzer stack & brine chelating resin control')
@minValue(3)
param minCount int = 3

@description('Maximum node count for multi-electrolyzer cell room load-following bursts')
@minValue(6)
param maxCount int = 18

@description('Maximum H2-in-Cl2 wet chlorine header concentration (vol%) before Euro Chlor GEST / SIL-3 rectifier trip & N2 dilution purge')
param maxH2InCl2VolPct string = '2.5'

@description('Target cathode-to-anode differential pressure ΔP_H2_Cl2 (mbar) across zero-gap bilayer perfluorinated membrane')
param targetDiffPressureMbar string = '25.0'

@description('Maximum ultrapure brine alkaline-earth hardness Ca2+ + Mg2+ (ppb) before chelating resin regeneration')
param maxBrineHardnessPpb string = '20.0'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource chlorAlkaliPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'chloralkpool'
  properties: {
    mode: 'User'
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: minCount
    maxCount: maxCount
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.azure.com/workload': 'chlor-alkali-membrane-electrolyzer-sil3'
      'agent.azure.com/isolation': 'kata-mshv-vm'
      'agent.azure.com/electrochem-standard': 'euro-chlor-gest-79-82-nfpa-68-iec-61511-sil3'
      'agent.azure.com/cell-technology': 'zero-gap-bilayer-pfse-pfca-membrane-dsa'
      'agent.azure.com/max-h2-in-cl2-vol-pct': maxH2InCl2VolPct
      'agent.azure.com/target-dp-mbar': targetDiffPressureMbar
      'agent.azure.com/max-brine-hardness-ppb': maxBrineHardnessPpb
    }
    nodeTaints: [
      'agent.azure.com/chlor-alkali-membrane-electrolyzer-sil3=true:NoSchedule'
    ]
    tags: {
      scenario: 'chlor-alkali-membrane-electrolyzer-cl2-h2-eurochlor-sil3'
      compliance: 'Euro-Chlor-GEST-79-82-NFPA-68-IEC-61511-SIL3'
      architecture: 'AKSClaw-Kata-ZeroGap-Bipolar-Electrolyzer-TDLAS-Interlock'
    }
  }
}

output poolResourceId string = chlorAlkaliPool.id
output complianceStandard string = 'Euro Chlor GEST 79/82 + Pamphlet 100 + NFPA 68 + IEC 61511 SIL-3'
output safetyInterlockTopology string = 'TDLAS H2-in-Cl2 <2.5 vol% + ΔP_H2_Cl2 +25 mbar + Brine Ca/Mg <20 ppb + 80A Polarization Rectifier & N2 Inerting Purge'
