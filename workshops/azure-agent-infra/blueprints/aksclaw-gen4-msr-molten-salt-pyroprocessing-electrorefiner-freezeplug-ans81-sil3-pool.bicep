// ============================================================================
// AKSClaw Blueprint #168: Autonomous Gen-IV Molten-Salt Reactor (MSR / TMSR)
// Liquid-Fuel Loop (LiF-BeF2-ZrF4-UF4/ThF4 650-700 °C) & Pyroprocessing
// Molten-Salt Electrorefining (500 °C LiCl-KCl Eutectic Liquid-Cadmium Cathode
// U/TRU Codeposition) Delayed-Neutron Precursor Drift, UF4/UF3 Redox Hastelloy-N
// Tellurium-Corrosion & Nernst-Planck Electrodeposition PINN-MPC, Online 10 kHz
// Cyclic Voltammetry / HPGe Gamma / LIBS Metrology & IAEA SSR-2/1 / ANS-8.1 /
// ASME Sec. III Div. 5 / IEC 61513 SIL-3 Freeze-Plug Drain Tank & Subcriticality Pool
// ============================================================================
@description('Azure region for the AKSClaw Gen-IV MSR & Pyroprocessing Electrorefiner Edge cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'msrpyropl3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.228.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.228.1.0/24'
        }
      }
      {
        name: 'aks-msr-pyro-gpu-subnet'
        properties: {
          addressPrefix: '10.228.2.0/23'
        }
      }
      {
        name: 'iec61513-sil3-freezeplug-ans81-subnet'
        properties: {
          addressPrefix: '10.228.4.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
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
      networkPolicy: 'cilium'
       networkDataplane: 'cilium'
      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.10'
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
        name: 'msrpyrogpu'
        count: 4
        vmSize: 'Standard_NV36ads_A10_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/workload': 'gen4-msr-molten-salt-pyroprocessing-electrorefiner-pinn-mpc'
          'agent.azure.com/metrology': 'cv-10khz-hpge-gamma-libs-uf4-uf3-redox'
          'agent.azure.com/safety': 'iaea-ssr2-1-ans-8-1-asme-iii-div5-iec61513-sil3'
        }
        nodeTaints: [
          'nuclear.azure.com/msr-pyroprocessing-hotcell=true:NoSchedule'
        ]
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output aksClusterName string = aksCluster.name
output gpuPoolNodeLabel string = 'gen4-msr-molten-salt-pyroprocessing-electrorefiner-pinn-mpc'
output safetyStandard string = 'IAEA-SSR-2-1-ANSI-ANS-8-1-ASME-BPVC-III-Div5-IEC-61513-SIL3'
