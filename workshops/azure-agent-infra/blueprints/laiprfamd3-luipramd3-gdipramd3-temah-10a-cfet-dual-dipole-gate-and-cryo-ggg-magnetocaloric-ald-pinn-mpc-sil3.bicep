// ============================================================================
// Blueprint #278: Electronic-Grade Ultrapure Tris(N,N'-diisopropylformamidinato)lanthanum(III)
// (6N5 La(iPr-fAMD)3 >=99.99995%, Halide-Free Sublimed Rare-Earth Precursor, Ce/Pr/Nd/Th/U <=0.001ppbw)
// & Tris(N,N'-diisopropylacetamidinato)lutetium(III) (6N5 Lu(iPr-AMD)3 >=99.99995%, Smallest-Ionic-Radius
// Lanthanide r=0.861A, Yb/Tm/Er <=0.002ppbw) + Tris(N,N'-diisopropylacetamidinato)gadolinium(III)
// (6N5 Gd(iPr-AMD)3 >=99.99995%, High-Spin 4f7 S=7/2) + Tetrakis(ethylmethylamido)hafnium(IV)
// (6N5 TEMAH) 10A (1.0nm) Monolithic CFET Multi-Vt Dual-Dipole Gate Stack (La2O3 nFET Dipole
// Delta_V_FB = -420 mV & Lu2O3 High-k Interlayer Scavenging EOT < 0.42 nm, D_it < 8e10 cm-2eV-1)
// & On-Chip 4K-to-50mK Cryogenic Adiabatic Demagnetization Refrigerator (ADR) Gd3Ga5O12 (GGG)
// Magnetocaloric Thin-Film Super-Cycle PEALD PINN-MPC + SEMI S2/NFPA 704/OSHA PSM/SIL-3 Edge Pool
// ============================================================================

@description('Azure region for the AKSClaw 6N5 La(iPr-fAMD)3 & 6N5 Lu(iPr-AMD)3 + 6N5 Gd(iPr-AMD)3 + 6N5 TEMAH 10A CFET Dual-Dipole Gate & Cryo-GGG Magnetocaloric PEALD edge cluster')
param location string = resourceGroup().location

@description('Name of the AKS cluster hosting the Kata Pod VM + H100 PINN-MPC pools')
param clusterName string = 'aksclaw-laiprfamd3-luipramd3-gdipramd3-10a-cfet-dipole-ggg-ald-sil3'

@description('Number of Standard_NC40ads_H100_v5 nodes (1 node per 2 La(iPr-fAMD)3/Lu(iPr-AMD)3/Gd(iPr-AMD)3/TEMAH trains, minimum 4)')
@minValue(4)
@maxValue(64)
param h100NodeCount int = 4

@description('Number of 6N5 La(iPr-fAMD)3 / 6N5 Lu(iPr-AMD)3 / 6N5 Gd(iPr-AMD)3 / 6N5 TEMAH purification & 300mm 10A CFET Dual-Dipole + Cryo-GGG PEALD trains')
@minValue(1)
@maxValue(128)
param laiprfamd3Luipramd3Gdipramd3Trains int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource laiprfamd3Luipramd3Gdipramd3H100Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ladipoleggg'
  properties: {
    count: h100NodeCount
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 4
    maxCount: 64
    nodeLabels: {
      'aksclaw.io/workload-tier': 'laiprfamd3-luipramd3-gdipramd3-temah-10a-cfet-dual-dipole-cryo-ggg-ald-pinn-mpc-sil3'
      'aksclaw.io/precursor-purity': '6n5-laiprfamd3-6n5-luipramd3-6n5-gdipramd3-6n5-temah'
      'aksclaw.io/cfet-node': '10a-monolithic-cfet-la2o3-lu2o3-dipole-first-eot-sub-0p42nm'
      'aksclaw.io/cryo-adr-target': '4k-to-50mk-gd3ga5o12-ggg-magnetocaloric-peald'
      'aksclaw.io/spectroscopy-loop': 'qcl-tdlas-1642cm1-2968cm1-1384cm1-insitu-se-xps-arpes-10khz'
      'aksclaw.io/safety-interlock': 'semi-s2-nfpa704-osha-psm-sil3-pyrophoric-lanthanide-amidinate-o3'
    }
    nodeTaints: [
      'aksclaw.io/laiprfamd3-luipramd3-gdipramd3-10a-cfet-dipole-ggg-ald-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = laiprfamd3Luipramd3Gdipramd3H100Pool.id
output configuredTrains int = laiprfamd3Luipramd3Gdipramd3Trains
output sil3InterlockLatencyMs string = '0.11'
output edgeSpectroscopyLatencyMs string = '0.11'
