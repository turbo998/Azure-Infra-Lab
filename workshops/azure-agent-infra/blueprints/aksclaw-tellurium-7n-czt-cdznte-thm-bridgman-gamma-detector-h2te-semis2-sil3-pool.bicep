// ============================================================================
// Blueprint #188: AKSClaw Copper-Anode Slime & Tellurobismuthite (Cu2Te/Ag2Te)
// High-Pressure Alkaline Autoclave Leaching, 7N Tellurium & THM/Bridgman
// CdZnTe (CZT) Gamma/X-Ray Detector Crystal Growth PINN-MPC Pool
// ============================================================================
// Standard: NFPA 86 / OSHA 1910.1027 (Cadmium) / SEMI S2 / IEC 61511 SIL-3
// Node SKU: Standard_NC40ads_H100_v5 (10 kHz In-Situ EDXRD Interface Curvature,
//           FTIR Zn Fraction x & TDLAS H2Te/Cd Vapor Edge Loop)
// ============================================================================

@description('Azure region for the AKSClaw 7N Tellurium & CdZnTe (CZT) Crystal Growth pool')
param location string = resourceGroup().location

@description('AKS cluster name')
param clusterName string = 'aksclaw-tellurium-7n-czt-sil3'

@description('Agent pool VM SKU for PINN-MPC THM/Bridgman CZT & 10 kHz EDXRD/FTIR/TDLAS edge fusion')
param vmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum number of dedicated H100 v5 nodes')
@minValue(2)
@maxValue(32)
param minCount int = 3

@description('Maximum number of dedicated H100 v5 nodes')
@minValue(3)
@maxValue(64)
param maxCount int = 12

@description('Maximum H2Te toxic gas concentration before SIL-3 NaClO/NaOH scrubber & purge trip (ppb)')
param maxH2TeGasConcentrationPpb int = 50

@description('Maximum quartz ampoule Cadmium partial pressure deviation before N2 autoclave counter-pressure & heater quench (kPa)')
param maxCadmiumAmpoulePressureDeltaKpa int = 18

@description('Maximum workplace airborne Cadmium aerosol concentration per OSHA 1910.1027 PEL (ug/m3 x 10)')
param maxAirborneCadmiumTenthsUgPerM3 int = 50

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource teCztPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'tecztsil3'
  properties: {
    vmSize: vmSize
    count: minCount
    minCount: minCount
    maxCount: maxCount
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    workloadRuntime: 'KataMshvVmIsolation'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/Select': 'tellurium-7n-czt-cdznte-thm-bridgman-gamma-detector-sil3'
      'aksclaw.io/Standard': 'NFPA86-OSHA19101027-SEMIS2-IEC61511-SIL3'
      'aksclaw.io/Metrology': '10kHz-InSitu-EDXRD-FTIR-Zn-TDLAS-H2Te-Cd'
      'aksclaw.io/InterlockLatencyMs': '0.29'
    }
    nodeTaints: [
      'aksclaw.io/tellurium-czt-sil3=true:NoSchedule'
    ]
    tags: {
      Domain: 'Tellurium-7N-CdZnTe-CZT-THM-Bridgman-Detector-Crystal-Growth'
      SafetyStandard: 'NFPA-86-OSHA-1910.1027-SEMI-S2-IEC-61511-SIL3'
      MaxH2TeGasConcentrationPpb: string(maxH2TeGasConcentrationPpb)
      MaxCadmiumAmpoulePressureDeltaKpa: string(maxCadmiumAmpoulePressureDeltaKpa)
      MaxAirborneCadmiumTenthsUgPerM3: string(maxAirborneCadmiumTenthsUgPerM3)
    }
  }
}

output poolId string = teCztPool.id
output safetyStandard string = 'NFPA 86 / OSHA 1910.1027 / SEMI S2 / IEC 61511 SIL-3'
output targetInterlockMs string = '0.29'
