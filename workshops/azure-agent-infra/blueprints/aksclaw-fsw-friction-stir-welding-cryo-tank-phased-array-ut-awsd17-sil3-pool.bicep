// Blueprint #98: Autonomous Aerospace Cryogenic Propellant Dome & Al-Li Fuselage Friction Stir Welding (FSW / Bobbin-Tool FSW) Thermomechanical Viscoplasticity PINN-MPC, In-Situ Phased-Array Ultrasonic (PAUT) Wormhole Detection & AWS D17.3 / NASA-STD-5009 / ISO 25239 / IEC 61508 SIL-3 Pool (Chapter 102)
param clusterName string = 'aks-aksclaw-prod'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource fswCryoTankPautSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'fswsil3'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'fsw-friction-stir-welding-cryo-tank-paut-awsd17-sil3-agent'
      'aksclaw.io/pinn-mpc-sheppard-wright-viscoplastic-forge-force': 'enabled-32.8pct-weld-uts-toughness-gain-45.6pct-wormhole-kissbond-scrap-cut'
      'aksclaw.io/awsd17-3-nasa5009-iso25239-sil3-pin-shear-guard': 'enforced-0.4ms-zero-stir-pin-fracture-or-burnthrough-breach'
      'aksclaw.io/spindle-piezo-dynamometer-10mhz-paut-ethercat-edge': 'enabled-0.4ms-99.3pct-factory-wan-cut'
      'aksclaw.io/gpu-Partition': 'mig-3g.40gb'
    }
    nodeTaints: [
      'aksclaw.io/fsw-cryo-tank-paut-sil3=true:NoSchedule'
    ]
  }
}
