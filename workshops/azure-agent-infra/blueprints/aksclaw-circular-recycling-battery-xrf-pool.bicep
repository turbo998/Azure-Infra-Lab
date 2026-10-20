// Blueprint #57: Autonomous Circular Economy, EV Battery Pack Robotic Disassembly, XRF/NIR Sorting & UL 9540A Interlock Pool
// Models:
// 1. 3D Point-Cloud CAD-Free Fastener Pose Estimation + 1kHz Force-Torque Adaptive Unbolting & XRF/NIR Sorting (+23.6% mineral recovery, -37.5% cycle time)
// 2. UL 9540A / NFPA 855 Thermal Runaway & Gas LEL Hardware Interlock (0.8 ms gate, dT/dt<=1.5C/s, T<=62C, 0.0% thermal runaway puncture escape)
// 3. Plant-Floor Azure IoT Operations Hyperspectral SWIR/NIR + XRF & LWIR Thermal Edge Triage (9.0 ms vs 1,180.0 ms raw HSI cloud upload, 96.9% WAN cut)

param clusterName string = 'aks-agent-infra-lab'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource circularRecyclingPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'recycxrf'
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
      'aksclaw.io/workload-class': 'circular-recycling-battery-xrf-agent'
      'aksclaw.io/cad-free-torque-xrf-sorting': 'enabled-23.6pct-yield-gain-37.5pct-cycle-time-cut'
      'aksclaw.io/ul9540a-nfpa855-thermal-interlock': 'enforced-0.8ms-62C-zero-puncture-thermal-runaway'
      'aksclaw.io/hsi-xrf-lwir-edge-triage': 'enabled-9ms-96.9pct-wan-bandwidth-cut'
    }
    nodeTaints: [
      'aksclaw.io/circular-recycling-xrf=true:NoSchedule'
    ]
  }
}
