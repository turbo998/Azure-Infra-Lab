// ============================================================================
// Blueprint #113: AKSClaw Autonomous Hollow-Core Anti-Resonant (HC-ARF / NANF)
// & Ultra-Low-Loss Optical Fiber Draw Tower (2,000-2,200 C Graphite Furnace),
// Neck-Down Meniscus & Capillary Differential-Pressure PINN-MPC, In-Line 10kHz
// Laser Concentricity Metrology & ITU-T G.652/G.654 / Telcordia GR-20 /
// NFPA 86 / IEC 61508 SIL-3 Bare-Fiber Break Catcher & Argon Furnace Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the Optical Fiber & Hollow-Core NANF Draw Tower pool')
param location string = resourceGroup().location

@description('Environment tier for hollow-core & ultra-low-loss optical fiber draw tower')
@allowed([
  'prod-fiber-draw-tower-sil3'
  'staging-nanf-capillary-hil'
])
param environment string = 'prod-fiber-draw-tower-sil3'

@description('Existing AKS cluster name hosting the AKSClaw fiber draw tower fleet')
param aksClusterName string = 'aks-aksclaw-fiber-draw-tower'

@description('Target outer cladding diameter in micrometers (typically 125 um +/- 0.1 um)')
param targetCladdingDiameterUm int = 125

@description('Maximum allowable draw tension in grams-force before brittle fracture (30 - 250 gf)')
param maxDrawTensionGf int = 180

@description('Maximum UV-acrylate curing chamber oxygen concentration in ppm')
param maxUvCureOxygenPpm int = 150

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Real-Time PINN-MPC Node Pool for Preform Neck-Down Viscoelastic Flow & NANF Capillary Pressure Control
resource fiberDrawPinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'fibpinn'
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
      'aksclaw.io/workload-class': 'hollowcore-optical-fiber-draw-tower-pinn-mpc'
      'aksclaw.io/isolation': 'kata-vm-isolated'
      'aksclaw.io/telecom-standard': 'itu-g652-g654-telcordia-gr20-nfpa86-iec-61508-sil3'
      'aksclaw.io/in-line-metrology': '10khz-laser-forward-scatter-concentricity-botda-edge'
    }
    nodeTaints: [
      'aksclaw.io/fiber-draw-tower-sandbox=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '25%'
    }
  }
}

// 2. Deterministic Safety & Bare-Silica Whip Catcher / Graphite Furnace Inerting Guardrail Pool
resource fiberDrawSil3SafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'fibsil3'
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
      'aksclaw.io/workload-class': 'fiber-draw-break-catcher-uv-monomer-sil3-interlock'
      'aksclaw.io/safety-standard': 'itu-g652-g654-telcordia-gr20-nfpa86-iec-61508-sil3'
      'aksclaw.io/target-cladding-um': string(targetCladdingDiameterUm)
      'aksclaw.io/max-draw-tension-gf': string(maxDrawTensionGf)
      'aksclaw.io/max-uv-cure-o2-ppm': string(maxUvCureOxygenPpm)
    }
    nodeTaints: [
      'aksclaw.io/fiber-draw-sil3-interlock=true:NoSchedule'
    ]
  }
}

output pinnPoolResourceId string = fiberDrawPinnMpcPool.id
output sil3SafetyPoolResourceId string = fiberDrawSil3SafetyPool.id
output safetyEnvelopeSummary object = {
  environment: environment
  targetCladdingDiameterUm: targetCladdingDiameterUm
  maxDrawTensionGf: maxDrawTensionGf
  maxUvCureOxygenPpm: maxUvCureOxygenPpm
  standards: [
    'ITU-T G.652 / G.654 & Telcordia GR-20 Optical Fiber Geometry & Proof-Test Standard'
    'NFPA 86 Class A Graphite Induction Furnace & UV-Acrylate Monomer Inerting'
    'IEC 61508 SIL-3 High-Speed Bare-Fiber Breakage Whip-Catcher, Capstan Emergency Decel & Argon Purge Interlock'
  ]
}
