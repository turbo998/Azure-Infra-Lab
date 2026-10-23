@description('Azure region for the AKSClaw Supercritical CO2 Allam-Fetvedt 300 bar Oxy-Fuel Turbine-Compander, Span-Wagner Near-Critical Compressor Anti-Surge & PCHE Recuperator Agent Pool')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the Allam-Fetvedt sCO2 Oxy-Fuel Power Cycle PINN-MPC & API 617/NFPA 85/SIL-3 pool')
param aksClusterName string

@description('VM SKU for GPU-accelerated Span-Wagner real-gas EoS density-gradient PINN-MPC, PCHE recuperator thermal-stress modeling, and 50 kHz blade-tip clearance / TDLAS oxy-combustor telemetry')
param vmSize string = 'Standard_NV36ads_A10_v5'

@description('Minimum node count for high-availability Allam-Fetvedt sCO2 oxy-fuel power train twins')
param minCount int = 2

@description('Maximum node count for multi-unit utility-scale sCO2 zero-emission power blocks')
param maxCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource sco2AllamPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'sco2allam3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'agent.infra/domain': 'allam-fetvedt-sco2-oxyfuel-turbine-compander'
      'agent.infra/physics-kernel': 'pinn-mpc-span-wagner-near-critical-compressor-pche'
      'agent.infra/metrology-loop': '50khz-blade-tip-capacitance-and-tdlas-oxycombustor'
      'agent.infra/safety-interlock': 'api617-asme-ptc10-nfpa85-iec61511-sil3'
    }
    nodeTaints: [
      'agent.infra/sco2-allam-oxyfuel-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = sco2AllamPool.id
output isolationRuntime string = sco2AllamPool.properties.workloadRuntime
