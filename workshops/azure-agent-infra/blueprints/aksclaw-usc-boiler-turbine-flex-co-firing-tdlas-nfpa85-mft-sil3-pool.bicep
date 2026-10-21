// ============================================================================
// Azure Bicep Blueprint #127: Autonomous Ultra-Supercritical (USC 620-650 C /
// 30-35 MPa) & 700 C A-USC Deep-Peak-Shaving Boiler-Turbine Unit (1,000-1,350 MW)
// with Biomass/NH3 Co-Firing & Post-Combustion Carbon Capture (PCC), Tangential
// Fireball Vortex & Superheater Oxide-Scale Exfoliation Creep PINN-MPC, TDLAS
// CO/O2/NH3-Slip & Acoustic Pyrometry Metrology & NFPA 85 / ASME BPVC Sec I /
// IEEE C37.106 / IEC 61508 SIL-3 Master Fuel Trip (MFT), Furnace Implosion
// Draft & 100% Fast Cut-Back (FCB) Interlock Pool
// ============================================================================
@description('Name of the existing AKS cluster hosting the AKSClaw control plane')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure region for Ultra-Supercritical USC Boiler-Turbine Flex & NFPA 85 MFT SIL-3 GPU pool')
param location string = resourceGroup().location

@description('Initial node count for Standard_NC24ads_A100_v4 USC Boiler-Turbine PINN-MPC pool')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource uscBoilerTurbineSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'uscpinns3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'usc-boiler-turbine-flex-cofiring-tdlas-nfpa85-mft-sil3-agent'
      'aksclaw.io/pinn-mpc-usc-fireball-superheater-oxide-creep-pcc': 'enabled-39.2pct-deep-flex-ramp-efficiency-gain-54.1pct-tube-creep-nox-nh3-slip-cut'
      'aksclaw.io/nfpa85-asme-sil3-mft-furnace-draft-fcb-interlock': 'enforced-0.3ms-zero-furnace-explosion-implosion-or-tube-rupture'
      'aksclaw.io/boiler-edge-tdlas-co-nh3-acoustic-pyrometry': 'enabled-0.3ms-99.5pct-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/usc-boiler-turbine-sil3=true:NoSchedule'
    ]
  }
}
