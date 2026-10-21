// ============================================================================
// Blueprint #112: AKSClaw Autonomous Medical Cyclotron (18-70 MeV) &
// Radiopharmaceutical (18F-FDG / 68Ga / 177Lu / 225Ac) Hot-Cell Synthesis,
// Target Cavitation & Beam-Optics PINN-MPC, Prompt-Gamma Tomography &
// IAEA SSG-30 / USP <823> / 21 CFR Part 212 / IEC 61508 SIL-3 Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the Medical Cyclotron & Radiopharma Hot-Cell pool')
param location string = resourceGroup().location

@description('Environment tier for radiopharmaceutical cyclotron & hot-cell synthesis')
@allowed([
  'prod-cyclotron-hotcell-sil3'
  'staging-radiopharma-dosimetry-hil'
])
param environment string = 'prod-cyclotron-hotcell-sil3'

@description('Existing AKS cluster name hosting the AKSClaw radiopharma agent fleet')
param aksClusterName string = 'aks-aksclaw-cyclotron-hotcell'

@description('Maximum proton beam current on 18O-water target in microamperes (100 - 300 uA)')
param maxBeamCurrentUa int = 180

@description('Minimum hot-cell negative pressure differential in Pascals (-150 to -50 Pa)')
param minHotCellNegativePressurePa int = -85

@description('Maximum stack airborne 18F/11C radioactivity release threshold in Bq/m3')
param maxStackActivityBqM3 int = 500

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Real-Time PINN-MPC Node Pool for Cyclotron Space-Charge Beam Optics, 18O-Target Nucleate Boiling & Microfluidic Cassette Synthesis
resource cyclotronPinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'cycpinn'
  properties: {
    count: 4
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableUltraSSD: true
    enableNodePublicIP: false
    maxPods: 30
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'medical-cyclotron-radiopharma-hotcell-pinn-mpc'
      'aksclaw.io/isolation': 'kata-vm-isolated'
      'aksclaw.io/radiopharma-standard': 'iaea-ssg30-usp823-21cfr212-iec-61508-sil3'
      'aksclaw.io/prompt-gamma-hplc': 'in-line-radio-hplc-tlc-prompt-gamma-edge'
    }
    nodeTaints: [
      'aksclaw.io/cyclotron-hotcell-sandbox=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '25%'
    }
  }
}

// 2. Deterministic Safety & Radiation Containment / Havar Foil Integrity Guardrail Pool
resource cyclotronSil3SafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'cycsil3'
  properties: {
    count: 3
    vmSize: 'Standard_FX36mds'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableUltraSSD: true
    enableNodePublicIP: false
    maxPods: 24
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'cyclotron-havar-foil-hotcell-containment-sil3-interlock'
      'aksclaw.io/safety-standard': 'iaea-ssg30-usp823-21cfr212-iec-61508-sil3'
      'aksclaw.io/max-beam-current-ua': string(maxBeamCurrentUa)
      'aksclaw.io/min-hotcell-neg-pressure-pa': string(minHotCellNegativePressurePa)
      'aksclaw.io/max-stack-activity-bqm3': string(maxStackActivityBqM3)
    }
    nodeTaints: [
      'aksclaw.io/cyclotron-sil3-interlock=true:NoSchedule'
    ]
  }
}

output pinnPoolResourceId string = cyclotronPinnMpcPool.id
output sil3SafetyPoolResourceId string = cyclotronSil3SafetyPool.id
output safetyEnvelopeSummary object = {
  environment: environment
  maxBeamCurrentUa: maxBeamCurrentUa
  minHotCellNegativePressurePa: minHotCellNegativePressurePa
  maxStackActivityBqM3: maxStackActivityBqM3
  standards: [
    'IAEA Specific Safety Guide SSG-30 Safety of Radioisotope Production Facilities'
    'USP <823> / FDA 21 CFR Part 212 Positron Emission Tomography Drugs cGMP'
    'IEC 61508 SIL-3 Ion-Source/RF Crowbar Beam Trip, Havar Target Foil Rupture & Hot-Cell Delay-Tank Containment Interlock'
  ]
}
