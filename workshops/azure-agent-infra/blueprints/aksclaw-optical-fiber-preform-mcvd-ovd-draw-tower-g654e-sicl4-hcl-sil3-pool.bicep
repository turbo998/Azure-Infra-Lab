// ============================================================================
// AKSClaw + E2B-on-Azure Blueprint #152 (Cycle #151 · 160-Test Milestone)
// Autonomous Ultra-Low-Loss Optical Fiber Preform (MCVD / OVD / VAD SiCl4 +
// GeCl4 + O2 -> SiO2-GeO2 Soot Deposition & Cl2 Dehydration Sintering) &
// High-Speed 2,400 m/min 2,150 °C Graphite Induction Drawing Tower Pool,
// Core-Cladding Refractive Index Profile (G.654.E / G.652.D < 0.155 dB/km),
// Neck-Down Meniscus Draw Tension & UV-Acrylate Coating Concentricity PINN-MPC,
// Online 50 kHz Laser Micrometer / OTDR Water-Peak & FTIR SiCl4-HCl-Cl2
// Metrology & OSHA 29 CFR 1910.119 / NFPA 86 / SEMI S2 / IEC 61511 SIL-3
// SiCl4 Hydrolysis HCl / Cl2 Scrubber, H2/O2 Burner Flashback & Graphite
// Furnace Argon-Curtain Interlock
// ============================================================================

@description('Azure region for the optical fiber preform MCVD/VAD & 2,400 m/min drawing tower pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the optical fiber preform & drawing tower control plane')
param clusterName string = 'aksclaw-optical-fiber-mcvd-draw-sil3'

@description('VM size for real-time refractive-index profile, Cl2 dehydration & neck-down meniscus PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Target G.654.E / G.652.D optical attenuation at 1,550 nm (dB/km)')
param targetAttenuation1550nmDbPerKm string = '0.154'

@description('Maximum permissible cladding diameter deviation on 125.0 um fiber (um)')
param maxCladdingDiameterDeviationUm string = '0.10'

@description('OSHA 1910.119 / NFPA 86 / SEMI S2 SIL-3 HCl/Cl2 scrubber & H2/O2 flashback trip latency budget (ms)')
param sil3ScrubberAndBurnerTripLatencyMs int = 1

resource aksFiberPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/fibersil3'
  properties: {
    count: 3
    vmSize: gpuNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 3
    maxCount: 12
    nodeLabels: {
      'agent.infra/domain': 'ultra-low-loss-optical-fiber-preform-mcvd-ovd-vad-and-2400mpm-draw-tower'
      'agent.infra/physics-horizon': 'thermophoretic-soot-deposition-cl2-oh-dehydration-and-neckdown-meniscus-pinn-mpc'
      'agent.infra/safety-interlock': 'osha-1910-119-nfpa86-semis2-sil3-sicl4-hcl-cl2-scrubber-and-h2-o2-flashback-gate'
      'agent.infra/edge-metrology': 'online-50khz-laser-micrometer-1383nm-oh-otdr-and-ftir-sicl4-hcl-cl2-telemetry'
      'agent.infra/target-attenuation-1550nm-db-km': targetAttenuation1550nmDbPerKm
      'agent.infra/max-diameter-dev-um': maxCladdingDiameterDeviationUm
    }
    nodeTaints: [
      'fiberPreformDrawSil3Only=true:NoSchedule'
    ]
  }
}

output poolResourceId string = aksFiberPool.id
output targetAttenuationDbPerKm string = targetAttenuation1550nmDbPerKm
output sil3InterlockLatencyBudgetMs int = sil3ScrubberAndBurnerTripLatencyMs
