// blueprints/astatine211-bismuth-alpha-cyclotron-iodine123-xenon124-halogen-theranostics-sil3.bicep
// Cycle #222 — Chapter 227: Autonomous Halogen Theranostics Astatine-211 (211At T1/2=7.21h Alpha-Emitting Heavy Halogen via 28.5 MeV Alpha-Beam Irradiation 209Bi(alpha,2n)211At & 680C Quartz-Capillary Dry Thermochromatographic Distillation Eliminating 29.0 MeV Threshold 209Bi(alpha,3n)210At->210Po T1/2=138.4d Bone/Spleen Alpha Toxin) & No-Carrier-Added Iodine-123 (n.c.a. 123I >=99.8% mIBG / DaTscan SPECT via 30 MeV Proton High-Pressure Enriched Xenon-124 124Xe >=99.9% Gas-Target 124Xe(p,2n)123Cs->123Xe->123I Cryogenic Freeze-Trap Decay & >99.9% 124Xe Recovery) PINN-MPC, Online 10 kHz LaBr3:Ce / HPGe Gamma, Alpha-Liquid-Scintillation & Airborne Halogen Ionization Metrology & USP <823> / 10 CFR 20 / EU GMP Annex 3 / ISO 17873 / IEC 61511 SIL-3 Volatile Astatine/Iodine TEDA-AgX Scrubber Lockout, 210At/210Po Impurity Lot Quarantine & High-Pressure 124Xe Target Cryo-Recovery Interlock (Blueprint #223)

targetScope = 'resourceGroup'

@description('Azure region for the Astatine-211 & Iodine-123 Halogen Theranostics PINN-MPC & SIL-3 Interlock cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'at211i123s3'

@description('Number of parallel 209Bi(alpha,2n)211At dry distillation & 124Xe(p,2n)123I cryogenic gas-target production trains (1 to 32)')
@minValue(1)
@maxValue(32)
param at211I123Trains int = 8

@description('Governance mode for 28.5MeV 209Bi(a,2n)211At dry distillation, 124Xe->123I cryo gas target & USP <823> / ISO 17873 / SIL-3 safety')
@allowed([
  'pinn_mpc_bi209_a2n_at211_dry_distillation_and_xe124_p2n_i123_cryo_target_sil3_edge'
  'raw_cloud_above_threshold_alpha_beam_with_210po_impurity_and_open_halogen_venting'
])
param governanceMode string = 'pinn_mpc_bi209_a2n_at211_dry_distillation_and_xe124_p2n_i123_cryo_target_sil3_edge'

var aksClusterName = '${envPrefix}-aks-at211-i123-sil3'
var gpuNodeCount = max(2, (at211I123Trains + 1) / 2)
var rtNodeCount = max(2, (at211I123Trains + 3) / 4)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'astatine211-bismuth-alpha-cyclotron-iodine123-xenon124-halogen-theranostics-sil3'
    chapter: '227'
    blueprintId: '223'
    governanceMode: governanceMode
    safetyStandard: 'USP-823-10-CFR-20-EU-GMP-Annex-3-ISO-17873-IEC-61511-SIL-3'
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
        osSKU: 'Ubuntu'
      }
      {
        name: 'at211i222s3'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeLabels: {
          'agent-infra/role': 'pinn-mpc-bi209-a2n-at211-dry-distillation-and-xe124-p2n-i123-cryo-target'
          'agent-infra/metrology': '10khz-labr3-hpge-gamma-alpha-lsc-and-volatile-halogen-ionization'
        }
      }
      {
        name: 'at211i222rt'
        count: rtNodeCount
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeLabels: {
          'agent-infra/role': 'usp823-iso17873-sil3-teda-agx-halogen-scrubber-210po-quarantine-and-xe124-cryo-trip'
          'agent-infra/latency-target-ms': '0.16'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output gpuPoolNodeCount int = gpuNodeCount
output realtimeSil3PoolNodeCount int = rtNodeCount
output safetyInterlockTargetMs string = '0.16'
output edgeMetrologyLoopMs string = '0.15'
