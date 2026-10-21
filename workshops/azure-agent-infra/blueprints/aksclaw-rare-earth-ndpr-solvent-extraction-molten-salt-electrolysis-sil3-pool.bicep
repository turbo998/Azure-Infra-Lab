// =============================================================================
// Blueprint #136: Autonomous Rare-Earth Neodymium-Praseodymium (NdPr) Bastnasite/
// Monazite Acid Roasting, 120-Stage P507 Counter-Current Mixer-Settler Solvent
// Extraction (SX) & 1,050 C Fluoride-Oxide Molten Salt Electrolysis (Nd2O3 +
// LiF-NdF3 -> Nd) PINN-MPC, Online EDXRF / FTIR CF4 Metrology & IAEA SSR-6 /
// NFPA 30 / IEC 61508 SIL-3 Kerosene Organic Flash-Fire, HF Dry-Scrubber &
// Thorium-232 NORM Tailings Interlock Pool
// =============================================================================
// Target Workload:
//   1. 120-Stage P507/Sulfonated-Kerosene Counter-Current Mixer-Settler Cascade &
//      30 kA / 1,050 C NdF3-LiF-Nd2O3 Molten Salt Electrolysis PINN-MPC
//      (Standard_NC24ads_A100_v4) — couples Kremser-McCabe-Thiele multi-component
//      lanthanide mass-transfer PDEs (La/Ce/Pr/Nd/Sm with separation factor
//      beta_Pr/Nd ~ 1.5, Ca/Mg saponification equilibrium, and third-phase crud
//      emulsification threshold) with 3D magnetohydrodynamic (MHD) molten-fluoride
//      electrolysis cell oxide dissolution, carbon-anode bubble overpotential, and
//      anode-effect (CF4/C2F6 generation) suppression MPC.
//   2. IAEA SSR-6 / NFPA 30 / IEC 61508 SIL-3 Solvent Extraction Kerosene Flash-
//      Fire Nitrogen Blanket, HF/CF4 Dry-Alumina/Lime Scrubber & Thorium-232 NORM
//      Leachate Containment Interlock (0.3 ms) — hardware backplane linking
//      mixer-settler electrostatic/vapor LEL sensors, high-rate N2 foam/blanket
//      flooding valves, electrolysis cell voltage-spike (> 8.5 V) rapid Nd2O3
//      micro-feeder & anode-lift actuators, HF off-gas hydrated-lime dry scrubber
//      boosters, and Th-232/Ra-226 gamma-monitored double-lined tailings isolation.
//   3. Cascade-Edge Online Multi-Channel EDXRF Lanthanide Concentration, Cell-
//      Voltage Wavelet Anode-Effect Precursor & FTIR HF/CF4 Triage Sandbox
//      (0.3 ms) — processes 24-point on-stream EDXRF aqueous/organic lanthanide
//      profiles, 10 kHz electrolysis cell voltage noise spectra, and stack FTIR
//      spectra locally at the refinery edge, cutting WAN bandwidth by 99.5%.
// =============================================================================

@description('Azure region for the Rare-Earth NdPr Solvent Extraction & Molten Salt Electrolysis Agent Pool')
param location string = resourceGroup().location

@description('Environment identifier')
@allowed([
  'prod-rare-earth-ndpr-edge'
  'staging-sx-electrolysis-twin'
  'audit-iaea-nfpa30-sil3'
])
param environment string = 'prod-rare-earth-ndpr-edge'

@description('AKS cluster name for Rare-Earth NdPr SX & Molten Salt Electrolysis Pool')
param clusterName string = 'aksclaw-rare-earth-ndpr-sil3'

@description('Maximum allowable molten-salt electrolysis cell voltage in millivolts before anode-effect CF4/C2F6 onset and SIL-3 rapid Nd2O3 pulse feeding')
param maxElectrolysisCellVoltageMv int = 6800

@description('Maximum allowable hydrogen fluoride (HF) off-gas concentration in ppm before emergency hydrated-lime dry scrubber boost and cell hood seal')
param maxExhaustHfConcentrationPpm int = 2

@description('Target IAEA SSR-6 / NFPA 30 / SIL-3 organic N2 blanket and HF scrubber interlock latency in microseconds')
param sil3RareEarthInterlockTargetUs int = 300

resource rareEarthCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// -----------------------------------------------------------------------------
// 1. PINN-MPC 120-Stage P507 SX Cascade & 1,050 C NdF3-LiF Electrolysis Pool
// -----------------------------------------------------------------------------
resource rareEarthPinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: rareEarthCluster
  name: 'ndprpinnmpc'
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
      'agent.infra/workload': 'rare-earth-ndpr-p507-sx-cascade-molten-salt-electrolysis-pinn-mpc'
      'agent.infra/sx-cascade': '120stage-p507-kerosene-ca-mg-saponification-4n5-ndpr'
      'agent.infra/molten-salt-cell': '30ka-1050C-lif-ndf3-nd2o3-zero-anode-effect-cf4'
      'agent.infra/norm-governance': 'thorium-232-radium-226-selective-iron-phosphate-coprecipitation'
    }
    nodeTaints: [
      'agent.infra/rare-earth-ndpr-pinn-mpc=true:NoSchedule'
    ]
  }
}

// -----------------------------------------------------------------------------
// 2. IAEA SSR-6 / NFPA 30 / SIL-3 Organic Fire, HF Scrubber & NORM Gate Pool
// -----------------------------------------------------------------------------
resource nfpa30IaeaSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: rareEarthCluster
  name: 'ndprsil3'
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
      'agent.infra/safety-standard': 'iaea-ssr6-nfpa-30-iec-61508-sil3'
      'agent.infra/max-cell-voltage-mv': string(maxElectrolysisCellVoltageMv)
      'agent.infra/max-exhaust-hf-ppm': string(maxExhaustHfConcentrationPpm)
      'agent.infra/interlock-target-us': string(sil3RareEarthInterlockTargetUs)
      'agent.infra/interlock-action': 'sx-n2-blanket-flood-nd2o3-pulse-feed-hf-lime-scrubber-norm-isolation'
    }
    nodeTaints: [
      'agent.infra/nfpa30-iaea-sil3=true:NoSchedule'
    ]
  }
}

// -----------------------------------------------------------------------------
// 3. Refinery-Edge Online Multi-Stream EDXRF, Cell Wavelet & FTIR HF/CF4 Pool
// -----------------------------------------------------------------------------
resource rareEarthMetroEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: rareEarthCluster
  name: 'ndpredge'
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
      'agent.infra/edge-metrology': 'onstream-24ch-edxrf-10khz-cell-voltage-wavelet-ftir-hf-cf4'
      'agent.infra/product-purity-target': '99p99pct-4n-ndpr-oxide-and-low-carbon-neodymium-metal'
      'agent.infra/wan-compression-target-pct': '99.5'
      'agent.infra/environment': environment
    }
    nodeTaints: [
      'agent.infra/rare-earth-metro-edge=true:NoSchedule'
    ]
  }
}

output rareEarthPinnMpcPoolId string = rareEarthPinnMpcPool.id
output nfpa30IaeaSil3PoolId string = nfpa30IaeaSil3Pool.id
output rareEarthMetroEdgePoolId string = rareEarthMetroEdgePool.id
output configuredMaxElectrolysisCellVoltageMv int = maxElectrolysisCellVoltageMv
output configuredSil3RareEarthInterlockTargetUs int = sil3RareEarthInterlockTargetUs
