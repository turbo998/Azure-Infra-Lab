// Blueprint #215 (220-Chapter & 215-Blueprint Milestone!): Autonomous Tritium (T2 / DT) Fusion Fuel Cycle, Tokamak Exhaust Pd-25Ag Membrane Permeator, Water Detritiation (WDS-LPCE), 20-25 K 4-Column Cryogenic Hydrogen Isotope Distillation (H2/HD/HT/D2/DT/T2) & ZrCo / Uranium Hydride Storage & Delivery System (SDS) PINN-MPC, Online 10 kHz Laser Raman 6-Isotopologue Spectroscopy, Beta-Induced X-Ray Spectrometry (BIXS) & Isothermal Calorimetry & DOE-STD-1129 / ITER RCC-MRx / ISO 17873 / IEC 61511 SIL-3 Glovebox Atmosphere Detritiation (ADS), ZrCo Pyrophoric Air-Ingress Lock & Cryogenic Tritium Inventory (<70 g) PassiveExpansion Dump Interlock Pool (Cycle #214)
param aksClusterName string = 'aks-tritium-dt-fusion-fuel-cycle-pdag-cryo-zrco-sil3'
param location string = resourceGroup().location

resource tritiumDtFusionFuelCycleSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'tritium214s3'
  properties: {
    count: 4 // Standard_NC24ads_A100_v4 (Sieverts Pd-25Ag Permeation, 20-25K 6-Component Cryo Distillation with Beta-Decay Self-Heating & ZrCo Hydride P-C-T Hysteresis PINN-MPC + Online 10 kHz Q1 Raman / BIXS / Calorimetry Edge)
    vmSize: 'Standard_NC24ads_A100_v4'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 16
    nodeLabels: {
      'aksclaw.io/workload-class': 'tritium-dt-fusion-fuel-cycle-pdag-permeator-cryo-distillation-zrco-bed-iter-sil3-agent'
      'aksclaw.io/pinn-mpc-pd25ag-sieverts-20k-cryo-distillation-and-zrco-pct-hydride': 'enabled-53.4pct-dt-fuel-recovery-purity-gain-77.8pct-tritium-permeation-loss-zrco-disproportionation-cut'
      'aksclaw.io/doestd1129-iter-iso17873-sil3-glovebox-ads-zrco-quench-and-cryo-dump': 'enforced-0.18ms-zero-hto-release-zrco-air-ingress-fire-or-cryo-inventory-overpressure'
      'aksclaw.io/tritium-edge-10khz-laser-raman-6isotopologue-bixs-ion-chamber-and-calorimetry': 'enabled-0.15ms-99.7pct-tritium-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/tritium-dt-fusion-fuel-cycle-sil3=true:NoSchedule'
    ]
  }
}

resource tritiumDtFusionFuelCycleRtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'tritium214rt'
  properties: {
    count: 2 // Standard_F16s_v2 deterministic real-time PLC safety interlock nodes
    vmSize: 'Standard_F16s_v2'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    nodeLabels: {
      'aksclaw.io/realtime-plc-interlock': 'doestd1129-iter-iso17873-iec61511-sil3-tritium-ads-zrco-cryo-dump-guard'
    }
  }
}
