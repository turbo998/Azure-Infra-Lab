// blueprints/aksclaw-silicomanganese-ferromanganese-saf-aod-co-prereduction-nfpa86-sil3-pool.bicep
// Blueprint #180 (180-Blueprint Milestone!): Autonomous Silicomanganese & Ferromanganese Submerged Arc Furnace (SiMn/HC-FeMn SAF 63 MVA, 1,400-1,650C) & AOD Refining PINN-MPC + NFPA 86 / OSHA 1910.1000 / ISO 13577 / IEC 61511 SIL-3 Burden Hang-Collapse Eruption & MnOx Fume Interlock Pool
@description('Azure region for the Silicomanganese & Ferromanganese SAF-AOD PINN-MPC & NFPA 86 / SIL-3 cluster')
param location string = resourceGroup().location

@description('Environment prefix for the Silicomanganese & Ferromanganese SAF control plane')
param envPrefix string = 'simnsafpinn'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.30.6'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.238.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.238.1.0/24'
        }
      }
      {
        name: 'pinn-gpu-subnet'
        properties: {
          addressPrefix: '10.238.2.0/24'
        }
      }
      {
        name: 'sil3-saf-aod-interlock-subnet'
        properties: {
          addressPrefix: '10.238.3.0/24'
        }
      }
    ]
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'simngpupool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/Accelerator': 'nvidia-a100'
          'agent.azure.com/PinnDomain': 'silicomanganese-saf-aod-prereduction-slag-basicity-mpc'
          'agent.azure.com/Metrology': '10khz-burden-impedance-tdlas-co-co2-libs-mn-si'
        }
      }
      {
        name: 'sil3simnpool'
        count: 3
        vmSize: 'Standard_D16ds_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/SafetyStandard': 'NFPA-86-OSHA-1910-1000-ISO-13577-IEC-61511-SIL3'
          'agent.azure.com/InterlockTarget': 'burden-hang-eruption-trip-hood-n2-purge-mnox-baghouse-0.34ms'
        }
      }
    ]
  }
}

output aksClusterName string = aks.name
output pinnGpuPoolLabel string = 'silicomanganese-saf-aod-prereduction-slag-basicity-mpc'
output safetyInterlockStandard string = 'NFPA-86-OSHA-1910-1000-ISO-13577-IEC-61511-SIL3'
