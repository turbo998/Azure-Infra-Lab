// Blueprint #154: Autonomous Semiconductor EUV Photomask Blank (40-Bilayer Mo/Si Ion-Beam Deposition IBD & TaBN/Ru ICP-RIE Etch),
// 50 keV 262,144-Beam Multi-Beam Mask Writer (MBMW) & CNT EUV Pellicle Pool, Coulomb Space-Charge, Resist Heating & 3D-M3D PEC PINN-MPC,
// Online 50 kHz Actinic 13.5 nm AIMS / APMI / Heterodyne Interferometer Metrology & SEMI S2 / SEMI P37 / ISO 14644-1 Class 1 / IEC 61508 SIL-3 Interlock (Chapter 158)
targetScope = 'resourceGroup'

@description('Azure region for the EUV photomask MBMW & actinic AIMS edge-cloud pool')
param location string = resourceGroup().location

@description('Environment tier for the EUV photomask MBMW control cluster')
@allowed([
  'prod'
  'staging'
])
param environment string = 'prod'

@description('Number of 50 keV MBMW electron-beam writers, IBD Mo/Si coaters, and actinic AIMS bays supervised')
@minValue(1)
@maxValue(64)
param mbmwPhotomaskBays int = 8

@description('Enable hardware-wired SEMI S2 / SEMI P37 / ISO 14644-1 Class 1 / IEC 61508 SIL-3 50 kV arc crowbar, UHV gate valve & halogen etch gas interlock')
param enableSemiS2P37Sil3PhotomaskInterlock bool = true

var clusterName = 'aks-euv-photomask-mbmw-sil3-${environment}'
var gpuNodeCount = max(2, (mbmwPhotomaskBays + 3) / 4)

resource photomaskVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-euv-photomask-mbmw-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.254.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-pinn-mpc'
        properties: {
          addressPrefix: '10.254.1.0/24'
        }
      }
      {
        name: 'snet-actinic-aims-interferometer-edge'
        properties: {
          addressPrefix: '10.254.2.0/24'
        }
      }
    ]
  }
}

resource photomaskAks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'euv-photomask-mbmw-eb-writer-actinic-aims-pellicle-sil3'
    chapter: '158'
    blueprint: '154'
    safetyStandard: 'SEMI-S2-SEMI-P37-ISO14644-Class1-IEC61508-SIL3'
    mbmwPhotomaskBays: string(mbmwPhotomaskBays)
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'syspool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: photomaskVnet.properties.subnets[0].id
      }
      {
        name: 'pinnmpcpool'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        vnetSubnetID: photomaskVnet.properties.subnets[0].id
        nodeLabels: {
          'agent-infra/role': 'coulomb-space-charge-resist-heating-3d-m3d-pec-pinn-mpc'
          'agent-infra/metrology': '50khz-actinic-13p5nm-aims-apmi-heterodyne-interferometer-edge'
          'agent-infra/safety-sil3': string(enableSemiS2P37Sil3PhotomaskInterlock)
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      serviceCidr: '10.255.254.0/24'
      dnsServiceIP: '10.255.254.10'
    }
  }
}

output clusterResourceId string = photomaskAks.id
output supervisedMbmwPhotomaskBays int = mbmwPhotomaskBays
output semiS2P37Sil3InterlockActive bool = enableSemiS2P37Sil3PhotomaskInterlock
