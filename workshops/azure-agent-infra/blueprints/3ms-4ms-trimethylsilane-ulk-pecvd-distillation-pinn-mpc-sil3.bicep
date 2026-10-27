// ============================================================================
// Blueprint #237: Autonomous Electronic-Grade Trimethylsilane (6N 3MS HSi(CH3)3)
// & Tetramethylsilane (6N 4MS Si(CH3)4) Ultra-Low-k (ULK p-SiCOH / a-SiC:H)
// PECVD Precursor Extractive-Fractional Distillation, Chlorosilane/Alkane
// Co-Boiler Separation & SEMI C3 / NFPA 55 / IEC 61511 SIL-3 Interlock
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 6N 3MS/4MS ULK PECVD Precursor PINN-MPC & SIL-3 edge-cloud plane')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param environmentName string = 'prod-3ms-4ms-ulk-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Maximum allowable total hydrolysable chloride (Me3SiCl + Me2SiHCl + HCl) impurity (ppmv)')
param maxHydrolysableChloridePpmv string = '0.05'

@description('Maximum allowable C4/C5 alkane co-boiler (neopentane C5H12 + isopentane) impurity (ppmv)')
param maxAlkaneCoBoilerPpmv string = '0.20'

@description('Maximum allowable hexamethyldisiloxane (HMDSO Me3Si-O-SiMe3) impurity (ppmv)')
param maxHmdsoSiloxanePpmv string = '0.20'

@description('BS&B burst-disk & NFPA 68 deflagration relief header trip threshold (% LEL, LEL=1.3% vol)')
param lelTripThresholdPct string = '15.0'

// 1. Virtual Network with 4 Isolated Subnets (Control, Kata Compute, HorizonDB, OT-SIL3-Organosilane)
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${environmentName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.241.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-control'
        properties: {
          addressPrefix: '10.241.1.0/24'
        }
      }
      {
        name: 'snet-aks-kata-3ms-pinn'
        properties: {
          addressPrefix: '10.241.2.0/24'
        }
      }
      {
        name: 'snet-horizondb-private'
        properties: {
          addressPrefix: '10.241.3.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-ot-sil3-3ms-4ms-pecvd-loop'
        properties: {
          addressPrefix: '10.241.4.0/24'
        }
      }
    ]
  }
}

// 2. Log Analytics Workspace for Zero-Trust Audit & SEMI C3 / NFPA 55 / SIL-3 Telemetry
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${environmentName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

// 3. AKS Cluster with Kata MSHV VM Isolation & GPU PINN-MPC Pool for 6N 3MS/4MS Purification & ULK PECVD
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: 'aks-${environmentName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: environmentName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v6'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'katapinn'
        count: 4
        vmSize: 'Standard_D16as_v7'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv-vm-isolation'
          'industry.azure.com/domain': 'trimethylsilane-6n-3ms-4ms-ulk-pecvd-pinn-mpc'
          'safety.azure.com/standard': 'semi-c3-nfpa55-nfpa68-iec61511-sil3'
        }
      }
      {
        name: 'gpumpc'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'industry.azure.com/workload': '3ms-4ms-extractive-distillation-ulk-pecvd-pinn'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      outboundType: 'loadBalancer'
    }
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

// 4. Azure IoT Hub / Event Hubs for 10 kHz QCL-TDLAS (Si-H/Si-O-Si/Si-Cl), VUV-PIMS, CRDS & SIL-3 Telemetry
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'ehns-${environmentName}'
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: '3ms-4ms-qcl-tdlas-vuv-pims-crds-sil3-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

// 5. Key Vault for CMK Encryption, Entra Agent ID Certificates & SIL-3 Hardware Interlock Keys
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${take(uniqueString(resourceGroup().id), 10)}-3ms'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}

// 6. Config Metadata Outputs for 6N 3MS/4MS Distillation & ULK PECVD PINN-MPC Agent Harness
output aksClusterName string = aksCluster.name
output kataRuntimeClass string = 'kata-mshv-vm-isolation'
output maxHydrolysableChlorideLimitPpmv string = maxHydrolysableChloridePpmv
output maxAlkaneCoBoilerLimitPpmv string = maxAlkaneCoBoilerPpmv
output maxHmdsoSiloxaneLimitPpmv string = maxHmdsoSiloxanePpmv
output lelTripThresholdLimitPct string = lelTripThresholdPct
output safetyInterlockStandard string = 'SEMI-C3-NFPA55-NFPA68-IEC61511-SIL3-2oo3-Flame-Arrestor-Heated-Line-DBB'
