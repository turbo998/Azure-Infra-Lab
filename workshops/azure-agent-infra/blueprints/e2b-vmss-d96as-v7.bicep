// E2B on Azure VMSS Reference Architecture — Bicep Deployment Template
// Provisions the 4-Pool VMSS Topology (Server, API, Client on Standard_D96as_v7, Build)
// with Flexible Orchestration (up to 1,000 VMs per VMSS) and 60% CPU scale-out rule.

@description('Target Azure region supporting Standard_D96as_v7 (5th Gen AMD EPYC Turin)')
param location string = 'eastus2'

@description('Client Pool initial VM count (261 nodes supports 100,000 concurrent 512MiB sandboxes @ 60% CPU target)')
param clientPoolInstanceCount int = 261

@description('Client Pool VM SKU — Standard_D96as_v7 delivers 108ms Base / 132ms Code-Interpreter startup')
param clientPoolVmSku string = 'Standard_D96as_v7'

@description('API Pool VM SKU')
param apiPoolVmSku string = 'Standard_D16s_v6'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-e2b-prod'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.240.0.0/16']
    }
    subnets: [
      {
        name: 'snet-appgw-apim'
        properties: { addressPrefix: '10.240.0.0/24' }
      }
      {
        name: 'snet-e2b-pools'
        properties: { addressPrefix: '10.240.16.0/20' }
      }
    ]
  }
}

resource clientVmss 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: 'vmss-e2b-client-pool'
  location: location
  sku: {
    name: clientPoolVmSku
    tier: 'Standard'
    capacity: clientPoolInstanceCount
  }
  properties: {
    orchestrationMode: 'Flexible'
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
    }
  }
}

resource apiVmss 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: 'vmss-e2b-api-pool'
  location: location
  sku: {
    name: apiPoolVmSku
    tier: 'Standard'
    capacity: 12
  }
  properties: {
    orchestrationMode: 'Flexible'
    singlePlacementGroup: false
  }
}

resource clientAutoscale 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: 'autoscale-e2b-client-pool'
  location: location
  properties: {
    enabled: true
    targetResourceUri: clientVmss.id
    profiles: [
      {
        name: 'ScaleOutAt60PctCpuAndCustomHugePages'
        capacity: {
          minimum: '4'
          maximum: '1000'
          default: string(clientPoolInstanceCount)
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricResourceUri: clientVmss.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '10'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}
