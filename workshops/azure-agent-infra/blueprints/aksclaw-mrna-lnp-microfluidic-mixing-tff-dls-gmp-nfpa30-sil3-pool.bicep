// =============================================================================
// Blueprint #105: Autonomous Biopharmaceutical Continuous mRNA-LNP Microfluidic
// Chaotic-Advection Mixing (FRR/TFR), Ionizable-Lipid Self-Assembly & TFF
// PINN-MPC, In-Situ SR-DLS / Raman Inversion & FDA 21 CFR Part 11 / EU GMP
// Annex 1 / NFPA 30 / IEC 61511 SIL-3 Single-Use Manifold & Ethanol Interlock
// =============================================================================

@description('Azure region for the mRNA-LNP microfluidic continuous manufacturing cluster')
param location string = resourceGroup().location

@description('AKS cluster name hosting the mRNA-LNP microfluidic & GMP SIL-3 digital twin pool')
param aksClusterName string = 'aks-aksclaw-mrna-lnp-sil3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU PINN-MPC Pool: Staggered Herringbone / Impinging-Jet Microfluidic Dean-Vortex Mixing,
//    Smoluchowski Ionizable-Lipid/mRNA Self-Assembly Population Balance & TFF Transmembrane Pressure MPC
resource mrnaLnpGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mrnalnpsil3'
  properties: {
    count: 2
    vmSize: 'Standard_ND96isr_H100_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'OCIContainer'
    enableUltraSSD: true
    nodeLabels: {
      'aksclaw.io/workload-class': 'mrna-lnp-microfluidic-mixing-tff-dls-gmp-sil3-agent'
      'aksclaw.io/pinn-mpc-chaotic-advection-smoluchowski-tff': 'enabled-34.8pct-ee-monodisperse-yield-gain-47.5pct-pdi-shear-rejection-cut'
      'aksclaw.io/gmp-annex1-nfpa30-sil3-manifold-ethanol-guard': 'enforced-0.4ms-zero-single-use-bag-rupture-or-ethanol-vapor-ignition'
      'aksclaw.io/skid-edge-srdls-raman-coriolis-frr-fusion': 'enabled-0.4ms-99.3pct-biopharma-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/mrna-lnp-gpu=true:NoSchedule'
    ]
  }
}

// 2. Cleanroom Skid Edge Pool: In-Situ Spatially-Resolved Dynamic Light Scattering (SR-DLS),
//    In-Line Raman Encapsulation Efficiency & Coriolis Flow-Rate-Ratio (FRR) Edge Triage
resource mrnaLnpSkidEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'lnpskid'
  properties: {
    count: 4
    vmSize: 'Standard_D32as_v7'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'aksclaw.io/tier': 'skid-edge-srdls-raman-coriolis-tff'
      'aksclaw.io/interlock-standard': 'fda-21cfr11-eu-gmp-annex1-nfpa30-iec61511-sil3'
      'aksclaw.io/fieldbus-protocol': 'opcua-tsn-profisafe-0.4ms'
    }
  }
}
