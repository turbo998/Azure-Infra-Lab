// blueprints/aksclaw-metallurgical-silicon-ferrosilicon-saf-sio-cavity-microsilica-nfpa86-sil3-pool.bicep
// Blueprint #181 (Cycle #180 · 180-Cycle & 180-Simulator Milestone!): Autonomous Metallurgical Silicon & Ferrosilicon Submerged Arc Furnace (MG-Si 99.5% & FeSi75 SAF 45-63 MVA, 1,800-2,050C SiO(g) Cavity & SiC Condensation-Carburization) & Ladle Oxidative Refining PINN-MPC + NFPA 86 / NFPA 652 / OSHA 1910.119 / ISO 13577 / IEC 61511 SIL-3 SiO Jet Blowing, Water-Silicon H2 Explosion & Microsilica Baghouse Fire Interlock Pool
@description('Azure region for the Metallurgical Silicon & Ferrosilicon SAF PINN-MPC & NFPA 86 / NFPA 652 / SIL-3 cluster')
param location string = resourceGroup().location

@description('Environment prefix for the Metallurgical Silicon & Ferrosilicon SAF control plane')
param envPrefix string = 'mgsisafpinn'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.30.6'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.239.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.239.1.0/24'
        }
      }
      {
        name: 'pinn-gpu-subnet'
        properties: {
          addressPrefix: '10.239.2.0/24'
        }
      }
      {
        name: 'sil3-mgsi-saf-interlock-subnet'
        properties: {
          addressPrefix: '10.239.3.0/24'
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
        name: 'mgsigpupool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/Accelerator': 'nvidia-a100'
          'agent.azure.com/PinnDomain': 'metallurgical-silicon-ferrosilicon-saf-sio-cavity-sic-mpc'
          'agent.azure.com/Metrology': '10khz-arc-cavity-3rd-harmonic-ir-blowing-tdlas-sio-libs'
        }
      }
      {
        name: 'sil3mgsipool'
        count: 3
        vmSize: 'Standard_D16ds_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/SafetyStandard': 'NFPA-86-NFPA-652-OSHA-1910-119-ISO-13577-IEC-61511-SIL3'
          'agent.azure.com/InterlockTarget': 'sio-cavity-blow-stoking-water-leak-cutoff-baghouse-spark-0.33ms'
        }
      }
    ]
  }
}

output aksClusterName string = aks.name
output pinnGpuPoolLabel string = 'metallurgical-silicon-ferrosilicon-saf-sio-cavity-sic-mpc'
output safetyInterlockStandard string = 'NFPA-86-NFPA-652-OSHA-1910-119-ISO-13577-IEC-61511-SIL3'
