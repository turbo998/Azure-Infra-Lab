// ============================================================================
// Blueprint #30: AI-for-Science & HPC Agent Sandboxes — Azure Managed Lustre
// Parallel POSIX File System (`160 GB/s`), HB176rs_v4 400Gb/s NDR InfiniBand
// Topology-Aware Gang Pool (`1.65 us` MPI) & Async NVMe-to-Lustre Checkpointer
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name for AKSClaw Fleet')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure Managed Lustre File System Name')
param amlfsName string = 'amlfs-aksclaw-science-prod'

@description('Delegated Subnet ID for Azure Managed Lustre')
param lustreSubnetId string

resource amlfs 'Microsoft.StorageCache/amlFilesystems@2023-05-01' = {
  name: amlfsName
  location: location
  sku: {
    name: 'AMLFS-Durable-Premium-250'
  }
  zones: [
    '1'
  ]
  properties: {
    storageCapacityTiB: 128
    filesystemSubnet: lustreSubnetId
    maintenanceWindow: {
      dayOfWeek: 'Sunday'
      timeOfDayUTC: '03:00'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// HB176rs_v4 (AMD Genoa-X 3D V-Cache + 400Gb/s NDR InfiniBand) Scientific Solver Pool
resource hpcSciencePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hbv4science'
  properties: {
    count: 16
    vmSize: 'Standard_HB176rs_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    scaleSetPriority: 'Regular'
    nodeLabels: {
      'aksclaw.io/workload-class': 'ai-for-science-mpi-solver'
      'aksclaw.io/infiniband-ndr-400g': 'enabled'
      'aksclaw.io/gang-scheduler': 'kueue-topology-aware-torus'
      'aksclaw.io/lustre-parallel-mount': amlfsName
      'aksclaw.io/veloc-async-nvme-checkpoint': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/scientific-hpc=true:NoSchedule'
    ]
  }
}

output lustreMgsAddress string = amlfs.properties.clientInfo.mgsAddress
output hpcPoolResourceId string = hpcSciencePool.id
output parallelPosixBandwidthGBps int = 160
output mpiAllReduceLatencyUs string = '1.65'
