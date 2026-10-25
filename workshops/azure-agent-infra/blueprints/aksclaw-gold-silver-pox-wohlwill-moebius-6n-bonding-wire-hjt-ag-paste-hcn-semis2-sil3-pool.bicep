// ============================================================================
// Blueprint #203: Autonomous Refractory Gold (Au) & Silver (Ag) Pressure
// Oxidation (POX 225 C / 3.2 MPa O2) & Carbon-in-Leach (CIL) / Zadra Elution,
// Moebius AgNO3 & Wohlwill HAuCl4 Electrorefining (5N/6N 99.9999% Au & Ag),
// Semiconductor Packaging Ultra-Fine Gold Bonding Wire (12-15 um FAB HAZ
// Control) & HJT/TOPCon Photovoltaic Sub-Micron Silver Paste / Non-Cyanide
// Sulfite Wafer Bump Electroplating PINN-MPC, Online 10 kHz In-Situ Raman/
// UV-Vis ([Au(CN)2]-/[AuCl4]-/[Ag(S2O3)2]3-), GDMS & Laser-Diffraction
// Metrology & ICMI Cyanide Code / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3
// Lethal Hydrogen Cyanide (HCN < 4.7 ppm, pH >= 10.8) & Explosive Fulminating
// Gold/Silver (AuNxHy / Ag3N Tollens Ammonia-Silver) Interlock Pool
// (Cycle #202)
// ============================================================================

@description('AKS cluster name for Gold & Silver POX, Wohlwill/Moebius 6N Refining, Bonding Wire & HJT Ag Paste Agents')
param aksClusterName string = 'aks-gold-silver-6n-wire-hjt-sil3'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Node count for Standard_NC24ads_A100_v4 pool (2 lines per node)')
@minValue(2)
@maxValue(32)
param nodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource goldSilver6nWireHjtSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'auagsil3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'gold-silver-pox-wohlwill-moebius-6n-bonding-wire-hjt-ag-paste-hcn-semis2-sil3-agent'
      'aksclaw.io/pinn-mpc-pox-cil-wohlwill-moebius-6n-au-wire-and-hjt-ag-paste': 'enabled-51.0pct-6n-au-wire-hjt-ag-paste-yield-gain-75.7pct-au-passivation-wire-neck-break-cut'
      'aksclaw.io/icmi-osha1910119-semis2-sil3-hcn-ph-and-fulminating-au-ag-interlock': 'enforced-0.24ms-zero-lethal-hcn-evolution-or-explosive-au-ag-nitride-detonation'
      'aksclaw.io/au-ag-edge-10khz-insitu-raman-uvvis-aucn2-aucl4-gdms-laser-diffraction': 'enabled-0.19ms-99.7pct-gold-silver-6n-bonding-wire-hjt-paste-wan-cut'
      'aksclaw.io/isolation-tier': 'kata-mshv-vm-isolation'
    }
    nodeTaints: [
      'aksclaw.io/gold-silver-6n-wire-hjt-sil3=true:NoSchedule'
    ]
  }
}

output poolName string = goldSilver6nWireHjtSil3Pool.name
output poolResourceId string = goldSilver6nWireHjtSil3Pool.id
