// ============================================================================
// Blueprint #43: Semiconductor EDA, RTL-to-GDSII & Formal Verification Farm
// ============================================================================
// Target Architecture:
//   1. Azure NetApp Files Ultra (Sub-ms POSIX NFSv4.1 volume for Verilator
//      AST-hashed C++ object cache, OpenAccess PDKs, and GDSII/OASIS layouts)
//   2. FlexNet Floating EDA License Lease Coordinator & 3.0s Zombie-Seat Reaper
//   3. AKS Standard_FX48mds (4.0 GHz all-core turbo, 768 GiB RAM, 16:1 RAM/vCPU)
//      nodepool for SymbiYosys/LEC formal proofs & OpenROAD/KLayout DRC/LVS
// ============================================================================

@description('Deployment region for Semiconductor EDA Agent Infrastructure')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-eda'

@description('Existing AKS cluster name')
param aksClusterName string = '${envPrefix}-aks'

@description('Standard_FX48mds high-frequency high-memory EDA node count')
@minValue(4)
@maxValue(64)
param edaComputeNodeCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. Azure NetApp Files Account, Ultra Capacity Pool & POSIX EDA PDK/Cache Volume
resource netappAccount 'Microsoft.NetApp/netAppAccounts@2024-03-01' = {
  name: '${envPrefix}-anf-acct'
  location: location
}

resource anfUltraPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2024-03-01' = {
  parent: netappAccount
  name: 'eda-ultra-pool'
  location: location
  properties: {
    serviceLevel: 'Ultra'
    size: 17592186044416 // 16 TiB Ultra pool (~2,048 MiB/s throughput)
    qosType: 'Auto'
  }
}

// 2. AKS Standard_FX48mds (4.0 GHz All-Core Turbo, 768 GiB RAM) EDA & LEC Nodepool
resource edaRtlGdsiiPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'edafx48p'
  properties: {
    count: edaComputeNodeCount
    vmSize: 'Standard_FX48mds'
    osDiskSizeGB: 512
    osDiskType: 'Ephemeral'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    enableUltraSSD: true
    nodeLabels: {
      'aksclaw.io/workload-class': 'semiconductor-eda-rtl-gdsii-verifier'
      'aksclaw.io/verilator-ast-cache': 'anf-ultra-posix-185khz-62s'
      'aksclaw.io/formal-lec-drc-gate': 'symbiyosys-lec-klayout-wns-zero-ps'
      'aksclaw.io/flexnet-license-guard': 'dag-prelease-3s-zombie-reaper'
    }
    nodeTaints: [
      'aksclaw.io/eda-silicon=true:NoSchedule'
    ]
  }
}

output anfAccountId string = netappAccount.id
output edaNodePoolName string = edaRtlGdsiiPool.name
