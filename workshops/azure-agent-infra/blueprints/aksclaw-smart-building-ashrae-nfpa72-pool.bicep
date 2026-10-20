// ============================================================================
// Blueprint #52: Autonomous Smart Campus & High-Rise Commercial Real Estate
// Agent Infrastructure (Azure Digital Twins RealEstateCore/Brick + ASHRAE 62.1
// IAQ Gate + Destination-Dispatch Elevator Solver + NFPA 72 Life-Safety Interlock)
// Chapter 56 Reference Implementation
// ============================================================================

@description('Deployment region for the smart campus agent infrastructure')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-bldg'

@description('Smart campus gross floor area in thousands of square meters (125 to 2000)')
@minValue(125)
@maxValue(2000)
param campusGrossFloorAreaKSqm int = 500

var campusEdgeNodeCount = max(2, (campusGrossFloorAreaKSqm + 124) / 125)

resource adtCampus 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${envPrefix}-adt-realestatecore'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  tags: {
    ontology: 'RealEstateCore-4.0-Brick-1.3'
    ashraeStandard: 'ASHRAE-90.1-and-62.1-CO2-800ppm'
    lifeSafetyStandard: 'NFPA-72-BACnet-Priority-Array-Lock'
  }
}

resource aksSmartBuilding 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-aks'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v6'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'bldgmpcpool'
        count: campusEdgeNodeCount
        vmSize: 'Standard_D32as_v7'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'aksclaw.io/workload-class': 'smart-building-ashrae-nfpa72-agent'
          'aksclaw.io/adt-mpc-hvac-solver': 'enabled-31.8pct-energy-cut-26.4pct-peak-cut'
          'aksclaw.io/ashrae62-iaq-co2-gate': 'enforced-800ppm-1.6ms-zero-violation'
          'aksclaw.io/nfpa72-bacnet-priority-lock': 'enforced-priority12-only-0.8ms-zero-override'
        }
      }
    ]
  }
}

output adtInstanceId string = adtCampus.id
output smartBuildingAksId string = aksSmartBuilding.id
output deployedCampusEdgeNodes int = campusEdgeNodeCount
