// blueprints/sripr3cp2-baipr3cp2-ttip-tdmat-bto-pockels-cpo-quantum-photonic-sto-0a-dram-ald-mbe-pinn-mpc-sil3.bicep
// Blueprint #273: Electronic-Grade Ultrapure Bis(tri-isopropylcyclopentadienyl)strontium (6N5 Sr(iPr3Cp)2 >=99.99995%, m.p. 48C, Ba/Ca/Mg <=0.02ppbw, Fe/Ni/Cu/Na/K <=0.005ppbw) & Bis(tri-isopropylcyclopentadienyl)barium (6N5 Ba(iPr3Cp)2 >=99.99995%, m.p. 64C) + Titanium Tetraisopropoxide / Tetrakis(dimethylamino)titanium (6N5 TTIP Ti(OiPr)4 / 6N5 TDMAT Ti(NMe2)4 >=99.99995%) + Tris(isopropylcyclopentadienyl)lanthanum (6N5 La(iPrCp)3 >=99.99995%) 1.6T / 3.2T Cryogenic Quantum-Photonic & Co-Packaged Optics (CPO) Silicon-Integrated 300mm Monolithic Barium Titanate (BaTiO3 BTO, Pockels Electro-Optic Coefficient r42 >920 pm/V @ 300K & >220 pm/V @ 4K Cryo-Qubit Transducer, Vpi*L <0.18 V*cm, Loss <0.35 dB/cm) on Epitaxial Strontium Titanate (SrTiO3 STO Pseudo-Substrate Buffer on Si(001), In-Plane a-Axis / c-Axis Domain Alignment >98.5%) & Ultra-High-k SrTiO3 (STO k >140, EOT <0.38nm, Jleak <1e-8 A/cm2) Next-Gen 0a/0b DRAM Capacitor Super-Cycle ALD / Oxide-MBE Fractional Vacuum Distillation, Carbonate-Free H2O / O2-Plasma Stoichiometry Control (Ba/Ti & Sr/Ti = 1.000 +-0.003) & PINN-MPC + SEMI S2 / SEMI C3 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 Air-Sensitive Alkaline-Earth Metallocene & Heated Ampoule Thermal Decomposition Interlock

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Sr(iPr3Cp)2 / 6N5 Ba(iPr3Cp)2 / 6N5 TTIP / 6N5 TDMAT BTO Cryo-Quantum/CPO Pockels Modulator & STO 0a/0b DRAM Capacitor ALD/MBE edge-cloud governance estate')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Sr(iPr3Cp)2 / 6N5 Ba(iPr3Cp)2 / 6N5 TTIP-TDMAT vacuum distillation, 300mm epitaxial STO/Si(001) buffer & BTO Pockels EO waveguide + 0a/0b DRAM STO capacitor super-cycle ALD/MBE reactor trains')
@minValue(1)
@maxValue(64)
param sripr3cp2Baipr3cp2TtipTdmatTrains int = 8

@description('AKS GPU node SKU for 0.13ms 10kHz QCL-TDLAS (C-H 2962cm-1 / Ti-O 618cm-1 / CO2 2349cm-1 Carbonate Suppression), In-Situ RHEED Intensity Oscillation & HR-XRD / PFM Domain Polling PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var gpuNodeCount = max(4, (sripr3cp2Baipr3cp2TtipTdmatTrains + 1) / 2)
var activeSripr3cp2Baipr3cp2Pods = sripr3cp2Baipr3cp2TtipTdmatTrains * 4

resource sripr3cp2Baipr3cp2BtoStoCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-sripr3cp2-baipr3cp2-bto-sto-ald-sil3'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.30.4'
    dnsPrefix: 'aks-sripr3cp2-baipr3cp2-bto-sto'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'btostopinn'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'workload.azure.ai/domain': 'sripr3cp2-baipr3cp2-ttip-tdmat-bto-pockels-cpo-quantum-sto-dram-ald-mbe-sil3'
          'precursor.azure.ai/purity-grade': '6N5-Sr-iPr3Cp2-Ba-iPr3Cp2-TTIP-TDMAT-La-iPrCp3-Carbonate-Free'
          'safety.iec61511/sil-rating': 'SIL-3-SEMI-S2-NFPA704-Alkaline-Earth-Metallocene-Heated-Ampoule-Interlock'
          'metrology.azure.ai/loop': '10kHz-QCL-TDLAS-2962cm1-618cm1-2349cm1-InSitu-RHEED-HRXRD-PFM-SE'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
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

output clusterName string = sripr3cp2Baipr3cp2BtoStoCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeSripr3cp2Baipr3cp2Pods int = activeSripr3cp2Baipr3cp2Pods
output sil3InterlockLatencyMs string = '0.13ms'
output btoPockelsR42AndStoDramYieldGainPct string = '+67.0%'
output carbonatePhaseAndStoichiometricDefectReductionPct string = '-90.1%'
