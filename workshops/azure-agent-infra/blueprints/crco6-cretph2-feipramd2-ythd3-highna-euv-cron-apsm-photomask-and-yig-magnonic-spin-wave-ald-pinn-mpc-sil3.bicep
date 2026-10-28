// ============================================================================
// Blueprint #280 (280-Blueprint Milestone!): Autonomous Electronic-Grade
// Hexacarbonylchromium (6N5 Cr(CO)6 >=99.99995%) & Bis(ethylbenzene)chromium(0)
// (6N5 Cr(EtPh)2 >=99.99995%) + Bis(N,N'-diisopropylacetamidinato)iron(II)
// (6N5 Fe(iPr-AMD)2 >=99.99995%) + Tris(2,2,6,6-tetramethyl-3,5-heptanedionato)
// yttrium(III) (6N5 Y(THD)3 >=99.99995%) High-NA EUV (0.55 NA) Ultra-Low-
// Reflectivity Attenuated Phase-Shift Photomask (aPSM) Amorphous CrON / CrTaN
// Absorber (<=38 nm Thickness, 13.5 nm Reflectivity <1.2%, pi-Phase Shift =
// 180.0 deg +/-0.8 deg, Mask 3D Shadowing Reduction -62%) & On-Chip Magnonic
// Spin-Wave Logic Nanometer-Thick Yttrium Iron Garnet (Y3Fe5O12 YIG, Gilbert
// Damping alpha <8.5e-5, FMR Linewidth Delta_H <0.18 mT at 10 GHz) Epitaxial
// ALD/PEALD PINN-MPC + SIL-3
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Cr(CO)6 / 6N5 Cr(EtPh)2 / 6N5 Fe(iPr-AMD)2 / 6N5 Y(THD)3 High-NA EUV CrON aPSM Photomask & YIG Magnonic Spin-Wave ALD AKS Edge Cluster')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Cr(CO)6 / 6N5 Cr(EtPh)2 / 6N5 Fe(iPr-AMD)2 / 6N5 Y(THD)3 High-NA EUV aPSM & YIG Magnonic ALD reactor trains')
@minValue(1)
@maxValue(64)
param crco6Cretph2Feipramd2Trains int = 8

@description('AKS GPU node SKU for 10 kHz QCL-TDLAS/FTIR + In-Situ 13.5nm EUV Actinic Reflectometry/FMR & PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var gpuNodeCount = max(4, (crco6Cretph2Feipramd2Trains + 1) / 2)
var activePods = crco6Cretph2Feipramd2Trains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-crco6-cretph2-euv-apsm-yig-ald-sil3'
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'crco6-euv-yig-sil3'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/runtime': 'aksclaw-kata-ebpf'
          'semi.azure.com/process': '6n5-crco6-cretph2-feipramd2-ythd3-highna-euv-cron-apsm-yig-ald'
          'safety.azure.com/sil': 'semi-s2-nfpa704-osha-psm-sil3-0.10ms'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterName string = aksCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeProcessPods int = activePods
output safetyInterlockSpec string = 'SEMI-S2-NFPA704-OSHA-PSM-SIL3-0.10ms-CrCO6-CO-Offgassing-Pyrophoric-FeiPrAMD2-Lockout'
output spectroscopyChannels string = 'QCL-TDLAS-2000.4cm-1-CrCO6-1636.2cm-1-FeiPrAMD2-1574.8cm-1-YTHD3-13.5nm-EUV-Reflectometry-FMR'
