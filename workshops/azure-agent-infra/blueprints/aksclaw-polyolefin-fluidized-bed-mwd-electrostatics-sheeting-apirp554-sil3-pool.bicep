// ============================================================================
// Blueprint #139: Autonomous Gas-Phase Fluidized-Bed Polyolefin (UNIPOL PE /
// Spheripol PP 18-35 bar, 75-112 C) & Loop-Slurry Polymerization Reactor,
// Ziegler-Natta / Metallocene Single-Site Catalyst Population-Balance Molecular
// Weight Distribution (MWD, PDI = Mw/Mn & Melt Flow Index MFI) & Short-Chain
// Branching (SCB), Expanded-Bed Electrostatic Tribocharging & Wall-Sheeting /
// Chunking Thermal Hot-Spot Suppression PINN-MPC, Online Multi-Frequency
// Acoustic Emission (AE) / Raman Comonomer Metrology & API RP 554 / NFPA 68 /
// IEC 61508 SIL-3 Exothermic Runaway Catalyst Killer (CO / H2O Poison Injection)
// & Emergency Depressurization Flare Interlock Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the polyolefin fluidized-bed polymerization AKSklaw pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the polyolefin fluidized-bed PINN-MPC sandboxes')
param aksClusterName string = 'aks-polyolefin-fb-sil3'

@description('Polyolefin grade family')
@allowed([
  'lldpe-butene-hexene-metallocene-film'
  'hdpe-bimodal-pipe-pe100-loop-gas-cascade'
  'pp-homopolymer-impact-copolymer-spheripol'
])
param polyolefinGradeFamily string = 'hdpe-bimodal-pipe-pe100-loop-gas-cascade'

@description('Fluidized-bed superficial gas velocity u0 (m/s)')
param superficialGasVelocityMps string = '0.68'

@description('Target polymer production rate (t/h)')
@minValue(25)
@maxValue(120)
param targetPolymerProductionTph int = 75

@description('Maximum electrostatic wall-potential sheet-initiation threshold |V_wall,max| (kV)')
param maxWallElectrostaticPotentialKv string = '2.5'

@description('Maximum reactor bed temperature margin below polymer softening/sticking point T_stick - T_bed (K)')
param minSofteningPointMarginK string = '6.5'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU PINN-MPC Pool for Moment Population-Balance MWD/PDI, Condensed-Mode
//    Isopentane/Isobutane Induced-Condensing-Agent (ICA) Dew-Point & Triboelectric Wall-Sheeting PINN-MPC
resource polyolefinPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'polypinnpool'
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
      'agent.infra/workload': 'polyolefin-fluidized-bed-mwd-electrostatics-sheeting-pinn-mpc'
      'agent.infra/polyolefin-grade-family': polyolefinGradeFamily
      'agent.infra/superficial-gas-velocity-mps': superficialGasVelocityMps
      'agent.infra/target-production-tph': string(targetPolymerProductionTph)
      'agent.infra/kata-vm-isolation': 'true'
    }
    nodeTaints: [
      'polyolefin.agent.infra/pinn-gpu=true:NoSchedule'
    ]
  }
}

// 2. Deterministic Edge Safety Pool for 200 kHz Acoustic Emission (AE) Particle
//    Impact Spectrum, Static Voltage Probe & API RP 554 / NFPA 68 / SIL-3 CO Killer Injection Interlock
resource polyolefinSafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'polysil3pool'
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
      'agent.infra/workload': 'apirp554-nfpa68-sil3-polyolefin-co-killer-flare-interlock'
      'agent.infra/max-wall-electrostatic-potential-kv': maxWallElectrostaticPotentialKv
      'agent.infra/min-softening-point-margin-k': minSofteningPointMarginK
      'agent.infra/safety-standard': 'API-RP-554-NFPA-68-IEC-61508-SIL3'
    }
    nodeTaints: [
      'polyolefin.agent.infra/sil3-safety=true:NoSchedule'
    ]
  }
}

output polyolefinPinnPoolId string = polyolefinPinnPool.id
output polyolefinSafetyPoolId string = polyolefinSafetyPool.id
output safetyInterlockSpec string = 'API-RP-554/NFPA-68/IEC-61508-SIL3|Vwall_max=${maxWallElectrostaticPotentialKv}kV|dT_stick_min=${minSofteningPointMarginK}K|CO_Killer_Valve<12ms'
