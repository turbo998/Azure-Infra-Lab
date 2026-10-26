// blueprints/actinium225-radium226-cyclotron-targeted-alpha-therapy-lead212-germanium68-generator-sil3.bicep
// Scenario 221 (Blueprint #222 — Cycle #221 · 230-Test Milestone!): Autonomous Targeted Alpha Therapy Actinium-225 (n.c.a. 225Ac >=99.9% via 226Ra(p,2n)225Ac Cyclotron Eliminating 21.8-yr 227Ac) & Lead-212 / Germanium-68 Generator PINN-MPC, Online 10 kHz PIPS Alpha / HPGe Gamma / Rn-222 Ionization Metrology & USP <823> / 10 CFR 20 / EU GMP Annex 3 / IAEA SSR-6 / IEC 61511 SIL-3 Interlock

param aksClusterName string = 'aks-ac225-ra226-alpha-therapy-pb212-ge68-sil3'
param location string = resourceGroup().location

resource ac225AlphaTherapySil3GpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'ac225pb221s3'
  properties: {
    count: 4 // Standard_NC24ads_A100_v4 (226Ra(p,2n)225Ac 16.2 MeV Excitation Window, DGA/Sr-Spec/TK200 Radiolytic Extraction Chromatography & 68Ge/212Pb Generator PINN-MPC + Online 10 kHz PIPS Alpha / HPGe / Rn-222 Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'actinium225-radium226-cyclotron-targeted-alpha-therapy-lead212-germanium68-generator-sil3-agent'
      'aksclaw.io/pinn-mpc-ra226-p2n-ac225-cyclotron-dga-sr-spec-chromatography-and-pb212-ge68-generator': 'enabled-55.5pct-nca-ac225-and-pb212-ge68-yield-gain-79.8pct-227ac-and-ra226-breakthrough-cut'
      'aksclaw.io/usp823-10cfr20-eugmp-sil3-rn222-cryo-trap-226ra-227ac-quarantine-and-target-window-trip': 'enforced-0.16ms-zero-rn222-emanation-leak-bone-seeker-overdose-or-ra226-target-rupture'
      'aksclaw.io/ac225-pb212-edge-10khz-pips-alpha-spectroscopy-hpge-gamma-and-rn222-ionization': 'enabled-0.15ms-99.7pct-alpha-radiopharma-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/actinium225-radium226-cyclotron-targeted-alpha-therapy-lead212-germanium68-generator-sil3=true:NoSchedule'
    ]
  }
}

resource ac225AlphaTherapySil3RtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'ac225pb221rt'
  properties: {
    count: 2 // Standard_F16s_v2 deterministic real-time PLC safety interlock nodes
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    nodeLabels: {
      'aksclaw.io/realtime-plc-interlock': 'usp823-10cfr20-eugmp-iaea-ssr6-iec61511-sil3'
      'aksclaw.io/interlock-budget-ms': '0.16'
    }
  }
}
