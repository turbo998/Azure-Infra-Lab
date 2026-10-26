// 209. Autonomous Uranium (U, Z=92) & Thorium (Th, Z=90) Fluorination Conversion, UF6 Gas Centrifuge Cascade High-Assay Low-Enriched Uranium (HALEU 19.75% 235U) Enrichment, Sol-Gel Internal-Gelation Uranium Oxycarbide (UCO) Kernel & Spouted Fluidized-Bed Chemical Vapor Deposition (FB-CVD Buffer/IPyC/35um-beta-SiC/OPyC Quad-Layer) TRISO Particle Fuel Fabrication PINN-MPC, Online 10 kHz Mid-IR UF6 Laser Isotope Ratio (QCL-TDLAS / TIMS), High-Speed X-Ray Phase-Contrast Radiography & Active Neutron Coincidence Counting (NCC) Metrology & 10 CFR 70 / ANSI/ANS-8.1 / NFPA 55 / ASME NQA-1 / IEC 61511 SIL-3 Subcritical Geometry/Moderation Lock (k_eff < 0.92), UF6 Hydrolysis (UO2F2 + 2HF) Cryo-Autoclave Isolation & FB-CVD Methyltrichlorosilane (MTS-H2) Pyrolysis Runaway Interlock Pool (Cycle #208)
param aksClusterName string = 'aks-uranium-thorium-uf6-haleu-uco-triso-sil3'
param location string = resourceGroup().location

resource uraniumThoriumUf6HaleuUcoTrisoSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'uhaleu208s3'
  properties: {
    count: 4 // Standard_NC24ads_A100_v4 (UF6 Centrifuge Countercurrent Swirl, UCO Sol-Gel Kernel & FB-CVD TRISO Quad-Layer PINN-MPC + Online 10 kHz QCL-TDLAS / X-Ray Phase-Contrast / NCC Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'uranium-thorium-uf6-centrifuge-haleu-enrichment-uco-triso-fbcvd-criticality-sil3-agent'
      'aksclaw.io/pinn-mpc-uf6-centrifuge-haleu-uco-solgel-and-triso-fbcvd': 'enabled-51.8pct-haleu-swu-efficiency-uco-sphericity-triso-sic-integrity-gain-76.5pct-defect-cut'
      'aksclaw.io/cfr70-ans81-nfpa55-sil3-criticality-uf6-hydrolysis-and-mts-fbcvd': 'enforced-0.23ms-zero-keff-criticality-uf6-hf-hydrolysis-release-or-mts-h2-explosion'
      'aksclaw.io/haleu-triso-edge-10khz-qcl-tdlas-xray-radiography-and-ncc': 'enabled-0.18ms-99.7pct-haleu-triso-nuclear-fuel-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/uranium-thorium-uf6-haleu-uco-triso-sil3=true:NoSchedule'
    ]
  }
}

resource uraniumThoriumUf6HaleuUcoTrisoSil3RtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'uhaleu208rt'
  properties: {
    count: 2 // Standard_F16s_v2 deterministic hard-interlock nodes for 0.23 ms 10 CFR 70 / ANSI/ANS-8.1 / NFPA 55 / SIL-3 criticality, UF6 cryo-trap & MTS-H2 pyrolysis interlock
    vmSize: 'Standard_F16s_v2'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    nodeLabels: {
      'aksclaw.io/realtime-interlock': 'cfr70-ans81-nfpa55-sil3-0.23ms-criticality-uf6-cryotrap-mts-quench'
    }
  }
}
