// ============================================================================
// Blueprint #27: Carbon-Aware GreenOps Agent Fleet Scheduler & Kepler RAPL Pool
// Target: AKS Low-Carbon Batch Pool (Standard_D96as_v7) + KEDA Carbon-Intensity Scaler
// Purpose:
//   1. Provision AKS Turin D96as_v7 batch/async agent pool with amd-pstate-epp
//      power-efficiency labels and Kepler eBPF RAPL hardware Joule telemetry.
//   2. Configure Azure Monitor Workspace Prometheus rule group for CSRD Scope-2/3
//      per-tenant carbon accounting (gCO2eq per entra_agent_id & sponsor_oid).
// ============================================================================

@description('Primary low-carbon Azure region (e.g., swedencentral ~12 gCO2eq/kWh)')
param location string = 'swedencentral'

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure Monitor Workspace name for Kepler RAPL Joule & gCO2eq metrics')
param monitorWorkspaceName string = 'amw-aksclaw-greenops-csrd'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Azure Monitor Workspace for Kepler eBPF RAPL & WattTime MOER Telemetry
resource greenopsMonitorWorkspace 'Microsoft.Monitor/accounts@2023-04-03' = {
  name: monitorWorkspaceName
  location: location
}

// 2. AKS Carbon-Aware Async & Warm-Standby Nodepool (Standard_D96as_v7 Turin)
resource greenopsTurinPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'greenturin'
  properties: {
    count: 26
    minCount: 6
    maxCount: 120
    enableAutoScaling: true
    vmSize: 'Standard_D96as_v7'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    enableAcceleratedNetworking: true
    nodeLabels: {
      'aksclaw.io/greenops-carbon-aware': 'enabled'
      'aksclaw.io/cpu-governor': 'amd-pstate-epp-balance-power'
      'aksclaw.io/kepler-rapl-telemetry': 'enabled'
      'aksclaw.io/csrd-scope2-accounting': 'enforced'
    }
  }
}

output greenopsMonitorWorkspaceId string = greenopsMonitorWorkspace.id
output greenopsTurinPoolId string = greenopsTurinPool.id
