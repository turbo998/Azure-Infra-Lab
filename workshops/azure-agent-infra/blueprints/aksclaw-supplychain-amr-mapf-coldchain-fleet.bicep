// ============================================================================
// Blueprint #40: Autonomous Retail, Warehouse AMR Fleet & Supply Chain Control
// Tower Agent Infrastructure — RFID / Vision Edge Inventory Fusion, Multi-Robot
// CBS/MAPF Deadlock-Free Path Verification & Cold-Chain Excursion Guardrail
// ============================================================================
targetScope = 'resourceGroup'

@description('Deployment region for Supply Chain Control Tower & AMR MAPF cluster')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-scm'

@description('Existing AKS cluster name')
param aksClusterName string = '${envPrefix}-aks'

@description('MAPF-CBS trajectory solver node count (Standard_F32s_v2)')
@minValue(3)
@maxValue(64)
param mapfSolverNodeCount int = 8

// 1. Azure Digital Twins instance for Real-Time Warehouse & Cold-Chain Graph
resource warehouseDigitalTwin 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${envPrefix}-fulfillment-dt'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

// 2. Event Hubs Premium Namespace for RFID EPC Gen2 & AMR LiDAR Edge Fusion Stream
resource amrTelemetryNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${envPrefix}-amr-rfid-ehns'
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
  }
}

resource rfidFusionHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: amrTelemetryNamespace
  name: 'epc-gen2-amr-pose-stream'
  properties: {
    partitionCount: 32
    messageRetentionInDays: 7
  }
}

resource coldChainArrheniusHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: amrTelemetryNamespace
  name: 'fsma204-gxp-coldchain-telemetry'
  properties: {
    partitionCount: 16
    messageRetentionInDays: 14
  }
}

// 3. Dedicated AKS Compute-Optimized Nodepool for MAPF Conflict-Based Search (CBS)
//    & EDI 856/940 Idempotent Commitment Guardrail (<= 11.4 ms trajectory verification)
resource existingAks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource mapfSolverPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: existingAks
  name: 'scmmaphcbs'
  properties: {
    count: mapfSolverNodeCount
    vmSize: 'Standard_F32s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 3
    maxCount: 64
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
    nodeLabels: {
      'aksclaw.io/workload-class': 'supplychain-amr-mapf-cbs-verifier'
      'aksclaw.io/rfid-edge-fusion': 'epc-gen2-3d-lidar-dedup-98pct'
      'aksclaw.io/mapf-solver': 'conflict-based-search-11ms-deadlock-free'
      'aksclaw.io/coldchain-guard': 'fsma204-gxp-arrhenius-edi856-idempotent'
    }
    nodeTaints: [
      'aksclaw.io/supplychain-mapf=true:NoSchedule'
    ]
  }
}

output digitalTwinsHostName string = warehouseDigitalTwin.properties.hostName
output rfidEventHubId string = rfidFusionHub.id
output mapfSolverPoolId string = mapfSolverPool.id
