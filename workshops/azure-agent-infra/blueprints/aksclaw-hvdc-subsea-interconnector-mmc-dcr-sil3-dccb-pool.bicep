// ============================================================================
// Blueprint #71: Autonomous Multi-Terminal HVDC (MMC-HVDC) Subsea
// Interconnector, Dynamic Cable Thermal Rating (DCR) & CIGRE TB 496 /
// ENTSO-E NC HVDC / IEC 61508 SIL-3 Hybrid DC Circuit Breaker (DCCB) Pool
// ============================================================================
// Provisions an AKSklaw / Kata Confidential GPU node pool and Azure Local
// converter-station edge bridge for +-525 kV Modular Multilevel Converter
// (MMC-HVDC) grid-forming control, IEC 60287 subsea XLPE cable electro-thermal
// PINN Dynamic Cable Rating (DCR), and hardware-isolated CIGRE TB 496 /
// ENTSO-E NC HVDC / IEC 61508 SIL-3 Hybrid DC Circuit Breaker (DCCB <= 2.5 ms)
// and subsea fiber-optic DAS/DTS anchor-strike protection interlock.
// ============================================================================

@description('Target Azure region for the MMC-HVDC Subsea Interconnector control plane')
param location string = resourceGroup().location

@description('AKS cluster name hosting the MMC-HVDC & Subsea DCR agent pool')
param aksClusterName string = 'aks-hvdc-subsea-mmc-dcr-sil3'

@description('Number of bipolar +-525 kV MMC-HVDC converter stations & subsea interconnector corridors')
@minValue(1)
@maxValue(64)
param hvdcMmcConverterBipoles int = 8

@description('GPU SKU for IEC 60287 subsea cable electro-thermal PINN & MMC circulating-current MPC')
param gpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('Maximum allowed XLPE subsea cable conductor temperature in degC (CIGRE TB 496 / IEC 60287)')
param maxXlpeConductorTempDegC int = 70

@description('Maximum allowed Hybrid DC Circuit Breaker (DCCB) fault clearing window in microseconds')
param maxDccbFaultClearingUs int = 2500

var gpuNodeCount = max(2, (hvdcMmcConverterBipoles + 3) / 4)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource hvdcMmcDcrPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hvdcdcrpool'
  properties: {
    count: gpuNodeCount
    vmSize: gpuVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    nodeLabels: {
      'agent.azure.com/domain': 'hvdc-subsea-interconnector-mmc-dcr-sil3-dccb'
      'agent.azure.com/hvdc-standard': 'cigre-tb496-entsoe-nchvdc-iec60287'
      'agent.azure.com/safety-interlock': 'iec61508-sil3-hybrid-dccb-das-anchor-strike'
      'agent.azure.com/edge-bus': 'iec61850-9-2le-sv-das-dts-50khz'
    }
    nodeTaints: [
      'hvdc.azure.com/sil3-dccb-isolated=true:NoSchedule'
    ]
    tags: {
      workload: 'hvdc-subsea-mmc-dcr-sil3-dccb-sandbox'
      hvdcMmcConverterBipoles: string(hvdcMmcConverterBipoles)
      maxXlpeConductorTempDegC: string(maxXlpeConductorTempDegC)
      maxDccbFaultClearingUs: string(maxDccbFaultClearingUs)
    }
  }
}

output poolName string = hvdcMmcDcrPool.name
output provisionedGpuNodes int = gpuNodeCount
output sil3DccbProtectionPolicy string = 'CIGRE-TB496-ENTSOE-IEC61508-SIL3-XLPE-${maxXlpeConductorTempDegC}C-DCCB-${maxDccbFaultClearingUs}us'
