// blueprints/aksclaw-solid-state-sulfide-battery-dry-electrode-isobaric-h2s-ul9540a-sil3-pool.bicep
// Chapter 104 — Autonomous Next-Gen Solid-State Sulfide Lithium-Metal Battery (ASSB) Dry-Electrode
// Fibrillation Calendering, Isobaric Stack Press Viscoplastic-Electrochemical PINN-MPC, In-Situ
// Ultrasonic Acoustic Time-of-Flight (ToF) Dendrite / Delamination Inspection & UL 9540A / IEC 62619 /
// OSHA 29 CFR 1910.1000 / IEC 61508 SIL-3 Toxic H2S (<1 ppm) Dry-Room Purge & Stack-Short Interlock
targetScope = 'resourceGroup'

@description('AKS cluster name hosting the Solid-State Sulfide Battery (ASSB) Dry-Electrode & Isobaric Stack PINN-MPC agent pool')
param clusterName string = 'aks-aksclaw-assb-sulfide-sil3'

@description('Azure region for the sovereign ASSB dry-room gigafactory control plane')
param location string = resourceGroup().location

@description('VM size for coupled Newman-Monroe viscoplastic-electrochemical dendrite & dry-electrode PTFE fibrillation PINN-MPC twins')
@allowed([
  'Standard_ND96isr_H100_v5'
  'Standard_ND96amsr_A100_v4'
  'Standard_HB176rs_v4'
])
param vmSize string = 'Standard_ND96isr_H100_v5'

@description('Number of GPU/HPC nodes in the ASSB dry-room gigafactory pool')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

@description('Maximum H2S gas concentration threshold in ppm inside the <-50 C dew-point dry room before SIL-3 argon purge & scrubber trip (OSHA / NIOSH ceiling)')
param maxDryRoomH2sPpm string = '0.8'

@description('Target argyrodite Li6PS5Cl solid-electrolyte separator relative density (%) after isobaric warm pressing')
param targetElectrolyteRelativeDensityPct string = '99.2'

@description('Maximum ultrasonic ToF interfacial void/delamination size in micrometers before stack rejection & pressure re-profiling')
param maxInterfacialVoidUm string = '1.5'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

// 1. Dedicated H100 v5 Node Pool for Viscoplastic Dry-Electrode Calendering & Newman-Monroe Dendrite PINN-MPC
resource assbSulfideSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'assbsil3'
  properties: {
    count: nodeCount
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-mshv-vm-isolation'
      'agent.aksclaw.io/domain': 'solid-state-sulfide-battery-dry-electrode-isobaric-sil3'
      'agent.aksclaw.io/OT-protocol': 'ethercat-opcua-tsn-ultrasonic-tof-ftir-h2s-isobaric-press'
      'agent.aksclaw.io/safety-standard': 'ul9540a-iec62619-osha1910-iec61508-sil3'
      'agent.aksclaw.io/max-dry-room-h2s-ppm': maxDryRoomH2sPpm
      'agent.aksclaw.io/target-electrolyte-density-pct': targetElectrolyteRelativeDensityPct
      'agent.aksclaw.io/max-interfacial-void-um': maxInterfacialVoidUm
    }
    nodeTaints: [
      'aksclaw.io/assb-sulfide-battery-sil3=true:NoSchedule'
    ]
    tags: {
      Architecture: 'AKSClaw-ASSB-Solid-State-Sulfide-Battery-Dry-Electrode-Isobaric-SIL3'
      Chapter: '104'
      SafetyInterlock: 'UL9540A-IEC62619-OSHA1910-IEC61508-SIL3-H2S-Purge-Isobaric-Relief'
    }
  }
}

output poolResourceId string = assbSulfideSil3Pool.id
output isolationRuntime string = assbSulfideSil3Pool.properties.workloadRuntime
output safetyStandard string = 'UL 9540A / IEC 62619 / OSHA 29 CFR 1910.1000 / IEC 61508 SIL-3 Hardware H2S Purge & Isobaric Press Interlock'
