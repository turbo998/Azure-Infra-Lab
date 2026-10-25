// blueprints/aksclaw-lanthanum-cerium-bastnasite-roasting-ceo2-cmp-slurry-lab6-emitter-lani5-hydride-sil3-pool.bicep
// Blueprint #205 (Cycle #204 — 210-Chapter & 205-Blueprint Milestone): Autonomous Lanthanum (La) & Cerium (Ce) Bastnasite (LnFCO3) Oxidative Roasting-Acid Leaching & Selective Ce4+ Extraction, Sub-2nm Semiconductor STI / 3D-NAND Chemical-Mechanical Planarization (CMP) Colloidal Ceria (CeO2 30-60 nm Surface Ce3+/Ce4+ Oxygen-Vacancy Ratio & >0.5 um Large-Particle Tail Elimination for Zero Angstrom-Scratch Oxide/Nitride Selectivity >50:1), Single-Crystal Lanthanum Hexaboride (LaB6 (100) Work Function 2.66 eV) Optical Floating-Zone Electron-Beam Emitter & LaNi5 Solid-State Hydrogen Storage Alloy PINN-MPC, Online 10 kHz UV-Vis/Raman (Ce3+/Ce4+), Single-Particle Optical Sizing (SPOS/DLS) & ICP-MS Metrology & NFPA 652 / OSHA 1910.1000 / SEMI S2 / IEC 61511 SIL-3 Bastnasite Fluoride-Roasting HF/SiF4 Off-Gas, Thorium (Th-232) Radioactive Slag & Pyrophoric La/Ce/LaNi5H6 Hydride Dust Explosion Interlock

@description('Deployment Azure region for the Lanthanum & Cerium Bastnasite Roasting, CeO2 CMP Slurry, LaB6 Emitter & LaNi5 Hydride AKSClaw cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Lanthanum & Cerium PINN-MPC + NFPA 652 / OSHA 1910.1000 / SEMI S2 / SIL-3 Edge')
param clusterName string = 'aksclaw-la-ce-cmp-lab6-sil3'

@description('GPU node VM SKU for Bastnasite Ce4+ Leaching, Colloidal CeO2 Ce3+/Ce4+ Defect Chemistry, LaB6 Floating-Zone & LaNi5 Hydride PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Number of GPU nodes in the Lanthanum & Cerium PINN-MPC pool (2 lines per node)')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 4

@description('Governance mode for Lanthanum & Cerium Bastnasite Roasting, CeO2 CMP Slurry & LaB6 Emitter PINN-MPC + SIL-3 Interlock')
@allowed([
  'pinn_mpc_bastnasite_ce4_roast_leach_ceo2_cmp_ce3_vacancy_spos_tail_lab6_floating_zone_lani5_hf_th_sil3_edge'
  'raw_cloud_open_loop_bastnasite_calcination_unfiltered_ceo2_milling_and_manual_lab6_zone_melt'
])
param laCeGovernanceMode string = 'pinn_mpc_bastnasite_ce4_roast_leach_ceo2_cmp_ce3_vacancy_spos_tail_lab6_floating_zone_lani5_hf_th_sil3_edge'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource laCePinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lacepinnpool'
  properties: {
    count: gpuNodeCount
    vmSize: gpuNodeVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    nodeLabels: {
      'agent.infra/domain': 'lanthanum-cerium-bastnasite-ceo2-cmp-slurry-lab6-emitter-lani5'
      'agent.infra/governance-mode': laCeGovernanceMode
      'agent.infra/safety-standard': 'nfpa652-osha19101000-semis2-iec61511-sil3'
      'agent.infra/edge-loop-khz': '10'
      'agent.infra/sil3-interlock-ms': '0.24'
    }
    nodeTaints: [
      'agent.infra/la-ce-cmp-lab6-sil3=true:NoSchedule'
    ]
    tags: {
      cycle: '204'
      chapter: '209'
      blueprint: '205'
      domain: 'lanthanum-cerium-ceo2-cmp-lab6-emitter-lani5-sil3'
    }
  }
}

output poolResourceId string = laCePinnMpcPool.id
output configuredGovernanceMode string = laCeGovernanceMode
output sil3InterlockTargetMs string = '0.24'
output edgeMetrologyLoopTargetMs string = '0.19'
