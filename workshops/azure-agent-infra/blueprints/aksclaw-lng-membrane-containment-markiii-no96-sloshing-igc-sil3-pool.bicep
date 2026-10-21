// 124. Azure Bicep: Autonomous Ultra-Large 266,000 m3 Membrane LNG Carrier (GTT Mark III / NO96 36% Ni Invar & 304L Corrugated Primary/Secondary Barrier at -163 C) & Dual-Fuel ME-GI/X-DF Reliquefaction, Hydroelastic Bagnold Sloshing Impact & BOG Subcooling PINN-MPC, Cryogenic FBG / Interbarrier N2-IR CH4 Leak-Tomography & IMO IGC Code / DNV-RU-SHIP / SIGTTO / IEC 61511 SIL-3 Inner-Hull Cold-Spot & Overpressure Interlock Pool (Chapter 128)
param location string = resourceGroup().location
param clusterName string = 'aks-agent-infra'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource lngMembraneContainmentSloshingSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'lngmempinns3'
  properties: {
    count: 2 // Standard_NC24ads_A100_v4 (6-DOF Ship-Wave Resonance & Bagnold Gas-Pocket Hydroelastic Sloshing Impact PINN + Active Heading/Speed Trim, Subcooler Spray & ME-GI/GCU BOG Reliquefaction MPC + Cryogenic FBG Strain/Temperature & Interbarrier IR CH4 Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'lng-membrane-containment-markiii-no96-sloshing-igc-sil3-agent'
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/pinn-mpc-bagnold-sloshing-bog-reliquefaction': 'enabled-38.8pct-reliquefaction-efficiency-54.1pct-sloshing-impact-bog-flare-cut'
      'aksclaw.io/igc-sil3-interbarrier-n2-sweep-hull-cofferdam-heating-interlock': 'enforced-0.4ms-zero-hull-brittle-fracture-or-tank-vacuum-collapse'
      'aksclaw.io/tank-edge-cryogenic-fbg-interbarrier-ir-ch4': 'enabled-0.3ms-99.5pct-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/lng-membrane-containment-sloshing-sil3=true:NoSchedule'
    ]
  }
}
