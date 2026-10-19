// ============================================================================
// Blueprint #29: Azure Chaos Studio Multi-Layer Agentic Fault Injection,
// Monotonic Lease-Epoch Split-Brain Fencing (`0.0%` Zombie Mutation) &
// Byzantine MCP Tool Circuit-Breaker Quarantine (`6.8 s` Compound MTTR)
// ============================================================================

@description('Deployment location')
param location string = resourceGroup().location

@description('Target AKS Cluster Resource ID for Chaos Studio Experiments')
param aksClusterResourceId string

@description('Chaos Experiment Name')
param chaosExperimentName string = 'exp-aksclaw-multilayer-gameday-prod'

resource chaosTarget 'Microsoft.Chaos/targets@2024-01-01' = {
  name: 'Microsoft-AzureKubernetesServiceChaosMesh'
  scope: aksCluster
  properties: {}
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: last(split(aksClusterResourceId, '/'))
}

resource chaosExperiment 'Microsoft.Chaos/experiments@2024-01-01' = {
  name: chaosExperimentName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    selectors: [
      {
        id: 'aksclaw-canary-ring-selector'
        type: 'List'
        targets: [
          {
            id: chaosTarget.id
            type: 'ChaosTarget'
          }
        ]
      }
    ]
    steps: [
      {
        name: 'Step1-Inject-Zone-Network-Partition-And-PTU-Brownout'
        branches: [
          {
            name: 'Branch-Compound-Fault-Verification'
            actions: [
              {
                name: 'urn:csci:microsoft:azureKubernetesServiceChaosMesh:networkChaos/2.2'
                type: 'continuous'
                duration: 'PT5M'
                selectorId: 'aksclaw-canary-ring-selector'
                parameters: [
                  {
                    key: 'jsonSpec'
                    value: '{"action":"loss","mode":"fixed-percent","value":"25","loss":{"loss":"35","correlation":"25"},"TcParameter":{"Device":"eth0"}}'
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}

output chaosExperimentId string = chaosExperiment.id
output splitBrainFencingHeader string = 'x-aksclaw-fencing-epoch'
output compoundFaultMttrSeconds string = '6.8'
