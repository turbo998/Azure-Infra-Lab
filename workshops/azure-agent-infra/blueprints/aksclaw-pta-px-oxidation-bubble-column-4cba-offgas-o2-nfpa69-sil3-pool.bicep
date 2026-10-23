// ============================================================================
// Blueprint #141: Autonomous Purified Terephthalic Acid (PTA 195-205 C /
// 14-16 bar Paraxylene PX Liquid-Phase Acetic-Acid Co-Mn-Br Catalytic Oxidation
// Bubble-Column Reactor) & Polyethylene Terephthalate (PET Melt Polycondensation),
// 4-Carboxybenzaldehyde (4-CBA) Impurity & Acetic-Acid Solvent Burning
// Suppression PINN-MPC, Online Off-Gas Tunable Diode Laser (TDLAS O2/CO/CO2) /
// Raman 4-CBA Metrology & NFPA 69 / API RP 554 / IEC 61508 SIL-3 Off-Gas Oxygen
// Breakthrough (>4.5 vol% O2 Acetic-Acid/Methyl-Acetate Deflagration),
// High-Pressure N2 Inerting & Air-Compressor Trip Interlock Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the PTA PX catalytic oxidation bubble-column AKSklaw pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the PTA PX oxidation & PET polycondensation PINN-MPC sandboxes')
param aksClusterName string = 'aks-pta-px-oxidation-sil3'

@description('PTA oxidation reactor & hydropurification process configuration')
@allowed([
  'invista-p8-t9-low-temp-bubble-column-2500ktpa'
  'bp-inhospa-compact-pta-oxidation-hydropurification'
  'mitsui-high-severity-co-mn-br-cta-crystallizer-cascade'
])
param ptaProcessConfiguration string = 'invista-p8-t9-low-temp-bubble-column-2500ktpa'

@description('Target crude terephthalic acid (CTA) 4-CBA impurity concentration (ppmw)')
param targetCta4CbaPpmw string = '2150'

@description('Single-train PTA nominal production capacity (kt/a)')
@minValue(1000)
@maxValue(3500)
param ptaCapacityKtpa int = 2500

@description('Maximum oxidation reactor overhead off-gas dry oxygen concentration O2,max (vol% below LEL/LOC)')
param maxOffGasOxygenVolPct string = '4.2'

@description('Maximum oxidation reactor operating temperature before runaway solvent decarboxylation T_ox,max (C)')
param maxOxidationReactorTempC string = '204.5'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU PINN-MPC Pool for Paraxylene -> p-Toluic Acid -> 4-CBA -> TA Free-Radical
//    Chain Oxidation Kinetics, Three-Phase Bubble-Column Gas-Liquid Mass Transfer
//    (k_L*a) & Acetic-Acid Solvent Oxidative Decarboxylation Burning PINN-MPC
resource ptaOxidationPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ptapinnpool'
  properties: {
    count: 4
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 12
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'pta-px-oxidation-bubble-column-4cba-solvent-burn-pinn-mpc'
      'agent.infra/pta-process-configuration': ptaProcessConfiguration
      'agent.infra/target-cta-4cba-ppmw': targetCta4CbaPpmw
      'agent.infra/pta-capacity-ktpa': string(ptaCapacityKtpa)
      'agent.infra/kata-vm-isolation': 'true'
    }
    nodeTaints: [
      'pta.agent.infra/pinn-gpu=true:NoSchedule'
    ]
  }
}

// 2. Deterministic Edge Safety Pool for 2oo3 Cross-Duct TDLAS Off-Gas O2/CO
//    Analyzers & NFPA 69 / API RP 554 / SIL-3 High-Pressure N2 Purge & Air Trip Interlock
resource ptaSafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ptasil3pool'
  properties: {
    count: 3
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    proximityPlacementGroupID: ''
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'nfpa69-apirp554-sil3-pta-offgas-o2-n2-purge-interlock'
      'agent.infra/max-offgas-oxygen-volpct': maxOffGasOxygenVolPct
      'agent.infra/max-oxidation-reactor-temp-c': maxOxidationReactorTempC
      'agent.infra/safety-standard': 'NFPA-69-API-RP-554-IEC-61508-SIL3'
    }
    nodeTaints: [
      'pta.agent.infra/sil3-safety=true:NoSchedule'
    ]
  }
}

output ptaOxidationPinnPoolId string = ptaOxidationPinnPool.id
output ptaSafetyPoolId string = ptaSafetyPool.id
output safetyInterlockSpec string = 'NFPA-69/API-RP-554/IEC-61508-SIL3|O2_offgas_max=${maxOffGasOxygenVolPct}vol%|T_ox_max=${maxOxidationReactorTempC}C|HP_N2_Purge<10ms'
