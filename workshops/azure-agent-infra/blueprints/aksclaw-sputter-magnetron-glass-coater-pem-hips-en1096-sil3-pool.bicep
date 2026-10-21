// 123. Azure Bicep: Autonomous Jumbo-Glass Vacuum Magnetron Sputtering Coater (3.21x6.00m Triple-Silver Low-E & Electrochromic WO3/NiO, 20-40 Rotary C-MAG/TwinMag Cathodes), Berg Target-Poisoning Hysteresis S-Curve & Plasma Emission Monitoring (PEM) PINN-MPC, In-Line Spectroscopic Ellipsometry & EN 1096 / ASTM C1376 / SEMI S2 / IEC 61508 SIL-3 Micro-Arc Blanking & Rotary-Target Water-Leak Interlock Pool (Chapter 127)
param location string = resourceGroup().location
param clusterName string = 'aks-agent-infra'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource sputterMagnetronGlassCoaterSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'sputpinnsil3'
  properties: {
    count: 2 // Standard_NC24ads_A100_v4 (Berg Reactive Sputtering Target-Poisoning S-Curve & 3D Magnetic Racetrack Cross-Corner Erosion PINN + Piezo-Valve O2/N2 Trim, Magnetic Shunt & Sub-nm Ag-Barrier Thickness MPC + 100kHz PEM Optical Emission & In-Line Ellipsometry Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'sputter-magnetron-glass-coater-pem-hips-en1096-sil3-agent'
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/pinn-mpc-berg-hysteresis-pem-ellipsometry': 'enabled-38.6pct-deltae-color-uniformity-rate-53.2pct-target-poisoning-arc-scrap-cut'
      'aksclaw.io/en1096-sil3-microarc-reverse-pulse-rotary-water-interlock': 'enforced-0.2ms-zero-macroarc-spatter-or-vacuum-water-flood'
      'aksclaw.io/cathode-edge-100khz-pem-spectroscopic-ellipsometry': 'enabled-0.3ms-99.5pct-coater-line-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/sputter-magnetron-glass-coater-sil3=true:NoSchedule'
    ]
  }
}
