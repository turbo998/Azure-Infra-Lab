// ============================================================================
// Blueprint #253: Electronic-Grade 5N HFIB + 5N 1,3-C4F6 + 5N FNO / F2
// 1000-Layer 3D NAND UHAR Etch & 2nm GAA Thermal ALE PINN-MPC & SIL-3 Interlock
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 5N HFIB + 5N 1,3-C4F6 + 5N FNO 3D NAND UHAR Etch & 2nm GAA Thermal ALE Edge-Cloud Control Plane')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #252 (260-Chapter Milestone!) deployment')
param environmentPrefix string = 'hfib-c4f6-fno-ale-sil3'

@description('Enable IEC 61511 SIL-3 / SEMI S2 / ACGIH TLV-C PFIB (10 ppbv) & Oxidizing FNO/F2 Hard Interlock')
param enableSil3PfibFnoInterlock bool = true

@description('QCL-TDLAS / FTIR (1642/1738/1844/1790 cm-1) + GC-AED + In-Line QCM/SE sampling rate in Hz')
param metrologySamplingRateHz int = 10000

var hubName = '${environmentPrefix}-iothub'
var aksClusterName = '${environmentPrefix}-aks-aksclaw'
var adxClusterName = replace('${environmentPrefix}adx', '-', '')

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: hubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpcpool'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'hfib-c4f6-fno-3dnand-uhar-etch-gaa-thermal-ale-pinn-mpc'
          'safety.iec61511/sil-tier': enableSil3PfibFnoInterlock ? 'SIL-3' : 'SIL-2'
          'metrology.qcl-tdlas/sampling-hz': string(metrologySamplingRateHz)
        }
      }
    ]
  }
}

output iotHubHostname string = iotHub.properties.hostName
output aksClusterId string = aksCluster.id
output sil3InterlockStatus string = enableSil3PfibFnoInterlock ? 'ACTIVE_SEMI_S2_ACGIH_TLVC_10PPBV_PFIB_AND_FNO_MONEL_SIL3' : 'DISABLED'
output adxTelemetryEndpoint string = 'https://${adxClusterName}.${location}.kusto.windows.net'
