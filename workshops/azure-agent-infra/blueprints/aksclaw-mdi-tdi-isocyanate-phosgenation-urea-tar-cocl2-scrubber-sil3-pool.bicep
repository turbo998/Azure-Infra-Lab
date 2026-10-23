// ============================================================================
// Azure Agent Infra Playbook - Blueprint #145
// AKSClaw Autonomous Polyurethane Isocyanate (MDI / TDI) Cold/Hot Two-Stage
// Phosgenation (CO + Cl2 -> COCl2 & MDA/TDA + COCl2 -> MDI/TDI + 2HCl) Pool
// (Carbamoyl Chloride Intermediate Dissociation, Urea-Tar Oligomer Suppression &
//  Hydrolyzable Chlorine HC < 80 ppm PINN-MPC, Online TDLAS ppb Phosgene &
//  ATR-FTIR 2270 cm^-1 -N=C=O Metrology + OSHA 1910.119 / NFPA 704 / API RP 521 /
//  IEC 61511 SIL-3 Secondary Containment, NaOH/NH3 Decomposition Scrubber &
//  High-Pressure Ammonia-Steam Curtain Deluge Interlock)
// ============================================================================

@description('Azure region for the MDI/TDI phosgenation digital twin control plane')
param location string = resourceGroup().location

@description('Environment identifier for the MDI/TDI phosgenation autonomous pool')
@allowed([
  'prod-mdi-tdi-phosgene-sil3'
  'staging-isocyanate-twin'
])
param environment string = 'prod-mdi-tdi-phosgene-sil3'

@description('AKS cluster name hosting the MDI/TDI phosgenation PINN-MPC & TDLAS/ATR-FTIR pods')
param aksClusterName string = 'aks-mdi-tdi-phosgene-sil3-01'

@description('Target phosgene excess molar ratio, monomeric 4,4-MDI purity, and hydrolyzable chlorine ceiling (ppm)')
param phosgenationTargets object = {
  phosgeneToAmineMolarRatio: '2.65'
  monomeric44MdiPurityPct: '99.2'
  hydrolyzableChlorineMaxPpm: '65'
  containmentPhosgeneAlarmPpb: '50'
  osha1910119Sil3CausticAmmoniaScrubberInterlockMs: '0.2'
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Dedicated Real-Time Edge NodePool for MDI/TDI Phosgenation PINN-MPC + TDLAS/ATR-FTIR Fusion
resource mdiTdiPhosgeneSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mdiphossil3'
  properties: {
    count: 3
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableUltraSSD: true
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'mdi-tdi-isocyanate-cold-hot-phosgenation'
      'agent.infra/physics-engine': 'pinn-mpc-carbamoyl-dissociation-urea-tar-hc-suppression'
      'agent.infra/metrology': 'open-path-tdlas-ppb-cocl2-atr-ftir-nco-2270cm1'
      'agent.infra/safety-interlock': 'osha1910119-nfpa704-sil3-naoh-nh3-scrubber-steam-curtain'
      'agent.infra/environment': environment
    }
    nodeTaints: [
      'safety.industrial.azure.com/osha1910119-nfpa704-sil3-phosgene:NoSchedule'
    ]
    tags: {
      blueprint: 'aksclaw-mdi-tdi-isocyanate-phosgenation-urea-tar-cocl2-scrubber-sil3-pool'
      monomeric44MdiPurityPct: phosgenationTargets.monomeric44MdiPurityPct
      hydrolyzableChlorineMaxPpm: phosgenationTargets.hydrolyzableChlorineMaxPpm
      interlockLatencyMs: phosgenationTargets.osha1910119Sil3CausticAmmoniaScrubberInterlockMs
    }
  }
}

output poolResourceId string = mdiTdiPhosgeneSil3Pool.id
output safetyStandard string = 'OSHA 29 CFR 1910.119 / NFPA 704 / API RP 521 / IEC 61511 SIL-3 Phosgene Secondary Containment, NaOH/NH3 Scrubber & Steam Curtain Interlock'
