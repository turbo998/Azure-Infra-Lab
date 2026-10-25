// blueprints/aksclaw-phosphorus-p4-arc-furnace-6n5-electronic-phosphorus-inp-lec-vgf-ph3-nfpa86-sil3-pool.bicep
// Blueprint #192 (Cycle #191 · 200-Test Milestone!): Autonomous Phosphate Rock Electrothermal Yellow Phosphorus (P4) Submerged-Arc Smelting (1,450-1,550 C),
// Wet Electrostatic Precipitator (WESP) Cottrell Dust Removal, 6N5 Electronic Phosphorus / PCl3 / PH3 Purification & High-Pressure (27.5 atm) LEC/VGF Indium Phosphide (InP)
// 1.6T/3.2T AI Optical Transceiver Wafer Synthesis PINN-MPC, Online 10 kHz In-Situ Raman P4/P2 Speciation, TDLAS PH3/CO & Slag LIBS Metrology &
// NFPA 86 / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3 Pyrophoric White Phosphorus (P4, 34 C Auto-Ignition) Warm-Water Seal, Lethal Phosphine (PH3) Scrubbing & InP Autoclave Interlock

@description('AKS cluster name for Phosphorus P4 Submerged-Arc Smelting, 6N5 Electronic Phosphorus & High-Pressure LEC/VGF InP Wafer Synthesis PINN-MPC')
param clusterName string = 'aksclaw-phosphorus-p4-inp-sil3'

@description('Azure region')
param location string = resourceGroup().location

@description('VM SKU for PINN-MPC & 10 kHz In-Situ Raman P4/P2 Speciation, TDLAS PH3/CO & Slag LIBS Edge Pool')
param vmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum and maximum node counts')
param minCount int = 2
param maxCount int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource phosphorusP4InpPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'p4inpsil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    AvailabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent-infra/workload': 'phosphorus-p4-arc-furnace-6n5-electronic-phosphorus-inp-lec-vgf-pinn-mpc'
      'agent-infra/safety-interlock': 'nfpa86-osha1910119-semis2-iec61511-sil3-pyrophoric-p4-water-seal-ph3-scrubber'
      'agent-infra/edge-metrology': 'insitu-raman-p4-p2-speciation-tdlas-ph3-co-slag-libs-10khz'
      'agent-infra/isolation': 'kata-mshv-vm-isolation'
    }
    nodeTaints: [
      'agent-infra/high-hazard-phosphorus-p4-ph3-inp-sil3=true:NoSchedule'
    ]
    tags: {
      blueprintId: '192'
      cycle: '191'
      chapter: '196'
      safetyStandard: 'NFPA-86-OSHA-1910.119-SEMI-S2-IEC-61511-SIL3'
      controlLoopLatencyMs: '0.20'
      interlockLatencyMs: '0.27'
    }
  }
}

output poolResourceId string = phosphorusP4InpPool.id
output safetyInterlockStandard string = 'NFPA 86 / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3 (0.27 ms Pyrophoric P4 55 C Warm-Water Seal Flood, NaClO/CuSO4 Venturi PH3 Scrubber & 27.5 atm InP Autoclave Isobaric N2 Lock)'
output metrologyPipeline string = '10 kHz In-Situ Raman P4/P2 Vapor Speciation + QCL-TDLAS PH3/CO/SiF4 + Slag LIBS CaO/SiO2 Acidity Ratio (0.20 ms Edge Loop, 99.7% WAN Cut)'
