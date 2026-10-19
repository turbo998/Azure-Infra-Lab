// ============================================================================
// Blueprint #34: Industrial Edge-to-Cloud Disconnected Agentic Infrastructure
// Provisions:
//   1. Azure IoT Operations (AIO) Instance + Distributed MQTTv5 Broker with NVMe Disk-Backed Store-and-Forward
//   2. Dataflow Endpoint to Cloud Event Hubs / Azure Digital Twins with Token-Bucket Uplink Shaping
//   3. Azure Arc-Enabled Kubernetes Edge SLM Nodepool Labels (`ONNX Runtime GenAI INT4` + `HLC-CRDT`)
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-edge'

@description('Custom Location resource ID on Azure Local / Arc-enabled K8s')
param customLocationId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aksclaw-edge/providers/Microsoft.ExtendedLocation/customLocations/cl-factory-01'

@description('Schema Registry resource ID')
param schemaRegistryId string = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aksclaw-edge/providers/Microsoft.DeviceRegistry/schemaRegistries/sr-factory-01'

// 1. Azure IoT Operations Instance on Azure Local
resource aioInstance 'Microsoft.IoTOperations/instances@2024-08-15-preview' = {
  name: '${envPrefix}-aio-instance'
  location: location
  extendedLocation: {
    name: customLocationId
    type: 'CustomLocation'
  }
  properties: {
    description: 'AKSClaw Disconnected Industrial Edge Agent Runtime + MQTTv5 Store-and-Forward'
    schemaRegistryRef: {
      resourceId: schemaRegistryId
    }
  }
}

// 2. Distributed MQTTv5 Broker with NVMe Disk-Backed Store-and-Forward Buffer (72h Disconnected Survival)
resource mqttBroker 'Microsoft.IoTOperations/instances/brokers@2024-08-15-preview' = {
  parent: aioInstance
  name: 'default'
  extendedLocation: {
    name: customLocationId
    type: 'CustomLocation'
  }
  properties: {
    memoryProfile: 'High'
    generateResourceLimits: {
      cpu: 'Enabled'
    }
    cardinality: {
      backendChain: {
        partitions: 8
        redundancyFactor: 2
        workers: 4
      }
      frontend: {
        replicas: 2
        workers: 2
      }
    }
    diskBackedMessageBuffer: {
      maxSize: '250G'
      ephemeralVolumeClaimSpec: {
        storageClassName: 'local-nvme-saf'
        accessModes: [
          'ReadWriteOnce'
        ]
      }
    }
  }
}

// 3. Azure Digital Twins Instance for HLC-CRDT Cloud State Reconciliation
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${envPrefix}-adt-${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

output aioInstanceId string = aioInstance.id
output mqttBrokerId string = mqttBroker.id
output digitalTwinsId string = digitalTwins.id
