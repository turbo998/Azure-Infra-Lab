// ============================================================================
// Blueprint #36: Hybrid Quantum-Classical Agentic Sandboxes
// Provisions:
//   1. Azure Quantum Workspace + Storage Account for QIR Job Artifacts
//   2. AKS `Standard_ND96isr_H200_v5` NVIDIA cuQuantum Tensor-Network Pre-Filter Pool
//   3. QIR LLVM Transpilation & Floquet / Surface-Code Error-Mitigation Labels
// ============================================================================

@description('Deployment region')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-qir'

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

// 1. Storage Account for QIR Bitcode & Shot Measurement Artifacts
resource quantumStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: replace('${envPrefix}qirstore', '-', '')
  location: location
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// 2. Azure Quantum Workspace for Hybrid QIR Job Submission
resource quantumWorkspace 'Microsoft.Quantum/workspaces@2023-11-13-preview' = {
  name: '${envPrefix}-quantum-ws'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    storageAccount: quantumStorage.id
    providers: [
      {
        providerId: 'quantinuum'
        providerSku: 'H2-1-Logical-Preview'
      }
      {
        providerId: 'ionq'
        providerSku: 'Forte-Enterprise'
      }
      {
        providerId: 'rigetti'
        providerSku: 'Ankaa-3'
      }
    ]
  }
}

// 3. NVIDIA H200 cuQuantum Tensor-Network Pre-Filter Pool
resource existingAks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource cuQuantumPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: existingAks
  name: 'cuquantumpool'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H200_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'aksclaw.io/quantum-prefilter': 'nvidia-cuquantum-cutensornet-h200'
      'aksclaw.io/qir-transpiler': 'llvm-qir-base-adaptive-profile'
      'aksclaw.io/qec-mitigation': 'floquet-surface-code-zne'
    }
  }
}

output quantumWorkspaceId string = quantumWorkspace.id
output cuQuantumPoolId string = cuQuantumPool.id
