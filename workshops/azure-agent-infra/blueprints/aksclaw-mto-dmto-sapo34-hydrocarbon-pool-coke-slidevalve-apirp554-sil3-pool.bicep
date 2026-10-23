// ============================================================================
// Blueprint #140: Autonomous Methanol-to-Olefins (MTO / DMTO-III 460-510 C)
// Dual-Fluidized-Bed Circulating Reactor-Regenerator, SAPO-34 Molecular-Sieve
// Cage Hydrocarbon-Pool (Polymethylbenzene vs Polycyclic Aromatics Coke wt%) &
// Ethylene/Propylene (C2=/C3=) Selectivity PINN-MPC, Online Near-Infrared (NIR)
// Spent-Catalyst Carbon / Cyclone Dipleg Differential-Pressure Metrology &
// API RP 554 / ASME BPVC Sec VIII / IEC 61508 SIL-3 Slide-Valve Differential-
// Pressure Reversal (O2-Hydrocarbon Deflagration), Regenerator Afterburning &
// Steam-Curtain Standpipe Isolation Interlock Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the MTO / DMTO-III SAPO-34 reactor-regenerator AKSklaw pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the MTO / DMTO-III PINN-MPC sandboxes')
param aksClusterName string = 'aks-mto-dmto-sapo34-sil3'

@description('MTO / CTO reactor-regenerator process generation')
@allowed([
  'dmto-iii-dense-bed-structured-internal-1800ktpa-meoh'
  'dmto-ii-c4-plus-olefin-cracking-dual-riser-bed'
  'smto-uop-hydrocarbon-pool-fast-fluidized-reactor'
])
param mtoProcessGeneration string = 'dmto-iii-dense-bed-structured-internal-1800ktpa-meoh'

@description('Target active SAPO-34 cage carbon content window (wt% coke on catalyst)')
param targetCageCarbonContentWtPct string = '7.8'

@description('Methanol feed rate per reactor train (t/h)')
@minValue(80)
@maxValue(360)
param methanolFeedRateTph int = 240

@description('Minimum spent/regenerated catalyst slide-valve positive differential pressure dP_min (kPa)')
param minSlideValveDiffPressureKpa string = '25.0'

@description('Maximum regenerator dilute-phase flue-gas afterburning temperature T_regen,max (C)')
param maxRegeneratorFlueTempC string = '705.0'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU PINN-MPC Pool for SAPO-34 Dual-Cycle (Aromatic/Olefin) Hydrocarbon-Pool
//    Kinetics, Cage Coke Distribution & Reactor-Regenerator Catalyst Circulation PINN-MPC
resource mtoPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mtopinnpool'
  properties: {
    count: 4
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 4
    maxCount: 12
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'mto-dmto-sapo34-hydrocarbon-pool-coke-slidevalve-pinn-mpc'
      'agent.infra/mto-process-generation': mtoProcessGeneration
      'agent.infra/target-cage-carbon-wtpct': targetCageCarbonContentWtPct
      'agent.infra/methanol-feed-tph': string(methanolFeedRateTph)
      'agent.infra/kata-vm-isolation': 'true'
    }
    nodeTaints: [
      'mto.agent.infra/pinn-gpu=true:NoSchedule'
    ]
  }
}

// 2. Deterministic Edge Safety Pool for Standpipe NIR Coke Metrology, Dipleg
//    500 Hz Pressure-Fluctuation & API RP 554 / SIL-3 Slide-Valve Reversal Interlock
resource mtoSafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'mtosil3pool'
  properties: {
    count: 3
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    proximityPlacementGroupID: ''
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.infra/workload': 'apirp554-asmeviii-sil3-mto-slidevalve-afterburn-interlock'
      'agent.infra/min-slidevalve-dp-kpa': minSlideValveDiffPressureKpa
      'agent.infra/max-regenerator-flue-temp-c': maxRegeneratorFlueTempC
      'agent.infra/safety-standard': 'API-RP-554-ASME-BPVC-VIII-IEC-61508-SIL3'
    }
    nodeTaints: [
      'mto.agent.infra/sil3-safety=true:NoSchedule'
    ]
  }
}

output mtoPinnPoolId string = mtoPinnPool.id
output mtoSafetyPoolId string = mtoSafetyPool.id
output safetyInterlockSpec string = 'API-RP-554/ASME-VIII/IEC-61508-SIL3|dP_slidevalve_min=${minSlideValveDiffPressureKpa}kPa|T_regen_max=${maxRegeneratorFlueTempC}C|Hydraulic_Lock<10ms'
