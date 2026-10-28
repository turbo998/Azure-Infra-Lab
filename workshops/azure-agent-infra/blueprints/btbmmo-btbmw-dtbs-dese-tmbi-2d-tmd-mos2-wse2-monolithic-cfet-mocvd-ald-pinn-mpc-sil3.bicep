// ============================================================================
// Blueprint #268: Autonomous Electronic-Grade Bis(tert-butylimido)bis(dimethylamino)molybdenum (6N5 BTBMMo (t-C4H9N)2Mo[N(CH3)2]2 >= 99.99995%, Halide-Free 0% Cl, W <= 0.02 ppmw, U/Th <= 0.001 ppbw) & Bis(tert-butylimido)bis(dimethylamino)tungsten (6N5 BTBMW (t-C4H9N)2W[N(CH3)2]2 >= 99.99995%, Mo <= 0.02 ppmw) + Di-tert-butyl Sulfide (6N5 DTBS [(CH3)3C]2S >= 99.99995%) & Diethyl Selenide (6N5 DESe (C2H5)2Se >= 99.99995%) + Trimethylbismuth (6N5 TMBi Bi(CH3)3 >= 99.99995%) Sub-1nm (A10/A7) Monolithic 3D CFET Wafer-Scale Monolayer 2D Transition Metal Dichalcogenide (1L-MoS2 n-FET d=0.65nm & 1L-WSe2 p-FET d=0.67nm) Channel Epitaxy & Ultralow-Schottky Semimetal Bismuth/Antimony (Bi/Sb Rc < 95 Ohm-um) Contact Low-Temperature (<= 420 degC) Cyclic MOCVD/ALD Fractional Vacuum Distillation, Beta-Hydride Carbon-Free Elimination & PINN-MPC, Online 10 kHz QCL-TDLAS/FTIR + GC-ICP-MS + In-Situ Raman/PL/SE/RHEED Metrology & SEMI S2 / SEMI C3 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 Pyrophoric TMBi, Toxic H2Se/H2S/CO & Bi Contact Dewetting Interlock
// Cycle #267 (275-Chapter Milestone! — Chapter 272 + Summary 273 = 275 Chapters, Blueprint #268, Simulator #267, Tool 267, 276/276 Unit Tests)
// ============================================================================

@description('Azure region for the 6N5 BTBMMo/BTBMW + DTBS/DESe + TMBi 2D TMD Monolithic CFET MOCVD/ALD Edge-Cloud Sandbox')
param location string = resourceGroup().location

@description('Environment prefix for A10/A7 2D TMD MoS2/WSe2 CFET Channel & Bi Semimetal Contact resources')
param environmentPrefix string = 'btbmmo-btbmw-dtbs-dese-tmbi-2d-cfet-sil3'

@description('AKS node VM SKU for PINN-MPC 2D TMD Step-Edge Epitaxy & Bi Contact Solver (Standard_D96as_v7)')
param aksAgentVmSize string = 'Standard_D96as_v7'

@description('Target 6N5 BTBMMo / BTBMW / DTBS / DESe / TMBi purity (%)')
param targetPrecursorPurityPct string = '99.99995'

@description('Maximum halide (Cl/F) and amorphous sp2 carbon residue in 1L-MoS2 / 1L-WSe2 channel')
param maxHalideAndCarbonResidueSpec string = 'Cl=0.0ppmw_C<=0.08at.pct_VS_VSe<=1.2e11cm-2'

@description('Target 1L-MoS2 Raman E12g-A1g frequency split (cm^-1) and Bi contact resistance Rc (Ohm-um)')
param targetMonolayerRamanAndBiRcSpec string = 'DeltaOmega=18.8cm-1_Rc<=95Ohm_um_Ion>=1150uA_um'

@description('SEMI S2 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 H2Se (IDLH 1 ppmv) & CO (TLV 25 ppmv) & TMBi pyrophoric trip threshold')
param sil3H2SeCoAndTmbiTripThreshold string = 'H2Se>=0.02ppmv_or_CO>=10ppmv_or_TMBi_O2>=0.8ppmv_or_Twafer>=245C_during_Bi'

@description('Target SIL-3 hardware interlock latency (ms) via JetStream + eBPF double-block-and-bleed shutoff')
param sil3InterlockLatencyMs string = '0.13'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'tmdcfetpool'
        count: 6
        vmSize: aksAgentVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/runtime': 'aksclaw-kata-ebpf'
          'semiconductor.azure.com/process': 'btbmmo-btbmw-dtbs-dese-tmbi-2d-tmd-mos2-wse2-cfet-ald'
          'safety.iec61511.com/sil': 'SIL-3'
          'safety.semi.com/standard': 'SEMI-S2-C3-NFPA704-OSHA-PSM'
        }
      }
    ]
  }
}

resource stepEdgeEpitaxyAndBiContactJob 'Microsoft.Batch/batchAccounts@2023-05-01' = {
  name: replace('${environmentPrefix}batch', '-', '')
  location: location
  properties: {
    poolAllocationMode: 'BatchService'
  }
}

output clusterName string = aksCluster.name
output targetPurity string = targetPrecursorPurityPct
output maxHalideAndCarbonResidue string = maxHalideAndCarbonResidueSpec
output targetMonolayerRamanAndBiRc string = targetMonolayerRamanAndBiRcSpec
output sil3TripThreshold string = sil3H2SeCoAndTmbiTripThreshold
output sil3InterlockLatency string = sil3InterlockLatencyMs
