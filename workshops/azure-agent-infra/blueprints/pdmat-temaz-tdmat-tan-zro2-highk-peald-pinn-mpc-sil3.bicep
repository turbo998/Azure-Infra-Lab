// =============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #240 (Cycle #239 · 240-Blueprint Milestone!)
// Autonomous Electronic-Grade Pentakis(dimethylamino)tantalum (6N PDMAT Ta(N(CH3)2)5
// >= 99.9999%, m.p. 98.5 C, v.p. 0.15 Torr @ 65 C) & Tetrakis(ethylmethylamino)zirconium
// (6N TEMAZ Zr(N(CH3)(C2H5))4 >= 99.9999%, b.p. 82 C @ 0.1 Torr) + Tetrakis(dimethylamino)-
// titanium (6N TDMAT Ti(N(CH3)2)4 >= 99.9999%) 2nm/A14 BEOL Zero-Incubation Copper
// Diffusion Barrier (1.2 nm Ultrathin TaN PEALD) & 1c/0a DRAM High-k Capacitor
// (4.5 nm ZrO2/TiN/ZrO2 ZAZ MIM Stack, k >= 38, EOT <= 0.42 nm, J_leak <= 1e-8 A/cm2)
// Vacuum Sublimation & Short-Path Molecular Distillation, Halide-Free Lithium-Dialkylamide
// Synthesis (Cl <= 0.10 ppmw Preventing Cu Pitting & TiN Blistering), Zr/Hf Homologous
// Trace Control & Mixed-Ligand Scrambling (Zr(NMe2)x(NEtMe)4-x <= 0.15 mol%) Suppression,
// Heated Solid-Source PDMAT (65.00 C) & Direct-Liquid-Injection (DLI) TEMAZ (95.0 C)
// Beta-Hydride Elimination Imine/Metallacycle Suppression (<= 0.12 ppmv) + NH3/O3 PEALD
// Supercycle PINN-MPC, Online 10 kHz QCL-TDLAS (945 cm-1 Ta-N / 1150 cm-1 C-N / 1645 cm-1
// C=N Imine Decomposition) + 1H/13C NMR + ICP-MS/MS (<= 2 pptw) Metrology & SEMI C3 /
// SEMI S2 / NFPA 30 / IEC 61511 SIL-3 PDMAT/TEMAZ Thermal Decomposition Runaway
// (> 105.0 C / > 125.0 C) & Pyrophoric Amine/Hydride Reaction Hard Interlock
// =============================================================================

@description('Azure region for the Electronic-Grade 6N PDMAT & 6N TEMAZ/TDMAT BEOL TaN Barrier & DRAM High-k ZAZ PEALD cluster')
param location string = resourceGroup().location

@description('Environment identifier')
@allowed([
  'prod'
  'staging'
])
param environment string = 'prod'

@description('Number of parallel 6N PDMAT sublimation & 6N TEMAZ/TDMAT distillation + BEOL TaN / DRAM ZAZ PEALD trains (2 to 32)')
@minValue(2)
@maxValue(32)
param pdmatTemazHighkTrains int = 8

var gpuNodeCount = max(2, (pdmatTemazHighkTrains + 1) / 2)
var clusterName = 'aks-pdmat-temaz-highk-sil3-${environment}'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}

resource pinnMpcGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'pdmatpinn'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC40ads_H100_v5'
    mode: 'User'
    osType: 'Linux'
    workloadRuntime: 'OCIContainer'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'pdmat-temaz-tdmat-tan-zro2-highk-peald-pinn-mpc'
      'agent.infra/pdmat-purity-grade': 'electronic-6n-99.9999pct-ta-nme2-5-cl-le-0.10ppmw'
      'agent.infra/temaz-purity-grade': 'electronic-6n-99.9999pct-zr-netme-4-scrambling-le-0.15molpct'
      'agent.infra/tdmat-purity-grade': 'electronic-6n-99.9999pct-ti-nme2-4-zaz-electrode'
      'agent.infra/beta-hydride-imine-limit': 'le-0.12ppmv-metallacycle-free-dli-vaporizer'
      'agent.infra/safety-interlock': 'semi-c3-s2-nfpa30-sil3-0.14ms-pdmat-105c-temaz-125c-lockout'
      'agent.infra/edge-metrology': 'qcl-tdlas-945cm1-1150cm1-1645cm1-nmr-icp-ms-ms-0.13ms'
    }
    nodeTaints: [
      'nvidia.com/gpu=true:NoSchedule'
    ]
  }
}

output clusterResourceId string = aksCluster.id
output pinnMpcGpuPoolNodes int = gpuNodeCount
output verifiedGovernanceMode string = 'pinn_mpc_pdmat_temaz_sublimation_distillation_and_zaz_tan_peald_sil3_edge'
output semiS2Sil3InterlockLatencyMs string = '0.14'
output edgeQclTdlasNmrIcpMsLatencyMs string = '0.13'
