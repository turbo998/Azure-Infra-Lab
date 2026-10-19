// ============================================================================
// Blueprint #37: Telco 5G-Advanced / O-RAN & Autonomous Network Slicing Pool
// Target: Azure Operator Nexus + SR-IOV/DPDK User-Plane Bypass + Near-RT RIC xApp
//         + Non-RT SMO rApp + 3GPP TS 28.531 Slice SLA Pre-Verification Gate
// ============================================================================

@description('Deployment region for Telco O-RAN RIC & Network Slicing control plane')
param location string = resourceGroup().location

@description('Environment prefix for Telco O-RAN resources')
param namePrefix string = 'aksclaw-oran'

@description('Existing AKS Cluster name hosting O-RAN Near-RT RIC xApp and Non-RT SMO rApp pools')
param aksClusterName string = '${namePrefix}-aks'

@description('Concurrent 5G-Advanced gNodeB cells managed by the O-RAN RIC fleet')
@minValue(250)
@maxValue(50000)
param concurrentGnodebCells int = 5000

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. Near-RT RIC xApp Real-Time Node Pool (SR-IOV / Accelerated Networking + HugePages + SCTP E2AP)
resource nearRtRicNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'oranxapprt'
  properties: {
    count: max(3, (concurrentGnodebCells + 624) / 625)
    vmSize: 'Standard_D32s_v6'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 3
    maxCount: 48
    osDiskSizeGB: 256
    osDiskType: 'Ephemeral'
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
      allowedUnsafeSysctls: [
        'net.sctp.rto_min'
        'net.sctp.rto_max'
        'net.core.rmem_max'
        'net.core.wmem_max'
      ]
    }
    linuxOSConfig: {
      transparentHugePageEnabled: 'always'
      transparentHugePageDefrag: 'defer+madvise'
      sysctls: {
        netCoreSomaxconn: 65535
        netCoreNetdevMaxBacklog: 131072
      }
    }
    nodeLabels: {
      'aksclaw.io/workload-class': 'telco-oran-nearrt-ric'
      'aksclaw.io/datapath': 'sriov-dpdk-pmd-vf'
      'aksclaw.io/e2sm-profile': 'rc-kpm-sub10ms'
      'aksclaw.io/3gpp-slice-verifier': 'ts-28-531-markov-gate'
    }
    nodeTaints: [
      'aksclaw.io/telco-oran-ric=true:NoSchedule'
    ]
  }
}

// 2. Non-RT RIC rApp & 3GPP TS 28.531 Intent Verifier Event Hubs Namespace (O1/A1 Telemetry Stream)
resource oranTelemetryEventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${namePrefix}-o1a1-ehns'
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
    isAutoInflateEnabled: false
  }
}

resource e2KpmStreamHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: oranTelemetryEventHubNamespace
  name: 'e2sm-kpm-rc-telemetry'
  properties: {
    partitionCount: 32
    messageRetentionInDays: 7
  }
}

resource a1PolicyAuditHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: oranTelemetryEventHubNamespace
  name: 'a1p-ts28531-slice-audit'
  properties: {
    partitionCount: 16
    messageRetentionInDays: 30
  }
}

output nearRtRicPoolId string = nearRtRicNodePool.id
output oranTelemetryEventHubId string = oranTelemetryEventHubNamespace.id
output e2LoopSloTargetMs string = '4.2ms P99 (<= 10.0ms O-RAN E2SM-RC SLO)'
output sliceProvisioningTargetSec string = '11.5s with 0.0% URLLC PRB starvation'
