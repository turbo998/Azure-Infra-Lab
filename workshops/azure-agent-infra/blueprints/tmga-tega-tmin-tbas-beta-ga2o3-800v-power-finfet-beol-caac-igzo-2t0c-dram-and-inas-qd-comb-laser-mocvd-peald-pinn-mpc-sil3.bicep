// blueprints/tmga-tega-tmin-tbas-beta-ga2o3-800v-power-finfet-beol-caac-igzo-2t0c-dram-and-inas-qd-comb-laser-mocvd-peald-pinn-mpc-sil3.bicep
// Cycle #290 (290-Cycle & 290-Simulator Double Milestone!) — Blueprint #291 (Chapter 295 + Summary 296 = 298 Chapters)
// Autonomous Electronic-Grade Ultrapure Trimethylgallium / Triethylgallium (6N5 TMGa / TEGa >=99.99995%, Si/Fe/Mg/Zn<=0.001ppbw, Alkoxide<=0.01ppmw) & Trimethylindium (6N5 TMIn >=99.99995%, Solution-TMIn Constant-Vapor-Pressure Bubbler) + Tertiarybutylarsine / Tertiarybutylphosphine (6N5 TBAs / TBP >=99.99995%, Low-Pyrolysis Liquid Group-V Hydride Replacements) + Diethylzinc (6N5 DEZn >=99.99995%) Ultra-Wide-Bandgap beta-Ga2O3 (Eg=4.88eV, E_crit=8.15MV/cm, BFOM=3440x Si, R_on_sp=0.42 mOhm*cm2 @ 2400V) 800V AI Rack Power FinFET, Monolithic 3D BEOL (<=320C) Crystalline c-Axis Aligned Indium-Gallium-Zinc-Oxide (CAAC-IGZO, mu_FE=42.5cm2/Vs, I_off=1.2e-22 A/um, Capacitorless 2T0C DRAM Retention tau_ret=4850s @ 85C) & 3.2T/6.4T CPO Heteroepitaxial 1.31um O-Band InAs/GaAs Quantum-Dot Comb Laser on 300mm Si(001) (TDD=1.4e6cm-2, 64x100GHz Comb Lines, WPE=28.4%, RIN=-158.5dB/Hz) MOCVD / PEALD / MBE PINN-MPC + SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1018 / IEC 61511 SIL-3 Pyrophoric Organometallic (TMGa/TEGa/TMIn/DEZn) & Acutely Hemolytic/Carcinogenic Group-V Hydride (TBAs/AsH3, OSHA PEL 0.005ppmv / 10ug/m3 as As) Hard Interlock

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 TMGa/TEGa/TMIn/TBAs/DEZn beta-Ga2O3 800V Power FinFET, BEOL CAAC-IGZO 2T0C DRAM & 3.2T/6.4T CPO InAs/GaAs QD Comb Laser MOCVD/PEALD PINN-MPC digital twin cluster')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'tmga-ga2o3-igzo-qdl-290'

@description('Number of parallel 6N5 TMGa/TEGa/TMIn/TBAs purification & beta-Ga2O3 / CAAC-IGZO / InAs QD Comb Laser MOCVD/PEALD reactor trains')
@minValue(1)
@maxValue(64)
param tmgaTegaTminTbasTrains int = 8

@description('Governance mode for 6N5 TMGa/TEGa/TMIn/TBAs beta-Ga2O3 800V Power FinFET, BEOL CAAC-IGZO 2T0C DRAM & InAs/GaAs QD Comb Laser MOCVD/PEALD PINN-MPC and SIL-3 arsine/pyrophoric organometallic interlock')
@allowed([
  'pinn_mpc_tmga_tega_tmin_tbas_beta_ga2o3_800v_power_finfet_beol_caac_igzo_2t0c_dram_and_inas_qd_comb_laser_mocvd_peald_sil3_edge'
  'unmanaged_open_loop_ash3_cylinder_tmin_channeling_and_igzo_oxygen_vacancy_drift'
])
param governanceMode string = 'pinn_mpc_tmga_tega_tmin_tbas_beta_ga2o3_800v_power_finfet_beol_caac_igzo_2t0c_dram_and_inas_qd_comb_laser_mocvd_peald_sil3_edge'

var gpuNodeCount = max(2, (tmgaTegaTminTbasTrains + 1) / 2)
var activeGa2o3IgzoQdLaserPods = tmgaTegaTminTbasTrains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'h100ga2o3igz'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent-infra/track': 'electronic-6n5-tmga-tega-tmin-tbas-beta-ga2o3-800v-finfet-beol-caac-igzo-2t0c-dram-and-inas-qd-comb-laser-mocvd-peald-pinn-mpc'
          'agent-infra/precursors': '6n5-tmga-6n5-tega-6n5-tmin-6n5-tbas-6n5-dezn'
          'agent-infra/metrology': '10khz-qcl-tdlas-592-2118-746cm1-sficpms-insitu-laytec-epirtt-hrxrd-comb-osa'
          'agent-infra/safety': 'semi-s2-nfpa704-osha-19101018-sil3-ash3-tbas-pyrophoric-organometallic-interlock'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
  }
}

output blueprintNumber int = 291
output simulatorFunction string = 'simulate_tmga_tega_tmin_tbas_beta_ga2o3_800v_power_finfet_beol_caac_igzo_2t0c_dram_and_inas_qd_comb_laser_mocvd_peald_sil3_sandbox'
output gpuNodes int = gpuNodeCount
output activeGa2o3IgzoQdLaserPods int = activeGa2o3IgzoQdLaserPods
output governanceModeSelected string = governanceMode
output sil3ArsineOrganometallicInterlockTargetLatencyMs string = '0.10'
output betaGa2o3BreakdownFieldMvCm string = '8.15'
output caacIgzo2t0cDramRetention85cSec string = '4850'
output inasQdCombLaserWpePct string = '28.4'
