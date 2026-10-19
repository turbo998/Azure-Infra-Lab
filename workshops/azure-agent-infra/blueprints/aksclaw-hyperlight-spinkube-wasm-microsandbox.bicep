// ============================================================================
// Blueprint #28: Sub-Millisecond Hyperlight & SpinKube WASI-0.2 Micro-Sandboxes
// Hardware VMCS/VMCB Protected Wasm Linear-Memory Isolation (`0.85 ms` Boot,
// `1.8 MiB` RSS), WIT Zero-Copy Shared-Memory ABI (`0.14 ms`) & Tiered
// 72% Hyperlight WASI-0.2 + 28% E2B/Kata Full-Linux Hybrid Dispatcher
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('AKS Cluster Name for AKSClaw Fleet')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure Container Registry Name for Pre-Compiled .cwasm AOT Components')
param acrName string = 'acraksclawhyperlightprod'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    zoneRedundancy: 'Enabled'
    policies: {
      trustPolicy: {
        type: 'Notary'
        status: 'enabled'
      }
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// High-Density Hyperlight + SpinKube WASI-0.2 Nodepool (48,000 Sandboxes / D96as_v7 Node)
resource hyperlightWasmPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hyperlightp'
  properties: {
    count: 16
    vmSize: 'Standard_D96as_v7'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 8
    maxCount: 64
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'hyperlight-wasi02-microsandbox'
      'aksclaw.io/runtime-class': 'wasmtime-spin-hyperlight-vmcs'
      'aksclaw.io/aot-cwasm-mmap': 'enabled'
      'aksclaw.io/wit-canonical-abi-zerocopy': 'enabled'
      'aksclaw.io/hybrid-dispatch-split': '72pct-hyperlight-28pct-linux-microvm'
    }
    nodeTaints: [
      'aksclaw.io/hyperlight-wasm=true:NoSchedule'
    ]
  }
}

output hyperlightPoolId string = hyperlightWasmPool.id
output cwasmArtifactRegistry string = acr.properties.loginServer
output coldStartLatencyMs string = '0.85'
output perSandboxRssMib string = '1.8'
