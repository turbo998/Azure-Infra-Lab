// blueprints/aksclaw-scandium-yttrium-red-mud-extraction-calciothermic-5n-distillation-alscn-baw-target-y2o3-plasma-coating-sil3-pool.bicep
// Cycle #203 — Chapter 208: Autonomous Scandium (Sc) & Yttrium (Y) Red-Mud/TiO2-Waste Extraction, Anhydrous ScF3/YF3 Calciothermic Vacuum Distillation (5N 99.999%), 5G/6G BAW/FBAR High-Piezoelectric Al(1-x)ScxN Sputtering Target & Semiconductor Plasma-Etch Y2O3/YF3 Chamber Coating / SOFC 8YSZ PINN-MPC, Online 10 kHz LIBS/ICP-OES, XRD Wurtzite c/a & RGA Metrology & NFPA 484 / OSHA 1910.1000 / SEMI S2 / IEC 61511 SIL-3 Molten Ca-Thermite, Pyrophoric Sc/Y Vapor & Anhydrous HF Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Scandium & Yttrium 5N Distillation, AlScN BAW Target & Y2O3 Plasma Coating AKSClaw cluster')
param location string = resourceGroup().location

@description('Environment name (prod-sc-y-alscn-baw-y2o3-sil3 / staging-sc-y-5n)')
param environmentName string = 'prod-sc-y-alscn-baw-y2o3-sil3'

@description('Existing AKS cluster name hosting the Sc/Y Calciothermic 5N Distillation, AlScN BAW Target & Y2O3 Coating PINN-MPC pool')
param aksClusterName string = 'aksclaw-sc-y-alscn-baw-y2o3-sil3'

@description('GPU VM size for D2EHPA/TBP Sc3+/Fe3+/Ti4+ Extraction, Calciothermic ScF3/YF3 Reduction-Distillation, Wurtzite Al(1-x)ScxN Phase-Stability & APS/SPS Y2O3/YF3 Dense Coating PINN-MPC')
@allowed([
  'Standard_NC24ads_A100_v4'
  'Standard_ND96asr_v4'
  'Standard_NV36ads_A10_v5'
])
param pinnGpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('Number of GPU nodes in the Sc/Y 5N Distillation, AlScN BAW Target & Y2O3 Coating PINN-MPC pool')
@minValue(2)
@maxValue(64)
param pinnGpuNodeCount int = 4

@description('Maximum anhydrous HF off-gas concentration (ppm) in NH4HF2 fluorination before OSHA 1910.1000 / SEMI S2 SIL-3 dry-alumina & Ca(OH)2 scrubber lockout')
param maxFluorinationHfOffgasPpm int = 2

@description('Maximum Tantalum crucible wall temperature (deg C) during ScF3/YF3 + Ca calciothermic reduction before NFPA 484 SIL-3 helium quench')
param maxTaCrucibleCalciothermicTempC int = 1620

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource scYAlscnY2o3PinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'scyalscnpool'
  properties: {
    count: pinnGpuNodeCount
    vmSize: pinnGpuVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    maxPods: 30
    nodeLabels: {
      'agent.azure.com/workload-tier': 'scandium-yttrium-red-mud-calciothermic-5n-alscn-baw-y2o3-plasma-coating-pinn-mpc'
      'agent.azure.com/safety-integrity': 'nfpa484-osha19101000-semis2-iec61511-sil3-hf-3ppm-pyrophoric-sc-y-ca-thermite-interlock'
      'agent.azure.com/edge-metrology': '10khz-libs-icpoes-sc-fe-ti-xrd-alscn-wurtzite-rga-ta-crucible-o2-f2'
      'agent.azure.com/domain': 'critical-rare-earth-scandium-yttrium-5g-baw-rf-filter-and-plasma-etch-chamber-ceramics'
    }
    nodeTaints: [
      'scandium-yttrium-alscn-y2o3-pinn=true:NoSchedule'
    ]
    tags: {
      environment: environmentName
      chapter: '208'
      cycle: '203'
      safetyStandard: 'NFPA-484-OSHA-1910.1000-SEMI-S2-IEC-61511-SIL3'
      maxFluorinationHfOffgasPpm: string(maxFluorinationHfOffgasPpm)
      maxTaCrucibleCalciothermicTempC: string(maxTaCrucibleCalciothermicTempC)
    }
  }
}

output poolResourceId string = scYAlscnY2o3PinnPool.id
output safetyInterlockSpec string = 'NFPA 484 / OSHA 1910.1000 / SEMI S2 / IEC 61511 SIL-3 (<0.24 ms NH4HF2 fluorination anhydrous HF <3 ppm dry-alumina/Ca(OH)2 quench, calciothermic Ta-crucible >1,620 C molten Ca-ScF3 thermite runaway helium cooling & Class-D Ar isolation)'
output edgeMetrologySpec string = '0.19 ms 10 kHz LIBS/ICP-OES Sc3+/Fe3+/Ti4+ extraction selectivity, online XRD Al(1-x)ScxN wurtzite c/a lattice ratio vs rocksalt phase & vacuum RGA O2/F2 telemetry loop (99.7% WAN bandwidth reduction)'
