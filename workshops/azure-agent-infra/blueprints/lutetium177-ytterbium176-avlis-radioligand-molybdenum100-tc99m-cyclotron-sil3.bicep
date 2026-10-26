// blueprints/lutetium177-ytterbium176-avlis-radioligand-molybdenum100-tc99m-cyclotron-sil3.bicep
// Cycle #220 (220-Cycle & 220-Simulator Milestone!) — Blueprint #221: Autonomous No-Carrier-Added Lutetium-177 (n.c.a. 177Lu >=99.9% PSMA/DOTATATE Radioligand Therapy via Enriched Ytterbium-176 176Yb >=99.6% AVLIS & Electro-Amalgamation/LN2-Chromatography Eliminating 160.4d 177mLu) & Enriched Molybdenum-100 (100Mo >=99.5% Cyclotron 99mTc Generator & Li2-100MoO4 0vbb Bolometer via MoF6 Centrifuge Cascade) PINN-MPC, Online 10 kHz HPGe Gamma Spectrometry, Fabry-Perot AVLIS & ICP-MS Metrology & USP <823> / EU GMP Annex 3 / 10 CFR 35 / CGA G-13 / IEC 61511 SIL-3 Hot-Cell Overpressure/Radiation Containment Lockout, 177mLu/Yb3+ Radiopharmaceutical Lot Quarantine & Toxic MoF6/HF Dry-Scrubber Isolation Interlock

@description('Deployment Azure region for the Lu-177 / Yb-176 AVLIS Radioligand & Mo-100 Cyclotron Isotope cluster')
param location string = resourceGroup().location

@description('Environment prefix for Lu-177 / Yb-176 & Mo-100 medical/quantum isotope resources')
param envPrefix string = 'lu177mo220'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Minimum PINN-MPC GPU nodes (Standard_NC24ads_A100_v4)')
param minGpuNodes int = 2

@description('Maximum PINN-MPC GPU nodes (Standard_NC24ads_A100_v4)')
param maxGpuNodes int = 12

@description('Deterministic SIL-3 real-time interlock node count (Standard_F16s_v2)')
param rtInterlockNodes int = 3

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.220.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.220.1.0/24'
        }
      }
      {
        name: 'lu177mo220s3-gpu-subnet'
        properties: {
          addressPrefix: '10.220.2.0/24'
        }
      }
      {
        name: 'lu177mo220rt-sil3-subnet'
        properties: {
          addressPrefix: '10.220.3.0/24'
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
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      serviceCidr: '10.220.128.0/18'
      dnsServiceIP: '10.220.128.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'lu177mo220s3'
        count: minGpuNodes
        minCount: minGpuNodes
        maxCount: maxGpuNodes
        enableAutoScaling: true
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/workload': 'lu177-yb176-avlis-radioligand-mo100-tc99m-pinn-mpc'
          'agent.azure.com/physics-domain': '1550k-yb176-avlis-electro-amalgamation-ln2-chrom-mof6-centrifuge'
          'agent.azure.com/metrology': '10khz-hpge-gamma-fabry-perot-avlis-icpms'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
      {
        name: 'lu177mo220rt'
        count: rtInterlockNodes
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/workload': 'usp823-eugmp-cfr35-cgag13-sil3-interlock'
          'agent.azure.com/interlock-budget-ms': '0.16'
          'agent.azure.com/isolation': 'kata-hv-sil3'
        }
        nodeTaints: [
          'sil3.interlock/realtime=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterName string = aks.name
output gpuPoolName string = 'lu177mo220s3'
output rtInterlockPoolName string = 'lu177mo220rt'
