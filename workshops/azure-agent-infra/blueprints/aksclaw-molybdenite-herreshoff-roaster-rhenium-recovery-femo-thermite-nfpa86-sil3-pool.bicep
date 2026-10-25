// Blueprint #183: Autonomous Molybdenite (MoS2) Multiple-Hearth Herreshoff Roasting (550-650 C),
// Byproduct Rhenium (Re2O7 -> NH4ReO4) Scrubbing, Two-Stage H2 Reduction & Aluminothermic FeMo Smelting
// PINN-MPC & NFPA 86 / NFPA 652 / OSHA 1910.119 / IEC 61511 SIL-3 Interlock Pool (Cycle #182)
param clusterName string = 'aksclaw-molybdenite-herreshoff-femo-sil3'
param location string = resourceGroup().location
param vmSize string = 'Standard_NC40ads_H100_v5'
param nodeCount int = 2

resource aksMolybdeniteHerreshoffPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/molybdenitepool'
  properties: {
    count: nodeCount
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableUltraSSD: true
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
    nodeLabels: {
      'agent.infra/workload': 'molybdenite-herreshoff-roaster-rhenium-femo-thermite-pinn-mpc'
      'agent.infra/safety-loop': 'nfpa86-nfpa652-osha1910119-iec61511-sil3-clinkering-h2-thermite-interlock'
      'agent.infra/metrology': '10khz-rabble-torque-tdlas-so2-o2-libs-mo-re-cu-s-telemetry'
    }
    nodeTaints: [
      'molybdenite-herreshoff-sil3=true:NoSchedule'
    ]
  }
}
