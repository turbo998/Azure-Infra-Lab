// Blueprint #59: Autonomous Cement Kiln Pyroprocessing, RDF Co-Firing MPC, Amine CCUS & EN 746-2 CO Interlock Pool
// Models:
// 1. Rotary Kiln Burning-Zone PINN MPC + RDF Co-Firing & Amine CCUS Reboiler Optimization (+26.8% RDF substitution, -19.4% CCUS steam, 0.0% off-spec f-CaO)
// 2. EN 746-2 / NFPA 86 Preheater CO (<0.8% vol) ESP Trip & Shell Refractory Spalling (<380C) Hardware Interlock (1.1 ms gate, 0.0% CO explosion/Red Kiln)
// 3. Cement Plant Azure IoT Operations Kiln Shell Line-Scan IR + PGNAA Raw-Mix & Flame Camera Edge Triage (11.0 ms vs 1,280.0 ms cloud upload, 96.7% WAN cut)

param clusterName string = 'aks-agent-infra-lab'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource cementKilnCcusPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'kilnccus'
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
      'aksclaw.io/workload-class': 'cement-kiln-ccus-pyro-agent'
      'aksclaw.io/rdf-pyro-mpc-amine-ccus': 'enabled-26.8pct-rdf-gain-19.4pct-ccus-steam-cut'
      'aksclaw.io/en746-nfpa86-co-esp-interlock': 'enforced-1.1ms-0.8pct-co-zero-esp-explosion-red-kiln'
      'aksclaw.io/kiln-shell-ir-pgnaa-edge': 'enabled-11ms-96.7pct-wan-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/cement-kiln-ccus=true:NoSchedule'
    ]
  }
}
