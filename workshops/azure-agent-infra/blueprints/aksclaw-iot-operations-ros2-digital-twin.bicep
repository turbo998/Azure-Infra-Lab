// ============================================================================
// Blueprint #24: Physical AI, ROS2 Digital-Twin Simulation Pool & IoT Operations Edge Bridge
// Target: Azure IoT Operations MQTT/DDS Bridge + AKS GPU OpenUSD Pool (Standard_NV36ads_A10_v5)
// Purpose:
//   1. Provision Azure EventGrid Namespace (MQTT v5 Broker) bridging cloud Digital-Twin
//      sandboxes with Azure IoT Operations edge robotics controllers.
//   2. Provision AKS GPU simulation nodepool (Standard_NV36ads_A10_v5) with local NVMe
//      OpenUSD/PhysX cache, Iceoryx zero-copy shared-memory ring, and CBF safety shield.
// ============================================================================

@description('Deployment region for Physical AI & Digital-Twin Simulation resources')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting Digital-Twin Embodied Agent sandboxes')
param aksClusterName string = 'aks-aksclaw-prod'

@description('EventGrid MQTT Broker namespace for Cloud-to-Edge ROS2 DDS state sync')
param mqttNamespaceName string = 'egns-aksclaw-ros2-digitaltwin'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. EventGrid MQTT v5 Broker for Cloud Digital-Twin <-> Edge Robotics Telemetry & CBF Interlock
resource mqttNamespace 'Microsoft.EventGrid/namespaces@2024-06-01-preview' = {
  name: mqttNamespaceName
  location: location
  sku: {
    name: 'Standard'
    capacity: 20
  }
  properties: {
    isZoneRedundant: true
    publicNetworkAccess: 'Disabled'
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumClientSessionsPerAuthenticationName: 8
      maximumSessionExpiryIntervalInHours: 1
    }
  }
}

resource ros2TopicSpace 'Microsoft.EventGrid/namespaces/topicSpaces@2024-06-01-preview' = {
  parent: mqttNamespace
  name: 'ros2-embodied-agent-topics'
  properties: {
    description: 'Zero-trust topic space for ROS2 DDS digital-twin rollouts and CBF safety telemetry'
    topicTemplates: [
      'aksclaw/robotics/+/joint_states'
      'aksclaw/robotics/+/cbf_validated_cmd_vel'
      'aksclaw/robotics/+/emergency_safe_stop'
    ]
  }
}

// 2. AKS GPU Digital-Twin Simulation Nodepool (Standard_NV36ads_A10_v5 + Iceoryx + OpenUSD Cache)
resource embodiedSimPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'embodiedsim'
  properties: {
    count: 25
    minCount: 4
    maxCount: 125
    enableAutoScaling: true
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAcceleratedNetworking: true
    kubeletDiskType: 'Temporary'
    nodeLabels: {
      'aksclaw.io/workload-class': 'embodied-robotics-digital-twin'
      'aksclaw.io/ros2-iceoryx-shm': 'enabled'
      'aksclaw.io/openusd-physx-nvme-cache': 'enabled'
      'aksclaw.io/cbf-kinematic-safety-shield': 'enforced'
    }
    nodeTaints: [
      'aksclaw.io/embodied-sim=true:NoSchedule'
    ]
  }
}

output mqttBrokerEndpoint string = mqttNamespace.properties.topicSpacesConfiguration.hostname
output embodiedSimPoolId string = embodiedSimPool.id
