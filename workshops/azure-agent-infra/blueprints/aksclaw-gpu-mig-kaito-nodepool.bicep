// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint 10
// AKSClaw Heterogeneous GPU Node Pool (`Standard_NC40ads_H100_v5` with MIG 1g.10gb)
// + KAITO (Kubernetes AI Toolchain Operator) Prefix-Cache Aware vLLM Workspace
// ============================================================================

targetScope = 'resourceGroup'

@description('Deployment region supporting H100 v5 Confidential/Accelerated GPU VMs')
param location string = resourceGroup().location

@description('Existing AKS cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Subnet ID for GPU inference & GUI-grounding sidecar nodes')
param gpuSubnetId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. NVIDIA H100 NVL (Standard_NC40ads_H100_v5) Node Pool with Hardware MIG 1g.10gb Partitioning
resource h100MigNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'gpuh100mig'
  properties: {
    count: 2
    minCount: 1
    maxCount: 16
    enableAutoScaling: true
    vmSize: 'Standard_NC40ads_H100_v5' // 1x NVIDIA H100 NVL (94 GB HBM3) · 40 vCPU / 320 GiB RAM
    osType: 'Linux'
    osSKU: 'Ubuntu'
    gpuInstanceProfile: 'MIG1g' // Hardware-isolated 1g.10gb slices (7 slices/GPU · 0% cross-tenant jitter)
    vnetSubnetID: gpuSubnetId
    osDiskSizeGB: 512
    osDiskType: 'Ephemeral'
    nodeLabels: {
      'aksclaw.azure.com/accelerator': 'nvidia-h100-mig-1g'
      'kaito.sh/workspace-pool': 'gui-grounding-vllm'
    }
    nodeTaints: [
      'sku=gpu-h100-mig:NoSchedule'
    ]
  }
}

// 2. KAITO Workspace Manifest Reference for Prefix-Cache Aware vLLM Inference Sidecar
output kaitoWorkspaceSpec object = {
  apiVersion: 'kaito.sh/v1beta1'
  kind: 'Workspace'
  metadata: {
    name: 'wksp-cua-grounding-prefix-cache'
    namespace: 'agent-fleet'
  }
  resource: {
    instanceType: 'Standard_NC80adis_H100_v5'
    labelSelector: {
      matchLabels: {
        'kaito.sh/workspace-pool': 'gui-grounding-vllm'
      }
    }
  }
  inference: {
    preset: {
      name: 'vllm-prefix-caching-cua'
    }
    config: '--enable-prefix-caching --gpu-memory-utilization 0.92 --max-num-seqs 64'
  }
}
