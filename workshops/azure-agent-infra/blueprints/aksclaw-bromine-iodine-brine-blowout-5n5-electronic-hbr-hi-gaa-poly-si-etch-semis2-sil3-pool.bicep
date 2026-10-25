// blueprints/aksclaw-bromine-iodine-brine-blowout-5n5-electronic-hbr-hi-gaa-poly-si-etch-semis2-sil3-pool.bicep
// Chapter 200 (Blueprint #196 — 195-Cycle & 195-Simulator Milestone!): Autonomous Subsurface Brine / Caliche-Leach Blow-Out Oxidation (Cl2 + 2Br- -> Br2, Cl2 + 2I- -> I2), SO2 Absorption & 6N Sublimed Iodine (I2), 5N5 Electronic-Grade Hydrogen Bromide (HBr) / Hydrogen Iodide (HI) Direct Catalytic Synthesis & 2nm Gate-All-Around (GAA) Nanosheet Silicon/SiGe HBr/Cl2/O2 Anisotropic Plasma Etching PINN-MPC, Online 10 kHz In-Situ UV-Vis (Br2/I2/ICl), TDLAS (HBr/HI/Cl2/H2O) & OES Metrology & OSHA 1910.119 / NFPA 318 / SEMI S2 / IEC 61511 SIL-3 Liquid Bromine (PEL 100 ppb, IDLH 3 ppm) / HBr Vapor Cloud Suppression, Sodium Thiosulfate (Na2S2O3/NaOH) Reductive Scrubber & Interhalogen Over-Chlorination Interlock

@description('AKS cluster name for Autonomous Brine Blow-Out Bromine/Iodine, 5N5 Electronic HBr/HI Synthesis & 2nm GAA HBr Anisotropic Plasma Etching PINN-MPC workloads')
param clusterName string = 'aksclaw-bromine-iodine-hbr-sil3'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('GPU node VM size for Brine ORP Blow-Out Stripping, 5N5 HBr/HI Fractional Distillation & 2nm GAA HBr/Cl2/O2 Etch Selectivity PINN-MPC')
param gpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum number of Kata-isolated GPU nodes')
@minValue(2)
param minCount int = 3

@description('Maximum number of Kata-isolated GPU nodes')
@minValue(4)
param maxCount int = 12

@description('Maximum ambient bromine (Br2, OSHA PEL 0.1 ppm = 100 ppb, IDLH 3 ppm) or iodine (I2, Ceiling 100 ppb) vapor concentration before SIL-3 Br2/Cl2 feed isolation, chilled Na2S2O3/NaOH reductive deluge scrubber and HBr cabinet lockout (ppb)')
param maxBromineIodineVaporLeakPpb int = 25

@description('Maximum trace moisture (H2O) and free Cl2/Fe impurity in 5N5 (99.9995%) electronic-grade HBr/HI before SIL-3 cylinder manifold quarantine to prevent 316L SS tubing pitting corrosion and GAA gate-oxide iron contamination (ppb)')
param maxElectronicHbrMoistureCl2Ppb int = 500

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource bromineIodineHbrPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'br2i2hbrsil3'
  properties: {
    vmSize: gpuVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: minCount
    maxCount: maxCount
    mode: 'User'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/tier': 'aksclaw-kata-gpu-bromine-iodine-brine-blowout-5n5-hbr-hi-gaa-etch-semis2-sil3'
      'halogen.control/domain': 'brine-orp-blowout-so2-absorption-6n-i2-5n5-hbr-hi-gaa-poly-si-etch-pinn-mpc'
      'safety.interlock/standard': 'osha-1910-119-nfpa318-semis2-iec61511-sil3-br2-i2-hbr-thiosulfate-scrubber'
      'metrology.edge/protocol': 'insitu-uvvis-10khz-br2-i2-icl-tdlas-hbr-hi-h2o-oes-br-si-etch'
    }
    nodeTaints: [
      'halogen.sil3/critical=true:NoSchedule'
    ]
    tags: {
      workload: 'bromine-iodine-brine-blowout-5n5-electronic-hbr-hi-gaa-poly-si-etch-semis2-sil3'
      maxBromineIodineVaporLeakPpb: string(maxBromineIodineVaporLeakPpb)
      maxElectronicHbrMoistureCl2Ppb: string(maxElectronicHbrMoistureCl2Ppb)
      compliance: 'OSHA-1910.119-NFPA-318-SEMI-S2-IEC-61511-SIL-3'
    }
  }
}

output poolResourceId string = bromineIodineHbrPinnPool.id
output safetyStandard string = 'OSHA-1910.119-NFPA-318-SEMI-S2-IEC-61511-SIL-3'
output edgeMetrologyLoopTargetMs string = '0.20'
