// ============================================================================
// Blueprint #208: AKSClaw Thulium (Tm, Z=69), Ytterbium (Yb, Z=70) & Lutetium
// (Lu, Z=71) Heavy Rare-Earth Terminal Triad Extraction & 5N5 Vacuum Sublimation,
// kW-Class 1,064 nm Yb3+ Fiber Laser & 171Yb+ Quantum Ion-Trap Clock Isotope,
// 1.94 um Tm:Fiber Cross-Relaxation Laser, 2,150 degC Czochralski LYSO:Ce TOF-PET
// Scintillator Boule Growth & Carrier-Free 177Lu Radioligand Therapy PINN-MPC &
// 10 CFR 35 / NFPA 484 / SEMI S2 / ANSI Z136.1 / IEC 61511 SIL-3 Pool
// ============================================================================
// Target Workload:
//   1. Heavy Rare-Earth Terminal Triad (Tm/Yb/Lu, beta_Yb/Tm = 2.15, beta_Lu/Yb = 1.48)
//      P507/P229 High-Pressure Chelating Chromatography & Selective Lanthanothermic
//      Vacuum Sublimation of Divalent Ytterbium (P_Yb = 100 Pa @ 730 degC vs Lu
//      P_Lu < 10^-6 Pa) & 5N5 Vacuum Distillation of Thulium & Lutetium
//   2. kW-Class 1,064 nm Yb3+/Al3+/P5+/Ce3+ Co-Doped Pedestal Double-Clad Fiber
//      Preform MCVD/Chelate Vapor Deposition (Suppressing Yb2+/Al-OHCA Color-Center
//      Photodarkening & Transverse Mode Instability TMI) + 171Yb+ (I=1/2) Laser-Avlis
//      & Calutron Isotope Enrichment (>= 99.6% 171Yb for Trapped-Ion Quantum Computers)
//   3. 1.94 um Tm3+:Silica & Tm:YAG Eye-Safe / Medical Thulium Fiber Laser (TFL)
//      Two-for-One Cross-Relaxation (3H4 + 3H6 -> 2 x 3F4 @ >= 3.2 wt% Tm2O3,
//      Quantum Efficiency > 180% Pumped at 793 nm) & 170Tm NDT Gamma Source
//   4. 2,150 degC Iridium-Crucible Czochralski Growth of Ø100 mm Lu1.8Y0.2SiO5:Ce3+
//      (LYSO:Ce) Single-Crystal Scintillator Boules (rho = 7.40 g/cm3, Zeff = 66,
//      32,000 ph/MeV, tau = 40 ns, 511 keV TOF-PET Coincidence Timing CTR <= 92 ps)
//   5. Carrier-Free No-Carrier-Added (n.c.a.) 177Lu (t_1/2 = 6.647 d) Radioligand
//      Cancer Therapy Production via Enriched 176Yb(n,gamma)177Yb -> 177Lu Automated
//      LN-Resin Chromatographic Separation (Yb/Lu Decontamination Factor >= 10^6,
//      Zero Long-Lived 177mLu t_1/2 = 160.4 d Impurity for PSMA-617 / DOTATATE)
//   6. 10 CFR 35 / NFPA 484 / SEMI S2 / ANSI Z136.1 / IEC 61511 SIL-3 Pyrophoric Yb/Tm
//      Sublimation Condensate Passivation, 2,150 degC Ir-Crucible LYSO Melt-Spill
//      Containment & 177Lu/170Tm Hot-Cell Negative-Pressure Interlock (0.23 ms)
// ============================================================================

@description('Azure region for the AKSClaw Tm/Yb/Lu Heavy Rare-Earth Laser, LYSO:Ce TOF-PET & 177Lu Radioligand Edge-Cloud Cluster')
param location string = resourceGroup().location

@description('Environment identifier for the heavy rare-earth photonics, scintillator & nuclear medicine control plane')
@allowed([
  'prod-tm-yb-lu-lyso-177lu-sil3'
  'staging-tm-yb-lu-digital-twin'
  'lab-czochralski-radioligand-bench'
])
param environment string = 'prod-tm-yb-lu-lyso-177lu-sil3'

@description('AKS GPU node VM size for 10 kHz TIMS/ICP-MS, 511 keV CTR TOF-PET & PINN-MPC inference')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Number of GPU nodes in the dedicated Tm/Yb/Lu PINN-MPC & metrology pool')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 4

@description('Number of parallel Tm/Yb/Lu sublimation, Yb/Tm fiber preform, LYSO:Ce Czochralski & 177Lu separation lines')
@minValue(1)
@maxValue(64)
param productionLines int = 8

@description('Maximum allowed 511 keV LYSO:Ce Time-of-Flight PET coincidence timing resolution CTR (picoseconds)')
param maxLysoCtrPicoseconds int = 92

@description('Maximum allowed 10 CFR 35 / NFPA 484 / SEMI S2 / SIL-3 hardware interlock response latency (microseconds)')
param maxSil3InterlockLatencyUs int = 230

var clusterName = 'aks-aksclaw-tm-yb-lu-${environment}'
var nodePoolName = 'tmyblusil3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource tmYbLuGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: nodePoolName
  properties: {
    vmSize: gpuNodeVmSize
    count: gpuNodeCount
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-domain': 'thulium-ytterbium-lutetium-yb-tm-fiber-laser-lyso-pet-177lu-radioligand'
      'aksclaw.io/pinn-mpc-engine': 'yb-sublimation-yb-tm-fiber-photodarkening-czochralski-lyso-nca-177lu'
      'aksclaw.io/metrology-loop': '10khz-tims-icpms-511kev-ctr-488nm-photodarkening-hpge'
      'aksclaw.io/safety-interlock': '10cfr35-nfpa484-semis2-ansiz136-iec61511-sil3'
      'aksclaw.io/production-lines': string(productionLines)
    }
    nodeTaints: [
      'aksclaw.io/tm-yb-lu-sil3=dedicated:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output clusterResourceId string = aksCluster.id
output gpuNodePoolName string = tmYbLuGpuPool.name
output configuredProductionLines int = productionLines
output targetMaxLysoCtrPicoseconds int = maxLysoCtrPicoseconds
output targetSil3InterlockLatencyUs int = maxSil3InterlockLatencyUs
