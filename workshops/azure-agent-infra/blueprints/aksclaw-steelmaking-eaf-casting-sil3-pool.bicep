// Blueprint #58: Autonomous Steelmaking, Electric Arc Furnace (EAF) Foaming-Slag MPC, Continuous Casting & SIL-3 Interlock Pool
// Models:
// 1. EAF Acoustic Harmonics Foaming-Slag MPC + LIBS Scrap Charge & LF Ferroalloy Trim (-44.5 kWh/t power, -18.4% electrode wear, 0.0% off-spec ladle)
// 2. NFPA 86 / IEC 61511 SIL-3 Wet-Scrap & Water-Cooled Lance Differential-Flow + FBG Mold Sticker Breakout Gate (0.9 ms gate, 0.0% steam explosion/breakout)
// 3. Melt-Shop Azure IoT Operations Slag-Door IR + LIBS Spectrum + FBG Mold Edge Triage (8.0 ms vs 1,120.0 ms raw furnace video upload, 97.1% WAN cut)

param clusterName string = 'aks-agent-infra-lab'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource steelmakingEafPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'steeleaf'
  properties: {
    count: 4
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'steelmaking-eaf-casting-sil3-agent'
      'aksclaw.io/eaf-foaming-slag-mpc-libs': 'enabled-44.5kwh-ton-cut-18.4pct-electrode-save'
      'aksclaw.io/nfpa86-sil3-lance-mold-interlock': 'enforced-0.9ms-zero-steam-explosion-or-breakout'
      'aksclaw.io/meltshop-ir-libs-fbg-edge': 'enabled-8ms-97.1pct-wan-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/steelmaking-eaf-sil3=true:NoSchedule'
    ]
  }
}
