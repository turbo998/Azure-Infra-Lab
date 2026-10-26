// Cycle #212 — Blueprint #213: Heavy Water (D2O) & Stable Isotope (18O / 13C / 15N) Cascade Separation
// Girdler-Sulfide (H2S-H2O) Dual-Temperature Bithermal Sieve-Tray Exchange, CECE Pt-Hydrophobic Catalytic Exchange,
// Cryogenic CO / NO Fractional Distillation & Vacuum D2O Finishing PINN-MPC, Online 10 kHz CRDS / FTIR / IRMS &
// CAN/CSA-N285.0 / OSHA 1910.119 / ISO 15156 (NACE MR0175) / IEC 61511 SIL-3 Interlock Pool

@description('Azure region for the Heavy Water D2O & Stable Isotope 18O/13C/15N Cascade Separation AKSClaw pool')
param location string = resourceGroup().location

@description('AKS cluster name for Heavy Water D2O Girdler-Sulfide, CECE & Stable Isotope 18O/13C PINN-MPC')
param clusterName string = 'aksclaw-d2o-girdler-cece-stable-isotope-sil3'

@description('Number of parallel D2O Girdler-Sulfide, CECE & 18O/13C/15N isotope separation trains (1-64)')
@minValue(1)
@maxValue(64)
param d2oIsotopeCascadeTrains int = 8

@description('VM SKU for coupled Girdler-Sulfide bithermal tray hydraulics, CECE trickle-bed & cryogenic isotope distillation PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Governance mode for D2O Girdler-Sulfide bithermal exchange, CECE & 18O/13C cryogenic distillation')
@allowed([
  'pinn_mpc_girdler_sulfide_bithermal_cece_hydrophobic_pt_and_cryo_18o_13c_crds_nace_sil3_edge'
  'raw_cloud_fixed_h2s_water_ratio_open_loop_sieve_tray_weeping_and_offline_irms_grab_sampling'
])
param d2oIsotopeGovernanceMode string = 'pinn_mpc_girdler_sulfide_bithermal_cece_hydrophobic_pt_and_cryo_18o_13c_crds_nace_sil3_edge'

var gpuNodeCount = max(2, (d2oIsotopeCascadeTrains + 1) / 2)
var activeD2oIsotopePods = d2oIsotopeCascadeTrains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource d2oIsotopeGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'd2oisotope212s3'
  properties: {
    count: gpuNodeCount
    vmSize: gpuNodeVmSize
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    nodeLabels: {
      'aksclaw.io/workload-domain': 'heavy-water-d2o-girdler-sulfide-cece-stable-isotope-18o-13c'
      'aksclaw.io/governance-mode': d2oIsotopeGovernanceMode
      'aksclaw.io/metrology-loop': '10khz-crds-ftir-tdlas-h2s-perimeter-and-irms'
      'aksclaw.io/safety-interlock': 'csa-n285-osha1910119-iso15156-nace-mr0175-iec61511-sil3'
      'aksclaw.io/active-pods': string(activeD2oIsotopePods)
    }
    nodeTaints: [
      'aksclaw.io/d2o-isotope-sil3=true:NoSchedule'
    ]
  }
}

output poolName string = d2oIsotopeGpuPool.name
output provisionedGpuNodes int = gpuNodeCount
output activeD2oIsotopePods int = activeD2oIsotopePods
output locationOut string = location
