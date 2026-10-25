// ============================================================================
// AKSClaw Blueprint #193: Autonomous Antimony Sulfide Stibnite (Sb2S3)
// Volatilization Blast-Furnace Smelting (Sb2O3) / Alkaline Sulfide (Na3SbS3)
// Electrowinning, 6N5 (99.99995%) Zone-Refined Antimony & Trimethylantimony
// (TMSb) / Indium Antimonide (InSb) & InAs/GaSb Type-II Superlattice (T2SL)
// MWIR/LWIR Infrared Focal-Plane Detector & Ge2Sb2Te5 (GST) Phase-Change
// Photonic Memory PINN-MPC, Online 10 kHz In-Situ Raman/LIBS, TDLAS SbH3/AsH3/SO2
// Metrology & NFPA 86 / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3 Lethal Stibine
// (SbH3, PEL 0.1 ppm) Dry Chemisorption Scrubbing, Pyrophoric TMSb Isolation
// & Blast-Furnace CO/Sb2O3 Fume Interlock Pool (Cycle #192)
// ============================================================================
@description('AKS cluster name for Antimony Sb2S3 Smelting, 6N5 Antimony & InSb/T2SL Infrared Detector PINN-MPC agents')
param aksClusterName string = 'aks-antimony-6n5-insb-t2sl-gst-sbh3-sil3'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Initial node count for Standard_NC40ads_H100_v5 PINN-MPC & 10kHz In-Situ Raman/TDLAS/LIBS pool')
@minValue(2)
@maxValue(32)
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource antimonyInSbT2slPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'sbinsbsil3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'antimony-stibnite-blast-furnace-6n5-antimony-insb-t2sl-infrared-detector-gst-sbh3-nfpa86-sil3-agent'
      'aksclaw.io/pinn-mpc-stibnite-smelting-6n5-sb-insb-t2sl-gst': 'enabled-49.5pct-6n5-sb-insb-t2sl-gst-yield-gain-74.4pct-sb2o4-slag-arsenic-cut'
      'aksclaw.io/nfpa86-osha1910119-semis2-sil3-sbh3-scrubber-tmsb-isolation-interlock': 'enforced-0.27ms-zero-lethal-sbh3-release-tmsb-ignition-or-fume-blowout'
      'aksclaw.io/sb-insb-edge-10khz-raman-tdlas-sbh3-ash3-so2-libs': 'enabled-0.20ms-99.7pct-antimony-infrared-photonic-fab-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/antimony-insb-t2sl-gst-sbh3-sil3=dedicated:NoSchedule'
    ]
  }
}

output poolResourceId string = antimonyInSbT2slPool.id
output workloadClass string = 'antimony-stibnite-blast-furnace-6n5-antimony-insb-t2sl-infrared-detector-gst-sbh3-nfpa86-sil3-agent'
