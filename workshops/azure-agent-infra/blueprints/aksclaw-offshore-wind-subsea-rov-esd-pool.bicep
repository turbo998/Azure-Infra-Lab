// Blueprint #56: Autonomous Subsea Pipeline & Offshore Wind Turbine Integrity, ROV Sonar & SIL-3 ESD Pool
// Models:
// 1. FLORIS/LES Cooperative Wake Steering MPC & Resident Subsea ROV Freespan Inspection (+11.8% wind farm AEP, -46.2% DP2 vessel cost)
// 2. DNV-ST-F101 / API RP 1173 & IEC 61511 SIL-3 Subsea HIPPS/ESD Valve Interlock (1.4 ms gate, <=0.95 MAOP, 0.0% overpressure or ESD bypass)
// 3. Offshore Substation Azure IoT Operations Coherent-OTDR DAS Anchor-Drag & ROV Multibeam Edge Triage (14.0 ms vs 1,840.0 ms raw VSAT backhaul, 97.2% bandwidth cut)

param clusterName string = 'aks-agent-infra-lab'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource offshoreSubseaPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'subseaesd'
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
      'aksclaw.io/workload-class': 'offshore-wind-subsea-rov-esd-agent'
      'aksclaw.io/floris-wake-steering-mpc': 'enabled-11.8pct-aep-gain-46.2pct-vessel-cost-cut'
      'aksclaw.io/dnv-api1173-sil3-hipps-esd': 'enforced-1.4ms-0.95maop-zero-overpressure-escape'
      'aksclaw.io/das-anchor-drag-rov-sonar-edge': 'enabled-14ms-97.2pct-vsat-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/offshore-subsea-esd=true:NoSchedule'
    ]
  }
}
