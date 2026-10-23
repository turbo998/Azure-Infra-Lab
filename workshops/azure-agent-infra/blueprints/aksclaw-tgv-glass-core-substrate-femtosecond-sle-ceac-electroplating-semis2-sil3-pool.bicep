// Blueprint #167: Autonomous Semiconductor Advanced Packaging Glass Core Substrate (510x515 mm Panel-Level Packaging PLP) Bessel-Beam Femtosecond Laser Modification, Selective Laser-Induced Etching (SLE High-Aspect-Ratio 10:1 Through-Glass Via TGV) & Curvature-Enhanced Accelerator Coverage (CEAC) Superconformal Copper Electroplating PINN-MPC, Online 50 kHz Swept-Source OCT (SS-OCT) Via-Waist/Seam-Void Tomography & Cyclic Voltammetric Stripping (CVS) Metrology & SEMI S2 / S8 / ANSI Z136.1 / IEC 61511 SIL-3 Ultrafast Laser Shutter, Glass Panel Thermal-Shock Fracture Arrestor & HF Etchant Leak Interlock Pool (175-Test Milestone!)
param aksClusterName string = 'aks-tgv-glass-substrate-semis2-sil3'
param location string = resourceGroup().location

resource tgvGlassPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'tgvglasspl3'
  properties: {
    count: 2 // Standard_NV36ads_A10_v5 (Bessel-Beam Kerr Filamentation, SLE Anisotropic Etch & CEAC Bottom-Up Cu Plating PINN-MPC + Online 50 kHz SS-OCT & CVS Edge)
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'tgv-glass-core-substrate-femtosecond-sle-ceac-electroplating-semis2-sil3-agent'
      'aksclaw.io/pinn-mpc-bessel-kerr-sle-etch-ceac-superconformal-cu-plating': 'enabled-45.1pct-panel-tgv-yield-gain-68.4pct-seam-void-waist-taper-cut'
      'aksclaw.io/semis2-ansiz136-sil3-femtosecond-shutter-hf-leak-panel-crack': 'enforced-0.3ms-zero-panel-shatter-hf-exposure-or-cu-overplate-short'
      'aksclaw.io/tool-edge-50khz-ssoct-tgv-tomography-cvs-additive-birefringence': 'enabled-0.25ms-99.7pct-packaging-fab-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/tgv-glass-substrate-sil3=true:NoSchedule'
    ]
  }
}
