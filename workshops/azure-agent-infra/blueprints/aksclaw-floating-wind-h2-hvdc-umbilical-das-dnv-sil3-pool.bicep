// blueprints/aksclaw-floating-wind-h2-hvdc-umbilical-das-dnv-sil3-pool.bicep
// Blueprint #159: Autonomous 1-5 GW Floating Offshore Wind-to-Hydrogen & Subsea 66 kV / +-320 kV HVDC Dynamic Export Umbilical
// Spar/Semi-Submersible 6-DOF Pitch-Roll-Yaw & VIV Suppression, Electrolyzer Ramp-Rate PINN-MPC, Online 10 kHz DAS/BOTDR &
// UHF Partial-Discharge Metrology & IEC 61400-3-2 / DNV-ST-0119 / CIGRE TB 852 / IEC 61511 SIL-3 Dynamic Cable MBR, H2 Crossover & ERS Interlock Pool

@description('Deployment Azure region for the floating offshore wind-to-hydrogen & dynamic HVDC umbilical control pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the floating offshore wind-to-hydrogen & dynamic HVDC umbilical control planes')
param clusterName string = 'aks-floating-wind-h2-hvdc-sil3'

@description('Target floating offshore wind-to-H2 farm capacity in MW (200 to 5000 MW)')
@minValue(200)
@maxValue(5000)
param farmCapacityMw int = 1500

@description('Maximum allowable dynamic umbilical minimum bend radius (MBR) safety factor (DNV-ST-0119 / CIGRE TB 852)')
param minBendRadiusSafetyFactor string = '1.35'

@description('Maximum allowable H2-in-O2 crossover concentration in % LEL before IEC 61511 SIL-3 electrolyzer Nitrogen purge & ERS trip')
param maxH2InO2LelPct string = '1.60'

resource floatingWindPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/fltwindpinn'
  properties: {
    count: 4
    vmSize: 'Standard_ND96amsr_A100_v4'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'agent.infra/workload': 'floating-wind-6dof-viv-electrolyzer-pinn-mpc'
      'agent.infra/domain': 'floating-offshore-wind-h2-hvdc-umbilical'
      'agent.infra/farm-capacity-mw': string(farmCapacityMw)
      'agent.infra/accelerator': 'nvidia-a100-80gb'
    }
    nodeTaints: [
      'agent.infra/floating-wind-pinn=true:NoSchedule'
    ]
  }
}

resource dasBotdrUdfPdMetrologyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/dasuhfmet'
  properties: {
    count: 6
    vmSize: 'Standard_FX48mds'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 3
    maxCount: 12
    ppg: null
    nodeLabels: {
      'agent.infra/workload': 'das-botdr-10khz-uhf-pd-metrology'
      'agent.infra/cable-standard': 'CIGRE-TB-852-DNV-ST-0119'
      'agent.infra/min-mbr-safety-factor': minBendRadiusSafetyFactor
    }
    nodeTaints: [
      'agent.infra/das-uhf-metrology=true:NoSchedule'
    ]
  }
}

resource dnvIecSil3ErsSafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/dnvsil3ers'
  properties: {
    count: 3
    vmSize: 'Standard_DC32ds_v3'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: false
    nodeLabels: {
      'agent.infra/workload': 'iec61400-dnvst0119-sil3-mbr-h2-ers-interlock'
      'agent.infra/safety-standard': 'IEC-61400-3-2-DNV-ST-0119-IEC-61511-SIL3'
      'agent.infra/max-h2-in-o2-lel-pct': maxH2InO2LelPct
      'agent.infra/confidential-sgx': 'enabled'
    }
    nodeTaints: [
      'agent.infra/sil3-safety-interlock=true:NoSchedule'
    ]
  }
}

output blueprintId string = 'aksclaw-floating-wind-h2-hvdc-umbilical-das-dnv-sil3-pool'
output configuredFarmCapacityMw int = farmCapacityMw
output safetyInterlockStandard string = 'IEC 61400-3-2 / DNV-ST-0119 / CIGRE TB 852 / IEC 61511 SIL-3'
