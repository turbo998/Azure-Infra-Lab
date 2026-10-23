// blueprints/aksclaw-tfln-lnoi-modulator-smartcut-ibe-shg-semis2-sil3-pool.bicep
// Blueprint #160 (160-Blueprint Milestone!): Autonomous 150/200mm Thin-Film Lithium Niobate (TFLN / LNOI 300-600nm X-Cut LiNbO3-on-Insulator
// 1.6T/3.2T Electro-Optic Mach-Zehnder Modulator VpiL < 1.8 V*cm, >110 GHz) He+ Smart-Cut Ion-Slicing & Ar/CHF3 Ion-Beam Etching (IBE) Ridge-Waveguide
// Sidewall & PPLN Poling PINN-MPC, Online 50 kHz Spectroscopic Ellipsometry / Cherenkov SHG Metrology & SEMI S2 / S8 / IEC 61508 SIL-3 PPLN HV Crowbar & Ion-Implanter Interlock Pool

@description('Deployment Azure region for the TFLN/LNOI wafer Smart-Cut, IBE etching & PPLN poling control pool')
param location string = resourceGroup().location

@description('AKS cluster name hosting the TFLN/LNOI photonic wafer fabrication control planes')
param clusterName string = 'aks-tfln-lnoi-modulator-sil3'

@description('Number of TFLN/LNOI Smart-Cut ion-slicing, IBE ridge-waveguide etching & PPLN poling tools')
@minValue(2)
@maxValue(64)
param tflnProcessTools int = 8

@description('Target X-cut TFLN film thickness uniformity 3-sigma tolerance in nanometers')
param targetTflnFilmUniformity3SigmaNm string = '1.2'

@description('Maximum allowable PPLN periodic poling coercive current density spike in mA/cm2 before SEMI S2 SIL-3 HV crowbar trip')
param maxPolingCurrentDensityMaCm2 string = '18.5'

resource tflnPinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/tflnpinn'
  properties: {
    count: 4
    vmSize: 'Standard_NC40ads_H100_v5'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'agent.infra/workload': 'tfln-lnoi-smartcut-ibe-ppln-pinn-mpc'
      'agent.infra/domain': 'thin-film-lithium-niobate-photonics'
      'agent.infra/tfln-tools': string(tflnProcessTools)
      'agent.infra/accelerator': 'nvidia-h100-nvl'
    }
    nodeTaints: [
      'agent.infra/tfln-pinn=true:NoSchedule'
    ]
  }
}

resource shgEllipsometrySimsMetrologyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/shgellipmet'
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
      'agent.infra/workload': 'shg-50khz-ellipsometry-sims-metrology'
      'agent.infra/target-tfln-3sigma-nm': targetTflnFilmUniformity3SigmaNm
      'agent.infra/metrology-rate': '50khz'
    }
    nodeTaints: [
      'agent.infra/shg-ellipsometry-metrology=true:NoSchedule'
    ]
  }
}

resource semiS2S8Sil3PplnHvSafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/semis2tfln'
  properties: {
    count: 3
    vmSize: 'Standard_DC32ds_v3'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: false
    nodeLabels: {
      'agent.infra/workload': 'semis2-s8-sil3-ppln-hv-crowbar-implanter-interlock'
      'agent.infra/safety-standard': 'SEMI-S2-S8-ANSI-Z136-1-IEC-61508-SIL3'
      'agent.infra/max-poling-current-ma-cm2': maxPolingCurrentDensityMaCm2
      'agent.infra/confidential-sgx': 'enabled'
    }
    nodeTaints: [
      'agent.infra/sil3-safety-interlock=true:NoSchedule'
    ]
  }
}

output blueprintId string = 'aksclaw-tfln-lnoi-modulator-smartcut-ibe-shg-semis2-sil3-pool'
output configuredTflnProcessTools int = tflnProcessTools
output safetyInterlockStandard string = 'SEMI S2 / SEMI S8 / ANSI Z136.1 / IEC 61508 SIL-3'
