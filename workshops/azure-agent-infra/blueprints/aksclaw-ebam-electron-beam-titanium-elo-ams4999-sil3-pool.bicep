// blueprints/aksclaw-ebam-electron-beam-titanium-elo-ams4999-sil3-pool.bicep
// Blueprint #120: Aerospace Titanium Electron Beam Additive Manufacturing (EBAM / EB-PBF) 60-150 kV Vacuum Chamber,
// Backscattered Electron (ELO) Keyhole Porosity & Al-Vaporization PINN-MPC & AMS 4999A / AWS D17.1 / NFPA 484 / SIL-3 Crowbar Interlock Pool
targetScope = 'resourceGroup'

@description('Azure region for the EBAM/EB-PBF Titanium Additive Manufacturing cluster')
param location string = resourceGroup().location

@description('Environment name')
@allowed(['prod-ams4999-sil3', 'staging-ebam-twin', 'qualification-awSD17'])
param environment string = 'prod-ams4999-sil3'

@description('AKS cluster name for EBAM/EB-PBF PINN-MPC & ELO Tomography pods')
param aksClusterName string = 'aks-ebam-titanium-sil3'

@description('Accelerating voltage target (kV) for the 60-150 kV electromagnetic deflection electron gun')
param acceleratingVoltageKv int = 60

@description('Maximum helium/argon controlled bleed vacuum pressure (mbar) before HV arc-flash crowbar trip')
param maxChamberPressureMbar string = '0.005'

@description('Minimum aluminum mass fraction (wt%) in Ti-6Al-4V melt pool under Langmuir evaporation compensation')
param minAluminumMassFractionPct string = '5.65'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource ebamPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ebampinn'
  properties: {
    count: 4
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableUltraSSD: true
     availabilityZones: ['1', '2', '3']
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-mshv'
      'agent.aksclaw.io/domain': 'ebam-titanium-elo-pinn-mpc'
      'Aerospace.ams4999a/qualification': 'ti6al4v-eli-grade23'
      'safety.iec61508/sil-rating': 'SIL-3'
    }
    nodeTaints: [
      'ebam.aksclaw.io/elo-pinn=true:NoSchedule'
    ]
    tags: {
      blueprintId: '120'
      cycleId: '119'
      chapter: '124'
      acceleratingVoltageKv: string(acceleratingVoltageKv)
      maxChamberPressureMbar: maxChamberPressureMbar
      minAluminumMassFractionPct: minAluminumMassFractionPct
      safetyStandard: 'AMS-4999A-AWS-D17.1-NFPA-484-SIL3'
    }
  }
}

resource ebamSil3EdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ebamsil3'
  properties: {
    count: 3
    vmSize: 'Standard_D16ds_v5'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    availabilityZones: ['1', '2', '3']
    nodeLabels: {
      'agent.aksclaw.io/isolation': 'kata-mshv'
      'agent.aksclaw.io/domain': 'ebam-hv-crowbar-nfpa484-sil3'
      'safety.nfpa484/pyrophoric-passivation': 'enabled'
    }
    nodeTaints: [
      'safety.aksclaw.io/sil3-interlock=true:NoSchedule'
    ]
  }
}

output blueprintId int = 120
output ebamPinnPoolId string = ebamPinnPool.id
output ebamSil3EdgePoolId string = ebamSil3EdgePool.id
