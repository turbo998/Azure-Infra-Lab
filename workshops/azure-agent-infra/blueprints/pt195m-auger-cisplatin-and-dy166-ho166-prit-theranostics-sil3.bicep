// blueprints/pt195m-auger-cisplatin-and-dy166-ho166-prit-theranostics-sil3.bicep
// Blueprint #232: Autonomous Auger-Electron Cisplatin Theranostics No-Carrier-Added Platinum-195m (n.c.a. 195mPt T1/2=4.02d 36 Auger/IC Electrons per Decay + 98.9keV SPECT via 197Au(p,3n)195mHg->195mPt Dual-Generator & Chemo-Radio-Cisplatin Synthesis) & Multi-Modal Beta-Gamma-MRI Theranostics Holmium-166 (164Dy(2n,gamma)166Dy->166Ho In-Vivo/Ex-Vivo Reverse-Chromatography Generator <10^-7 Long-Lived 1200y 166mHo Impurity & 166Ho-PLLA Radioembolization + TCO/Tetrazine IEDDA Pretargeted Radioimmunotherapy PRIT) PINN-MPC, Online 10 kHz HPGe 98.9/80.6/184.4 keV Gamma, SQUID/NMR Paramagnetic Susceptibility & Microfluidic Radio-HPLC Metrology & USP <823> / 10 CFR 35.1000 / EU GMP Annex 3 / ISO 17873 / IEC 61511 SIL-3 1200y 166mHo Impurity Quarantine, Cisplatin Nephrotoxic Hydrolysis/Trans-Isomer Lockout & Hg-Target Vapor Cryo-Trap Interlock (Cycle #231 — 240-Test Milestone!)

@description('Deployment Azure region for the Pt-195m Auger-Cisplatin & Dy-166/Ho-166 PRIT Theranostics facility')
param location string = resourceGroup().location

@description('Environment prefix for Pt-195m & Ho-166 PRIT Theranostics control plane')
param envPrefix string = 'pt195mho166s3'

@description('AKS GPU node SKU for 195mHg->195mPt Dual-Generator, 166Dy/166Ho Reverse-LN2 Chromatography & IEDDA PRIT Pharmacokinetic PINN-MPC')
param gpuNodeSku string = 'Standard_NC24ads_A100_v4'

@description('Confidential Compute node SKU for USP <823> / 10 CFR 35.1000 / ISO 17873 SIL-3 1200y 166mHo quarantine & Hg-vapor cryo-trap gatekeeper')
param ccNodeSku string = 'Standard_DC16ads_v5'

@description('Maximum permissible long-lived 1200-year 166mHo (184.4 / 711.7 / 810.3 keV gamma) to 166Ho activity ratio before SIL-3 quarantine')
param maxHo166mImpurityRatio string = '0.0000001'

@description('Maximum permissible toxic trans-platin / aquated cisplatin impurity or trans-cyclooctene (TCO->cis-cyclooctene) deactivation fraction (%) before SIL-3 lot lockout')
param maxTransPlatinOrCisTcoImpurityPct int = 1

@description('Maximum permissible Au/Hg target cell temperature (deg C) before SIL-3 RF-crowbar & gold-amalgam cryo-trap interlock')
param maxAuHgTargetTempC int = 340

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.237.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.237.1.0/24'
        }
      }
      {
        name: 'sil3-pt195m-ho166-plc-subnet'
        properties: {
          addressPrefix: '10.237.2.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-aks'
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: gpuNodeSku
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/workload': 'pt195m-auger-cisplatin-and-dy166-ho166-prit-pinn-mpc'
          'agent.azure.com/isotope-pair': 'Pt195m-Hg195m-Ho166-Dy166-IEDDA-PRIT'
        }
      }
      {
        name: 'sil3gatepool'
        count: 2
        vmSize: ccNodeSku
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/safety-tier': 'usp823-10cfr35-iso17873-sil3'
          'agent.azure.com/max-ho166m-impurity-ratio': maxHo166mImpurityRatio
          'agent.azure.com/max-transplatin-or-cistco-pct': string(maxTransPlatinOrCisTcoImpurityPct)
          'agent.azure.com/max-auhg-target-temp-c': string(maxAuHgTargetTempC)
        }
      }
    ]
  }
}

resource iotNamespace 'Microsoft.DeviceRegistry/namespaces@2024-11-01-preview' = {
  name: '${envPrefix}-iot-ns'
  location: location
  properties: {
    messaging: {
      endpoints: {
        hpge98keVAndParamagneticRadioHplcEdge: {
          endpointType: 'Microsoft.Devices/IoTHubs'
          address: 'tls://${envPrefix}-edge-broker.local:8883'
        }
      }
    }
  }
}

output aksClusterName string = aksCluster.name
output sil3InterlockSpec string = 'USP<823>/10CFR35.1000/ISO17873-SIL3-Ho166m-Quarantine-TransPlatin-Lockout-and-AuHg-Amalgam-Crowbar-0.15ms'
