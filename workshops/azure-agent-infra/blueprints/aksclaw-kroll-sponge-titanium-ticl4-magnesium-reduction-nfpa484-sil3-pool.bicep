// =============================================================================
// Blueprint #135: Autonomous Aerospace-Grade Sponge Titanium Kroll Process
// (TiO2 + C + Cl2 -> TiCl4 Fluidized-Bed Carbochlorination 1,000 C, VOCl3
// Fractional Distillation & TiCl4 + 2Mg -> Ti + 2MgCl2 Sealed Retort Reduction /
// 1,020 C Vacuum Distillation PINN-MPC), Online Raman VOCl3 / QMS Metrology &
// NFPA 484 / ASME BPVC Sec VIII / IEC 61508 SIL-3 Retort Runaway Creep, Fe-Ti
// Eutectic Melt-Through & TiCl4/Cl2 Toxic Vapor Scrubber Interlock Pool
// =============================================================================
// Target Workload:
//   1. Fluidized-Bed Carbochlorination (1,000 C), VOCl3 Fractional Distillation &
//      12-Ton Batch Sealed Retort Mg-Reduction / Vacuum Distillation PINN-MPC
//      (Standard_NC24ads_A100_v4) — couples 3D fluidized-bed chlorinator bubble
//      hydrodynamics, VOCl3/SiCl4 distillation column equilibrium, and strongly
//      exothermic TiCl4 + 2Mg -> Ti + 2MgCl2 (DeltaH = -421 kJ/mol at 880-920 C)
//      reaction-front heat transfer with Ti-Fe eutectic (1,085 C) stainless-steel
//      retort-wall diffusion and 1,020 C / 0.1 Pa vacuum distillation Mg/MgCl2
//      sublimation kinetics.
//   2. NFPA 484 / ASME BPVC Sec VIII / IEC 61508 SIL-3 Retort Creep Collapse,
//      Fe-Ti Eutectic Wall Burn-Through & TiCl4/Cl2 Caustic Scrubber Hardware
//      Interlock (0.3 ms) — hardware backplane linking retort outer-wall infrared
//      scanner / thermocouple array, TiCl4 liquid feed double-block-and-bleed
//      valves, high-purity 99.999% Argon emergency pressure-equalization backfill
//      manifold, cooling-air blower dampers, and NaOH/Ca(OH)2 emergency caustic
//      venturi scrubber.
//   3. Retort-Edge Online Raman VOCl3 Impurity, Vacuum QMS Residual Gas & Outer-
//      Shell Infrared Creep Thermography Triage Sandbox (0.3 ms) — processes 532 nm
//      in-line Raman spectroscopy on purified TiCl4 (VOCl3 < 2 ppm), vacuum line
//      quadrupole mass spectrometry (O2/N2/H2O air-leak detection + Mg vapor end-
//      point), and 360-degree retort shell IR thermography at the furnace edge,
//      cutting WAN bandwidth by 99.5%.
// =============================================================================

@description('Azure region for the Kroll Sponge Titanium & TiCl4 Reduction Agent Pool')
param location string = resourceGroup().location

@description('Environment identifier')
@allowed([
  'prod-kroll-titanium-edge'
  'staging-retort-digital-twin'
  'audit-nfpa484-asme-sil3'
])
param environment string = 'prod-kroll-titanium-edge'

@description('AKS cluster name for Kroll Sponge Titanium & Retort Control Pool')
param clusterName string = 'aksclaw-kroll-titanium-sil3'

@description('Maximum TiCl4-Mg reduction retort reaction-zone temperature in Celsius before Ti-Fe eutectic (1,085 C) wall contamination and NFPA 484 / SIL-3 TiCl4 feed cut-off')
param maxRetortReactionZoneTempC int = 965

@description('Maximum allowable TiCl4/Cl2/HCl vapor concentration in ppm in the chlorination/reduction bay before emergency caustic venturi scrubber activation')
param maxBayChlorideVaporPpm int = 1

@description('Target NFPA 484 / ASME BPVC / SIL-3 Argon backfill and TiCl4 feed cut-off interlock latency in microseconds')
param sil3RetortArgonBackfillAndScrubberTargetUs int = 300

resource krollTitaniumCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// -----------------------------------------------------------------------------
// 1. PINN-MPC Carbochlorination, VOCl3 Distillation & Mg-Reduction Pool (A100)
// -----------------------------------------------------------------------------
resource krollPinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: krollTitaniumCluster
  name: 'krollmpc'
  properties: {
    count: 3
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 3
    maxCount: 6
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'kroll-chlorinator-vocl3-distillation-mg-retort-pinn-mpc'
      'agent.infra/chlorination-process': 'fluidized-bed-rutile-slag-1000C-ticl4-synthesis'
      'agent.infra/purification-stage': 'fractional-distillation-vocl3-sicl4-removal-sub-2ppm'
      'agent.infra/reduction-distillation': '12ton-batch-mg-reduction-900C-vacuum-distillation-1020C-0p1Pa'
    }
    nodeTaints: [
      'agent.infra/kroll-titanium-pinn-mpc=true:NoSchedule'
    ]
  }
}

// -----------------------------------------------------------------------------
// 2. NFPA 484 / ASME BPVC / SIL-3 Retort Creep & TiCl4 Scrubber Gate Pool
// -----------------------------------------------------------------------------
resource nfpa484AsmeSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: krollTitaniumCluster
  name: 'krollsil3'
  properties: {
    count: 3
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: false
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    proximityPlacementGroupID: ''
    nodeLabels: {
      'agent.infra/safety-standard': 'nfpa-484-asme-bpvc-sec-viii-iec-61508-sil3'
      'agent.infra/max-retort-temp-c': string(maxRetortReactionZoneTempC)
      'agent.infra/max-bay-chloride-vapor-ppm': string(maxBayChlorideVaporPpm)
      'agent.infra/interlock-target-us': string(sil3RetortArgonBackfillAndScrubberTargetUs)
      'agent.infra/interlock-action': 'ticl4-dbb-cutoff-argon-pressure-balance-backfill-caustic-venturi-scrubber'
    }
    nodeTaints: [
      'agent.infra/nfpa484-asme-sil3=true:NoSchedule'
    ]
  }
}

// -----------------------------------------------------------------------------
// 3. Furnace-Edge Online Raman VOCl3, Vacuum QMS & IR Creep Thermography Pool
// -----------------------------------------------------------------------------
resource retortMetroEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: krollTitaniumCluster
  name: 'krolledg'
  properties: {
    count: 3
    vmSize: 'Standard_D16s_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 3
    maxCount: 9
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/edge-metrology': 'inline-532nm-raman-vocl3-vacuum-qms-airleak-ir-creep-thermography'
      'agent.infra/target-sponge-grade': 'aerospace-rotor-grade-1-eli-bhn-sub-100-fe-sub-0p03wtpct'
      'agent.infra/wan-compression-target-pct': '99.5'
      'agent.infra/environment': environment
    }
    nodeTaints: [
      'agent.infra/kroll-metro-edge=true:NoSchedule'
    ]
  }
}

output krollPinnMpcPoolId string = krollPinnMpcPool.id
output nfpa484AsmeSil3PoolId string = nfpa484AsmeSil3Pool.id
output retortMetroEdgePoolId string = retortMetroEdgePool.id
output configuredMaxRetortReactionZoneTempC int = maxRetortReactionZoneTempC
output configuredSil3RetortArgonBackfillAndScrubberTargetUs int = sil3RetortArgonBackfillAndScrubberTargetUs
