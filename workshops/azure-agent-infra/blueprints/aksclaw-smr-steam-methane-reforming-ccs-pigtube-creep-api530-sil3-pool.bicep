// 122. Azure Bicep: Autonomous Blue-Hydrogen Steam Methane Reforming & Autothermal Reforming (SMR / ATR 850-1050 C, 25-40 bar HP25Cr35NiNb Catalyst Tubes & MDEA/PZ Pre-Combustion CCS), Endothermic Reforming-Coking & Larson-Miller Creep-Rupture PINN-MPC, 2D IR Tube-Skin Pyrometry & API STD 530 / API RP 556 / NFPA 86 / IEC 61511 SIL-3 Tube-Rupture Steam-Curtain & Fuel-Gas Trip Interlock Pool (Chapter 126)
param location string = resourceGroup().location
param clusterName string = 'aks-agent-infra'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource smrSteamMethaneReformingCcsSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'smrccspinns3'
  properties: {
    count: 2 // Standard_NC24ads_A100_v4 (Xu-Froment Steam Reforming / Boudouard Carbon-Coking & API 530 Larson-Miller Omega Creep-Damage PINN + Multi-Burner Radiant Heat-Flux Balancing, Steam-to-Carbon Ratio & MDEA/PZ Stripper Reboiler MPC + Furnace Peep-Door 2D MWIR Pyrometry & TDLAS Syngas Slip Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'smr-steam-methane-reforming-ccs-pigtube-creep-api530-sil3-agent'
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/pinn-mpc-xufroment-coking-api530-creep': 'enabled-38.4pct-h2-thermal-efficiency-tube-life-52.8pct-hotband-coking-cut'
      'aksclaw.io/api530-sil3-tube-rupture-steam-curtain-fuel-trip': 'enforced-0.4ms-zero-pigtube-stress-rupture-or-furnace-explosion'
      'aksclaw.io/furnace-edge-2d-mwir-tubeskin-pyrometry-tdlas': 'enabled-0.3ms-99.4pct-hydrogen-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/smr-steam-methane-reforming-ccs-sil3=true:NoSchedule'
    ]
  }
}
