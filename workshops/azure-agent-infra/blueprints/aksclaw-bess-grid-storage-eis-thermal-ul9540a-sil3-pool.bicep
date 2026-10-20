// =============================================================================
// Blueprint #73: Grid-Scale Hybrid BESS (LFP + VRFB), EIS Thermal Runaway PINN
// & UL 9540A / NFPA 855 / IEC 62933-5-2 SIL-3 Deflagration & DC Contactor Pool
// =============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the regional BESS fleet control & Newman P2D PINN plane')
param location string = resourceGroup().location

@description('Environment identifier')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('Number of 5 MWh utility-scale LFP + VRFB hybrid BESS containers')
@minValue(4)
@maxValue(256)
param bessContainers int = 32

@description('AKS node VM size for Newman P2D electrochemical PINN & EIS Nyquist inversion')
param pinnNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Maximum NFPA 855 off-gas Lower Explosive Limit (LEL) fraction before SIL-3 purging')
param maxOffGasLelFraction string = '0.25'

@description('Maximum UL 9540A cell core temperature threshold (degC) before DC pyro-fuse trip')
param maxCellCoreTempDegC int = 68

var clusterName = 'aks-bess-ul9540a-sil3-${environment}'
var pinnNodeCount = max(2, (bessContainers + 15) / 16)
var activePcsBays = max(2, (bessContainers + 7) / 8)

resource bessVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-bess-ul9540a-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.246.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-p2d-eis-pinn'
        properties: {
          addressPrefix: '10.246.0.0/22'
        }
      }
      {
        name: 'snet-bess-pcs-ul9540a-sil3'
        properties: {
          addressPrefix: '10.246.4.0/22'
        }
      }
    ]
  }
}

resource bessAks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'bess-grid-storage-eis-thermal-ul9540a-sil3'
    bessContainers: string(bessContainers)
    activePcsBays: string(activePcsBays)
    maxOffGasLelFraction: maxOffGasLelFraction
    maxCellCoreTempDegC: string(maxCellCoreTempDegC)
    safetyStandard: 'UL-9540A-NFPA-855-IEC-62933-5-2-SIL3'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: bessVnet.properties.subnets[0].id
      }
      {
        name: 'p2deispinn'
        count: pinnNodeCount
        vmSize: pinnNodeVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: bessVnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/bess-role': 'newman-p2d-eis-dqdv-mpc'
          'agent.azure.com/ul9540a-sil3-interlock': 'dc-pyro-fuse-lel-vent-4ms2'
        }
      }
      {
        name: 'katabms'
        count: activePcsBays
        vmSize: 'Standard_D16s_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: bessVnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/bess-role': 'iec61850-modbus-pcs-bms-sandbox'
          'agent.azure.com/isolation': 'kata-vm-root-of-trust'
        }
      }
    ]
  }
}

output clusterResourceId string = bessAks.id
output pinnNodeCountOutput int = pinnNodeCount
output activePcsBaysOutput int = activePcsBays
