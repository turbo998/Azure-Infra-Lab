@description('Azure region for the VLEO ABEP Atmosphere-Breathing Electric Propulsion DSMC Intake & ECSS SIL-3 Sandbox Pool')
param location string = resourceGroup().location

@description('Resource name prefix for the VLEO ABEP Rarefied-Gas DSMC & RF Helicon Ion-Thruster Agent cluster')
param prefix string = 'vleoabep'

@description('Kubernetes version for the AKS control plane')
param kubernetesVersion string = '1.31'

@description('VM SKU for the Kata-isolated VLEO ABEP DSMC intake and RF helicon plasma control worker pool')
param kataVmSize string = 'Standard_D16s_v5'

@description('VM SKU for the PINN-MPC rarefied-gas DSMC intake compression and thermospheric drag-compensation GPU pool')
param gpuVmSize string = 'Standard_ND96isr_H100_v5'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.228.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-vleo-abep-subnet'
        properties: {
          addressPrefix: '10.228.1.0/24'
        }
      }
      {
        name: 'orbital-ground-ecss-sil3-subnet'
        properties: {
          addressPrefix: '10.228.2.0/24'
        }
      }
    ]
  }
}

resource ledger 'Microsoft.ConfidentialLedger/ledgers@2023-06-28-preview' = {
  name: '${prefix}-ecss-sil3-ledger'
  location: location
  properties: {
    ledgerType: 'Private'
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: '${prefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${prefix}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        logAnalyticsWorkspaceResourceId: ''
        securityMonitoring: {
          enabled: false
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'katavleo'
        count: 6
        vmSize: kataVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv'
          'vleo.azure.com/domain': 'abep-ram-ep-ion-thruster'
          'safety.azure.com/standard': 'ecss-st10c-nasa8719-sil3'
        }
        nodeTaints: [
          'vleo.azure.com/kata-only=true:NoSchedule'
        ]
      }
      {
        name: 'gpudsmc'
        count: 2
        vmSize: gpuVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/accelerator': 'h100-ndv5'
          'vleo.azure.com/solver': 'pinn-mpc-dsmc-helicon-drag'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
    ]
  }
}

output aksClusterName string = aks.name
output confidentialLedgerName string = ledger.name
