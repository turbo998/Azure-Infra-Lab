// Blueprint #247: Autonomous Electronic-Grade Boron Trichloride (5N5 BCl3 & Isotopically Enriched 5N5 11BCl3 >=99.9995% Chemical Purity, 11B >=99.85%, b.p. 12.6C, Ultra-Low Phosgene COCl2 <=0.10ppmv) & Titanium Tetrachloride (6N5 TiCl4 >=99.99995%, b.p. 136.4C, Vanadium Oxytrichloride VOCl3 <=0.02ppmw) + Silicon Tetrachloride (6N5 SiCl4 >=99.99995%, b.p. 57.6C) 2nm GAA Selective SiGe:B Source/Drain Epitaxy / 11B+ Ultra-Shallow Ion Implantation / AlCu/GaN Native-Oxide Scavenging Plasma Etch & DRAM High-Aspect-Ratio (80:1) Capacitor TiN Electrode / 3D NAND Low-Temp SiNx Spacer Thermal ALD Photochemical Phosgene Decomposition, Vanadium Reduction Rectification & Multi-Column Quartz Distillation PINN-MPC, Online 10 kHz QCL-TDLAS/FTIR (956cm-1 11B-Cl / 1827cm-1 COCl2 / 1035cm-1 VOCl3 / 621cm-1 Si-Cl) + HR-ICP-MS Metrology & SEMI S2 / SEMI C3 / NFPA 704 / OSHA PEL / IEC 61511 SIL-3 Moisture-Triggered Exothermic Hydrolysis (HCl Fume + H3BO3/TiO2/SiO2 Valve Seizure) & Phosgene COCl2 Breakout Hard Interlock (255-Test Milestone!)
targetScope = 'resourceGroup'

@description('Azure region for the BCl3 / 11BCl3, TiCl4 & SiCl4 GAA Epitaxy & DRAM TiN ALD Edge-Cloud cluster')
param location string = resourceGroup().location

@description('Number of parallel 5N5 BCl3 / 6N5 TiCl4 / 6N5 SiCl4 purification & DRAM TiN / GAA epitaxy trains (1-64)')
@minValue(1)
@maxValue(64)
param bcl3Ticl4Sicl4Trains int = 8

@description('Governance mode for 5N5 11BCl3 / 6N5 TiCl4 / 6N5 SiCl4 purification & DRAM TiN / GAA epitaxy PINN-MPC')
@allowed([
  'pinn_mpc_bcl3_ticl4_sicl4_phosgene_photolysis_vocl3_reduction_and_dram_tin_ald_sil3_edge'
  'raw_cloud_uncompensated_bcl3_cocl2_mass28_drift_and_ticl4_nh4cl_particulate_hydrolysis'
])
param governanceMode string = 'pinn_mpc_bcl3_ticl4_sicl4_phosgene_photolysis_vocl3_reduction_and_dram_tin_ald_sil3_edge'

var gpuNodeCount = max(2, (bcl3Ticl4Sicl4Trains + 1) / 2)
var activeBcl3Ticl4Sicl4Pods = bcl3Ticl4Sicl4Trains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-bcl3-ticl4-sicl4-sil3-${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'bcl3-ticl4-sicl4-sil3'
    agentPoolProfiles: [
      {
        name: 'syspool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'agent-infra/workload': 'bcl3-ticl4-sicl4-gaa-p-doping-dram-tin-ald-pinn-mpc-sil3'
          'agent-infra/governance-mode': governanceMode
          'agent-infra/active-pods': string(activeBcl3Ticl4Sicl4Pods)
          'agent-infra/safety-standard': 'SEMI-S2-SEMI-C3-NFPA704-OSHA-IEC61511-SIL3'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeBcl3Ticl4Sicl4Pods int = activeBcl3Ticl4Sicl4Pods
output governanceModeConfigured string = governanceMode
