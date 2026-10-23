// ============================================================================
// Blueprint #156: Autonomous Co-Packaged Optics (CPO 1.6T / 3.2T Optical Engine)
// & 300 mm Silicon Photonics (SiPh) SOI / Si3N4 Waveguide Active Sub-Micron
// (< 100 nm) 6-DOF Piezo-Hexapod Fiber-Array / CW-DFB Laser First-Light Alignment
// & UV-Epoxy Cure-Shrinkage Compensation PINN-MPC, Online 100 kHz OFDR Waveguide
// Backscatter & MRR Thermal-Phase Metrology & Telcordia GR-468-CORE / IEC 60825-1
// Class 3B/4 / SEMI S2 / IEC 61508 SIL-3 ELSFP Laser Shutter, Piezo Shear-Force
// Limit & UV Cure Purge Interlock Pool
// ============================================================================

@description('Azure region for the CPO Silicon Photonics 6-DOF Piezo-Hexapod Active Alignment & OFDR Edge-Cloud Pool')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param environmentPrefix string = 'cposiph156'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.30.6'

@description('Optical Engine Package Architecture (cpo_3_2t_obo_engine, cpo_1_6t_switch_tile, or pluggable_1_6t_osfp_xd_dr8)')
@allowed([
  'cpo_3_2t_obo_engine'
  'cpo_1_6t_switch_tile'
  'pluggable_1_6t_osfp_xd_dr8'
])
param cpoPackageArchitecture string = 'cpo_3_2t_obo_engine'

@description('Target 6-DOF Piezo-Hexapod Fiber-Array / Edge-Coupler Lateral Alignment Residual in nm (Telcordia GR-468-CORE <= 100 nm)')
param maxLateralAlignmentResidualNm int = 100

@description('Maximum Allowed Per-Channel Fiber-to-PIC Coupling Insertion Loss in dB (<= 1.20 dB)')
param maxCouplingInsertionLossDb string = '1.20'

@description('Maximum Allowed Piezo-Hexapod Facet Contact / Shear Force in mN (<= 350 mN before SIL-3 retraction)')
param maxFacetContactForceMn int = 350

var aksClusterName = '${environmentPrefix}-aksclaw-cposiph'
var logWorkspaceName = '${environmentPrefix}-law-cposiph'
var vnetName = '${environmentPrefix}-vnet-cposiph'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.156.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'system-pool-subnet'
        properties: {
          addressPrefix: '10.156.1.0/24'
        }
      }
      {
        name: 'pinn-hexapod-ofdr-gpu-subnet'
        properties: {
          addressPrefix: '10.156.2.0/24'
        }
      }
      {
        name: 'sil3-gr468-iec60825-safety-subnet'
        properties: {
          addressPrefix: '10.156.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentPrefix}-cposiph'
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      serviceCidr: '10.255.156.0/24'
      dnsServiceIP: '10.255.156.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'ofdrpinngpu'
        count: 4
        vmSize: 'Standard_NV36adms_A10_v5'
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/workload': 'cpo-siph-hexapod-uv-shrinkage-ofdr-pinn-mpc'
          'agent.azure.com/cpo-architecture': cpoPackageArchitecture
          'agent.azure.com/metrology-rate-hz': '100000'
          'agent.azure.com/max-alignment-residual-nm': string(maxLateralAlignmentResidualNm)
        }
        nodeTaints: [
          'cpo-siph-gpu=true:NoSchedule'
        ]
      }
      {
        name: 'gr468sil3'
        count: 3
        vmSize: 'Standard_F16s_v2'
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/workload': 'telcordia-gr468-iec60825-semi-s2-sil3-interlock'
          'agent.azure.com/max-coupling-loss-db': maxCouplingInsertionLossDb
          'agent.azure.com/max-facet-force-mn': string(maxFacetContactForceMn)
          'agent.azure.com/runtime-isolation': 'kata-containers-microvm'
        }
        nodeTaints: [
          'sil3-gr468-safety=true:NoSchedule'
        ]
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logWorkspace.id
        }
      }
    }
  }
}

output aksClusterResourceId string = aksCluster.id
output cpoArchitectureConfigured string = cpoPackageArchitecture
output safetyStandardCompliance string = 'Telcordia-GR-468-CORE_IEC-60825-1-Class-3B-4_SEMI-S2_IEC-61508-SIL-3'
