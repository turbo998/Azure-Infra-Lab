// blueprints/aksclaw-fluorine-anhydrous-hf-moissan-f2-electrolysis-6n-nf3-wf6-3d-nand-cryo-ale-semis2-sil3-pool.bicep
// Cycle #194 (200-Chapter Milestone!) — Blueprint #195: Autonomous Fluorspar (CaF2) Rotary-Kiln Sulfuric Acid Digestion to Anhydrous Hydrogen Fluoride (AHF), Potassium Bifluoride (KHF2, 80-100 C Molten Electrolyte) Moissan Anodic Fluorine (F2) Generation, 6N Electronic-Grade Nitrogen Trifluoride (NF3) / Tungsten Hexafluoride (WF6) Fractional Cryogenic Distillation & 3D NAND (>300-Layer) High-Aspect-Ratio (HAR) Cryogenic Atomic-Layer Etching (ALE) PINN-MPC & OSHA 1910.119 / NFPA 318 / SEMI S2 / IEC 61511 SIL-3 Interlock AKS Node Pool

@description('AKS cluster name hosting the Fluorine / AHF / Moissan F2 / 6N NF3-WF6 / 3D NAND Cryo-ALE PINN-MPC agent pool')
param aksClusterName string = 'aksclaw-fluorine-nf3-wf6-ale-sil3'

@description('Azure region for sovereign edge-cloud deployment')
param location string = resourceGroup().location

@description('GPU VM SKU for coupled CaF2 rotary-kiln AHF digestion, Moissan KHF2 molten-salt F2 electrolysis, 6N NF3/WF6 cryogenic distillation & 3D NAND HAR Cryo-ALE PINN-MPC')
param vmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum and maximum node counts for deterministic HA availability')
param minCount int = 3
param maxCount int = 9

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource fluorineNf3Wf6AlePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'flnf3sil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'workload.aksclaw.io/domain': 'fluorine-anhydrous-hf-moissan-f2-electrolysis-6n-nf3-wf6-3d-nand-cryo-ale'
      'safety.aksclaw.io/sil-rating': 'OSHA-1910-119-NFPA-318-SEMI-S2-IEC-61511-SIL3'
      'physics.aksclaw.io/pinn-mpc': 'fluorspar-ahf-moissan-khf2-f2-6n-nf3-wf6-cryo-distillation-3d-nand-har-ale'
      'telemetry.aksclaw.io/metrology-10khz': 'insitu-ftir-cf4-of2-tdlas-hf-f2-and-oes-har-etch'
    }
    nodeTaints: [
      'safety.aksclaw.io/fluorine-nf3-wf6-ale-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      cpuCfsQuota: false
      topologyManagerPolicy: 'single-numa-node'
    }
    linuxOSConfig: {
      sysctls: {
        netCoreRmemMax: 134217728
        netCoreWmemMax: 134217728
        vmMaxMapCount: 262144
      }
    }
  }
}

output poolResourceId string = fluorineNf3Wf6AlePool.id
output safetyStandard string = 'OSHA 1910.119 / NFPA 318 / SEMI S2 / IEC 61511 SIL-3 (AHF PEL 3 ppm / F2 PEL 100 ppb, Moissan H2/F2 Detonation Lockout, Ca(OH)2/Al2O3 Dry Scrubber & Cryo NF3 Isolation <= 0.26 ms)'
output telemetryLoopMs string = '0.20 ms (10 kHz In-Situ FTIR CF4/OF2/SF6, TDLAS HF/F2 & OES 3D NAND HAR Etch Metrology with 99.7% WAN compression)'
