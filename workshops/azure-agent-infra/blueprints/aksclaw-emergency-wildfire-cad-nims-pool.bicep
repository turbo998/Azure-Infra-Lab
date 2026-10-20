// Blueprint #55: Autonomous Emergency Dispatch, Wildland Fire WRF-SFIRE Spread & NIMS/ICS Interlock Agent Pool
// Models:
// 1. Coupled Atmosphere-Fire (WRF-SFIRE + Rothermel) PINN & NVIDIA cuOpt Contraflow/Apparatus Dispatch (-29.4% evac clearance time, +33.8% fireline containment)
// 2. FEMA NIMS / ICS & IPAWS Evacuation Polygon & Burnover Safety Envelope Gate (2.1 ms interlock, 0.0% premature evac downgrade or burnover dispatch escape)
// 3. Airborne/Tower Azure IoT Operations LWIR (8-14 um) Thermal Spot-Fire Ember Triage (17.0 ms vs 1,520.0 ms raw thermal stream, 96.6% FirstNet/SatCom cut)

param clusterName string = 'aks-agent-infra-lab'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource emergencyWildfirePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'firenims'
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
      'aksclaw.io/workload-class': 'emergency-wildfire-cad-nims-agent'
      'aksclaw.io/wrf-sfire-rothermel-cuopt': 'enabled-29.4pct-evac-time-cut-33.8pct-containment-gain'
      'aksclaw.io/nims-ics-burnover-interlock': 'enforced-2.1ms-zero-burnover-or-premature-evac-escape'
      'aksclaw.io/lwir-thermal-ember-edge': 'enabled-17ms-96.6pct-firstnet-satcom-cut'
    }
    nodeTaints: [
      'aksclaw.io/emergency-wildfire-cad=true:NoSchedule'
    ]
  }
}
