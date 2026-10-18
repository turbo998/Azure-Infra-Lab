// ============================================================================
// Blueprint #17: AKSClaw Zero-Downtime Fleet Upgrade, Node Soak & MANA Live Migration
// Configures AKS Agent Pool maxSurge: '33%', nodeSoakDurationInMinutes: 15,
// drainTimeoutInMinutes: 30, Weekly Maintenance Configurations & Accelerated Networking
// ============================================================================

@description('Target Azure region')
param location string = resourceGroup().location

@description('Existing AKSClaw cluster name')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Sandbox execution agent pool name')
param sandboxPoolName string = 'katapool'

@description('Host VM SKU with 50 Gbps Azure MANA Accelerated Networking')
param vmSize string = 'Standard_D64s_v6'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: aksClusterName
}

// 1. Zero-Downtime Sandbox Agent Pool with 33% Surge, 15m Soak & 30m Live-Migration Drain Window
resource sandboxAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: sandboxPoolName
  properties: {
    count: 25
    minCount: 10
    maxCount: 150
    enableAutoScaling: true
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    upgradeSettings: {
      maxSurge: '33%'
      nodeSoakDurationInMinutes: 15
      drainTimeoutInMinutes: 30
      undrainableNodeBehavior: 'Cordon'
    }
    nodeLabels: {
      'aksclaw.io/isolation': 'kata-vm-isolation'
      'aksclaw.io/nvme-cache-hydrated': 'true'
      'aksclaw.io/mana-live-migration': 'enabled-50gbps'
      'aksclaw.io/canary-ring': 'stable'
    }
    nodeTaints: [
      'aksclaw.io/sandbox-only=true:NoSchedule'
    ]
  }
}

// 2. Planned Node OS & Kernel Security Patching Maintenance Window (Off-Peak Sunday 02:00 UTC)
resource nodeOsMaintenanceWindow 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2024-05-01' = {
  parent: aksCluster
  name: 'aksManagedNodeOSUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 4
      utcOffset: '+00:00'
      startDate: '2026-10-18'
      startTime: '02:00'
    }
  }
}

output agentPoolId string = sandboxAgentPool.id
output maxSurgeSetting string = sandboxAgentPool.properties.upgradeSettings.maxSurge
output soakMinutes int = sandboxAgentPool.properties.upgradeSettings.nodeSoakDurationInMinutes
output drainTimeoutMinutes int = sandboxAgentPool.properties.upgradeSettings.drainTimeoutInMinutes
