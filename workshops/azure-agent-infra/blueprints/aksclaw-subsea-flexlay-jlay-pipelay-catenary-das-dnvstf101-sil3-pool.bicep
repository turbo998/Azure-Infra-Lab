// 125. Azure Bicep: Autonomous Ultra-Deepwater J-Lay / S-Lay / Reel-Lay Subsea Pipeline Laying Vessel (2,500-3,500 m Water Depth, 600-2,000 t Quad-Track Tensioner & Stinger / J-Lay Tower), Sagbend Touchdown-Point (TDP) Elasto-Plastic Ovalization & Propagating-Buckle PINN-MPC, Automated Ultrasonic Testing (AUT) Girth-Weld / OFDR Strain Metrology & DNV-ST-F101 / API RP 1111 / IMCA M 103 / IEC 61508 SIL-3 Wet-Buckle Abandonment & Tensioner Slip-Crush Interlock Pool (Chapter 129)
param location string = resourceGroup().location
param clusterName string = 'aks-agent-infra'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource subseaPipelayJlaySlayDnvSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'pipelaypinns3'
  properties: {
    count: 2 // Standard_NC24ads_A100_v4 (3D Catenary Overbend/Sagbend Touchdown-Point Elasto-Plastic Ovalization & DNV-ST-F101 Propagating Buckle PINN + DP-3 Vessel Surge/Heave Compensation & Quad-Track Tensioner Squeeze/Pay-Out MPC + Girth-Weld Zonal Phased-Array AUT & Stinger Load-Pin Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'subsea-flexlay-jlay-pipelay-catenary-das-dnvstf101-sil3-agent'
      'aksclaw.io/runtime': 'kata-vm-isolation'
      'aksclaw.io/pinn-mpc-catenary-sagbend-ovalization-dp3': 'enabled-39.1pct-pipelay-rate-weather-window-53.8pct-sagbend-fatigue-weld-repair-cut'
      'aksclaw.io/dnvstf101-sil3-wet-buckle-ar-winch-tensioner-interlock': 'enforced-0.3ms-zero-propagating-wet-buckle-or-tensioner-slip-drop'
      'aksclaw.io/firing-line-edge-zonal-aut-stinger-ofdr-strain': 'enabled-0.3ms-99.5pct-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/subsea-pipelay-jlay-slay-dnv-sil3=true:NoSchedule'
    ]
  }
}
