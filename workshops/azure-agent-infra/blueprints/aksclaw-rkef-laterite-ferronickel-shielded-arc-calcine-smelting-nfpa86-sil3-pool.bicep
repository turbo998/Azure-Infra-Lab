// blueprints/aksclaw-rkef-laterite-ferronickel-shielded-arc-calcine-smelting-nfpa86-sil3-pool.bicep
// Blueprint #182 (Cycle #181 · 190-Test Milestone!): Autonomous Laterite Nickel Rotary Kiln-Electric Furnace (RKEF 80-90 MVA Shielded-Arc Smelting 1,550-1,650C Ferronickel FeNi 20-35% Ni & Converting to High-Grade Nickel Matte 75% Ni) — Rotary-Kiln Selective Pre-Reduction, Hot-Calcine Slide-Gate Fluidization Control & Copper-Waffle Freeze-Lining PINN-MPC + NFPA 86 / ISO 13577 / OSHA 1910.119 / IEC 61511 SIL-3 Calcine-Flush Boilover, Copper-Cooler Burn-Through Steam Explosion & Kiln Coal-Gas Deflagration Interlock Pool
@description('Azure region for the RKEF Laterite Ferronickel & Nickel-Matte Smelting PINN-MPC & NFPA 86 / ISO 13577 / SIL-3 cluster')
param location string = resourceGroup().location

@description('Environment prefix for the RKEF Laterite Ferronickel Shielded-Arc SAF control plane')
param envPrefix string = 'rkefpinn'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.30.6'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.240.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.240.1.0/24'
        }
      }
      {
        name: 'pinn-gpu-subnet'
        properties: {
          addressPrefix: '10.240.2.0/24'
        }
      }
      {
        name: 'sil3-rkef-interlock-subnet'
        properties: {
          addressPrefix: '10.240.3.0/24'
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
        name: 'rkefgpupool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/Accelerator': 'nvidia-a100'
          'agent.azure.com/PinnDomain': 'rkef-laterite-ferronickel-shielded-arc-freeze-lining-mpc'
          'agent.azure.com/Metrology': '10khz-copper-waffle-heat-flux-kiln-tdlas-slag-libs'
        }
      }
      {
        name: 'sil3rkefpool'
        count: 3
        vmSize: 'Standard_D16ds_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/SafetyStandard': 'NFPA-86-ISO-13577-OSHA-1910-119-IEC-61511-SIL3'
          'agent.azure.com/InterlockTarget': 'calcine-flush-boilover-waffle-cooler-burnthrough-0.33ms'
        }
      }
    ]
  }
}

output aksClusterName string = aks.name
output pinnGpuPoolLabel string = 'rkef-laterite-ferronickel-shielded-arc-freeze-lining-mpc'
output safetyInterlockStandard string = 'NFPA-86-ISO-13577-OSHA-1910-119-IEC-61511-SIL3'
