// =============================================================================
// Blueprint #241 (Cycle #240 — 240-Simulator & 240-Tool Milestone!):
// Autonomous Electronic-Grade Bis(cyclopentadienyl)magnesium (6N Cp2Mg
// Mg(C5H5)2 >= 99.9999%, m.p. 176.0 C, v.p. 0.043 Torr @ 25 C) & Bis(ethyl-
// cyclopentadienyl)magnesium (6N (EtCp)2Mg Mg(C2H5C5H4)2 >= 99.9999%, Liquid
// m.p. -17.0 C, v.p. 0.055 Torr @ 40 C) + Bis(cyclopentadienyl)ruthenium /
// Bis(ethylcyclopentadienyl)ruthenium (6N RuCp2 / 6N Ru(EtCp)2 Ru(C5H5)2 /
// Ru(C2H5C5H4)2 >= 99.9999%, v.p. 0.12 Torr @ 85 C) p-GaN / AlGaN Deep-UV LED
// / Micro-LED Acceptor Activation (p >= 8.5e17 cm^-3) & 2nm / A14 BEOL
// Liner-Free Direct-Seeded Ruthenium (Ru rho <= 11.2 uOhm*cm @ 8 nm CD)
// MOCVD / O2-PEALD Multi-Stage Vacuum Sublimation & Fractional Vacuum
// Distillation, Grignard-Free Metallocene De-Halogenation (Cl/Br <= 0.05 ppmw,
// Si/Fe/Cr/Ni <= 0.5 pptw), Mg-H Passivation / 820 C N2 Thermal Activation &
// RuO4 Volatile Tetroxide Etchback Suppression (<= 0.02 ppmv) PINN-MPC, Online
// 10 kHz QCL-TDLAS (3105 cm^-1 eta5-Cp C-H / 880 cm^-1 RuO4 Asymmetric Stretch
// / 1985 cm^-1 Mg-H Passivation Complex) + ICP-MS/MS + SIMS / 4-Point Probe
// Metrology & SEMI S2 / NFPA 484 / OSHA 1910.1000 / IEC 61511 SIL-3 Pyrophoric
// Metallocene Air-Ingress & Toxic RuO4 Vapor Excursion (> 0.05 ppmv) Hard
// Interlock
// =============================================================================

@description('Azure region for the Electronic-Grade 6N Cp2Mg & 6N RuCp2/Ru(EtCp)2 p-GaN MOCVD & 2nm BEOL Ru PEALD Edge cluster')
param location string = resourceGroup().location

@description('Environment tier (prod-sil3, staging, lab)')
@allowed([
  'prod-sil3'
  'staging'
  'lab'
])
param environment string = 'prod-sil3'

@description('Number of parallel 6N Cp2Mg/RuCp2 vacuum sublimation, fractional distillation & p-GaN MOCVD / BEOL Ru PEALD trains (2-32)')
@minValue(2)
@maxValue(32)
param cp2mgRucp2Trains int = 8

@description('Kubernetes version for AKS hybrid cluster')
param kubernetesVersion string = '1.31.2'

var clusterName = 'aks-cp2mg-rucp2-pgan-ru-peald-${environment}'
var gpuNodeCount = max(2, (cp2mgRucp2Trains + 1) / 2)
var activeCp2mgRucp2Pods = cp2mgRucp2Trains * 4

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-cp2mg-rucp2-sil3-${environment}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-cp2mg-rucp2-sil3-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.241.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-system'
        properties: {
          addressPrefix: '10.241.1.0/24'
        }
      }
      {
        name: 'snet-aks-h100-pinn-mpc'
        properties: {
          addressPrefix: '10.241.2.0/24'
        }
      }
      {
        name: 'snet-sil3-profisafe-ethercat-interlock'
        properties: {
          addressPrefix: '10.241.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      outboundType: 'loadBalancer'
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
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'workload/type': 'cp2mg-rucp2-pgan-mocvd-beol-ru-peald-pinn-mpc'
          'metrology/qcl-tdlas-3105-880-1985cm1': 'enabled-10khz'
          'metrology/icp-ms-ms-sims-4pp': 'enabled-sub-0.5pptw'
          'safety/semi-s2-nfpa484-osha-sil3': 'enforced-0.14ms'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
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

output clusterName string = aksCluster.name
output gpuNodeCount int = gpuNodeCount
output activeCp2mgRucp2Pods int = activeCp2mgRucp2Pods
output targetElectronicGradePurity string = '>= 99.9999% (6N Cp2Mg & 6N RuCp2/Ru(EtCp)2, Si/Fe/Cr/Ni <= 0.5 pptw, Cl/Br <= 0.05 ppmw)'
output targetPganHoleAndBeolRuSpec string = 'p-GaN Active Hole p >= 8.5e17 cm^-3 (820 C N2 RTA) & 2nm BEOL Liner-Free Ru rho <= 11.2 uOhm*cm @ 8 nm CD'
output sil3InterlockLatencyMs string = '0.14 ms (SEMI S2 / NFPA 484 / OSHA 1910.1000 / IEC 61511 SIL-3 RuO4 > 0.05 ppmv & Pyrophoric Cp2Mg Air-Ingress Hard Interlock)'
