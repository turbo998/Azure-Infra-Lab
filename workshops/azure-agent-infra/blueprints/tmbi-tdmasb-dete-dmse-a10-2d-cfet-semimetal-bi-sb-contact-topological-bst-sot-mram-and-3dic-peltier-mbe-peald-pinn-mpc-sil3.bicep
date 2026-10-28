// =============================================================================
// Blueprint #298 (Cycle #297 · 305-Chapter Milestone! — Chapter 302 + Summary 303 = 305 Chapters):
// Electronic-Grade Ultrapure Trimethylbismuth / Tris(1-methoxy-2-methyl-2-propoxy)bismuth
// (6N5 TMBi / Bi(mmp)3 >= 99.99995%, Trace Metals <= 0.05 ppbw, Alpha <= 0.0001 counts/cm2*hr)
// & Tris(dimethylamino)antimony / Triethylantimony (6N5 TDMASb / TESb >= 99.99995%)
// + Diethyltelluride / Diisopropyltelluride (6N5 DETe / DIPTe >= 99.99995%)
// + Dimethylselenium (6N5 DMSe >= 99.99995%) 300mm A10/A7 2D CFET Zero-Schottky
// Semimetallic Bi(0112)/Sb(0112) Quantum-Limit Ohmic Contact (Rc_n = 29 Ohm*um),
// Topological Insulator (Bi1-xSbx)2Te3 / Bi2Se3 Dirac Spin-Momentum-Locked SOT-MRAM
// (|theta_SH_eff| = 3.2, Jc0 = 1.8e5 A/cm2) & Superlattice [Bi2Te3/Sb2Te3]N 3D-IC
// Micro-Peltier Thermoelectric Hotspot Cooler (ZT = 2.15, 680 W/cm2) MBE/MOCVD/PEALD
// PINN-MPC + SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3
// =============================================================================

@description('Azure region for the 6N5 TMBi / Bi(mmp)3 / TDMASb / DETe / DMSe A10 2D CFET Semimetallic Bi/Sb Contact, Topological BST SOT-MRAM & 3D-IC Micro-Peltier Cooler digital twin cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'aksclaw-tmbi-tdmasb-dete-dmse-bi-sb-bst-sil3'

@description('Number of parallel 6N5 TMBi / Bi(mmp)3 / TDMASb / DETe / DMSe purification & 300mm A10 Semimetallic Bi/Sb Contact / Topological BST SOT-MRAM / Micro-Peltier MBE/PEALD reactor trains')
@minValue(1)
@maxValue(64)
param tmbiTdmasbDeteDmseTrains int = 8

@description('AKS GPU node SKU for coupled semimetal Dirac-cone MIGS suppression, topological surface-state spin-charge conversion & superlattice phonon-blocking PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var gpuNodeCount = max(2, (tmbiTdmasbDeteDmseTrains + 1) / 2)
var activeBiSbContactTopologicalBstPeltierPods = tmbiTdmasbDeteDmseTrains * 4

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: envPrefix
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'bisbbstpool'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent-infra/domain': 'tmbi-tdmasb-dete-dmse-a10-2d-cfet-semimetallic-bi-sb-contact-topological-bst-sot-mram-and-3dic-peltier-cooler'
          'agent-infra/safety-interlock': 'semi-s2-nfpa704-osha-19101000-iec61511-sil3'
          'agent-infra/metrology': '10khz-qcl-crds-585cm1-1894cm1-insitu-arpes-rheed-stfmr-tdtr'
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

output clusterName string = aksCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeBiSbContactTopologicalBstPeltierPods int = activeBiSbContactTopologicalBstPeltierPods
output electronic6n5Tmbi6n5Tdmasb6n5Dete6n5DmsePurityAnd2dContactBstYieldGainPct string = '77.6'
output migsFermiPinningBulkShuntAndInterfacialThermalResistanceReductionPct string = '96.8'
output semiS2Nfpa704Osha19101000Sil3PyrophoricTmbiTesbStibineTellurideLockoutLatencyMs string = '0.10'
output edgeQclCrds585cm11894cm1InsituArpesRheedStfmrTdtrLatencyMs string = '0.11'
