// ============================================================================
// Blueprint #111: AKSClaw Autonomous High-Pressure LDPE/EVA Hyper-Compressor
// (2,500-3,200 bar) & Tubular Reactor Runaway PINN-MPC, FT-NIR Melt-Index
// Soft-Sensor & API 618 / ASME Section VIII Div. 3 / IEC 61511 SIL-3 Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the LDPE/EVA Hyper-Compressor & Tubular Reactor pool')
param location string = resourceGroup().location

@description('Environment tier for high-pressure polymerization control')
@allowed([
  'prod-ldpe-tubular-sil3'
  'staging-eva-autoclave-hil'
])
param environment string = 'prod-ldpe-tubular-sil3'

@description('Existing AKS cluster name hosting the AKSClaw polymerization agent fleet')
param aksClusterName string = 'aks-aksclaw-ldpe-hypercomp'

@description('Target reactor operating pressure in bar (2,000 - 3,200 bar)')
param reactorPressureBar int = 2850

@description('Maximum allowable peak zone temperature in Celsius before decomposition runaway (310 - 335 C)')
param maxZoneTempC int = 325

@description('Maximum hyper-compressor tungsten-carbide plunger rod drop/vibration in micrometers')
param maxPlungerVibrationUm int = 65

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. Real-Time PINN-MPC Node Pool for Hyper-Compressor Plunger Dynamics & Peroxide Initiator Dosing
resource ldpePinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ldpepinn'
  properties: {
    count: 4
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableUltraSSD: true
    enableNodePublicIP: false
    maxPods: 30
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'ldpe-eva-hypercompressor-tubular-pinn-mpc'
      'aksclaw.io/isolation': 'kata-vm-isolated'
      'aksclaw.io/polymerization-standard': 'api-618-asme-sec-viii-div3-iec-61511-sil3'
      'aksclaw.io/ftnir-spectroscopy': 'sapphire-window-3000bar-melt-index-soft-sensor'
    }
    nodeTaints: [
      'aksclaw.io/ldpe-hypercomp-sandbox=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '25%'
    }
  }
}

// 2. Deterministic Safety & Acoustic Emission / Plunger Rod-Load Guardrail Pool
resource ldpeSil3SafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ldpesil3'
  properties: {
    count: 3
    vmSize: 'Standard_FX36mds'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableUltraSSD: true
    enableNodePublicIP: false
    maxPods: 24
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'ldpe-decomposition-dump-valve-sil3-interlock'
      'aksclaw.io/safety-standard': 'api-618-asme-bpvc-div3-iec-61511-sil3'
      'aksclaw.io/reactor-pressure-bar': string(reactorPressureBar)
      'aksclaw.io/max-zone-temp-c': string(maxZoneTempC)
      'aksclaw.io/max-plunger-vibration-um': string(maxPlungerVibrationUm)
    }
    nodeTaints: [
      'aksclaw.io/ldpe-sil3-interlock=true:NoSchedule'
    ]
  }
}

output pinnPoolResourceId string = ldpePinnMpcPool.id
output sil3SafetyPoolResourceId string = ldpeSil3SafetyPool.id
output safetyEnvelopeSummary object = {
  environment: environment
  reactorPressureBar: reactorPressureBar
  maxZoneTempC: maxZoneTempC
  maxPlungerVibrationUm: maxPlungerVibrationUm
  standards: [
    'API 618 5th/6th Ed. Reciprocating Compressors for Petroleum, Chemical, and Gas Industry Services'
    'ASME BPVC Section VIII Division 3 Alternative Rules for Construction of High Pressure Vessels'
    'IEC 61511 SIL-3 Rapid Depressurization Dump Valve, Peroxide Initiator Cutoff & Nitrogen Quench Interlock'
  ]
}
