// blueprints/aksclaw-diamond-hpht-mpcvd-wafer-oes-asme-sil3-pool.bicep
// Blueprint #158: Autonomous 100mm (4-inch) Single-Crystal Diamond Wafer HPHT (5.5-8.0 GPa, 1350-1650 C) & 915MHz/2.45GHz MPCVD Plasma-Ball Anti-Arcing PINN-MPC, Online OES (C2 516.5nm / Ha 656.3nm) & Two-Color Pyrometry Metrology & ASME BPVC VIII-3 / IEC 61508 SIL-3 Interlock Pool
targetScope = 'resourceGroup'

@description('Deployment Azure region for the HPHT & 915MHz MPCVD 100mm Single-Crystal Diamond Wafer edge-cloud hybrid cluster')
param location string = resourceGroup().location

@description('Environment tier (prod-fab, pilot-quantum-diamond, digital-twin-staging)')
@allowed([
  'prod-fab'
  'pilot-quantum-diamond'
  'digital-twin-staging'
])
param environment string = 'prod-fab'

@description('AKS Kubernetes version for Maxwell-plasma / Navier-Stokes / Stefan-crystallization PINN-MPC & OES telemetry pods')
param kubernetesVersion string = '1.30.6'

@description('GPU node VM size for Helmholtz 915MHz resonant cavity EM field, H2/CH4 plasma kinetics & HPHT thermal-gradient PINN-MPC inference')
param gpuNodeVmSize string = 'Standard_NV36ads_A10_v5'

@description('RT-Deterministic node VM size for Two-Color Pyrometry, OES C2/Ha ratio tracking & ASME VIII-3 / SIL-3 safety supervisor')
param rtNodeVmSize string = 'Standard_F16s_v2'

@description('Target microwave plasma pressure in Torr (standard 140-260 Torr for high-rate 100mm SCD growth)')
param targetPlasmaPressureTorr int = 195

@description('Maximum allowable substrate radial temperature gradient in K/cm before poly-rim / cracking trip')
param maxSubstrateRadialTempGradientKPerCm string = '3.5'

@description('Target OES C2 Swan (516.5 nm) to H-alpha (656.3 nm) emission intensity ratio for dislocation-free <100> step-flow growth')
param targetOesC2ToHalphaRatio string = '0.42'

var clusterName = 'aksclaw-diamond-mpcvd-${environment}'
var logWorkspaceName = 'law-diamond-mpcvd-${environment}'
var eventHubNamespaceName = 'ehns-diamond-oes-${uniqueString(resourceGroup().id)}'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 8
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 20
    minimumTlsVersion: '1.2'
  }
}

resource oesPlasmaStream 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: 'oes-pyrometry-hpht-anvil-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcpool'
        count: 3
        vmSize: gpuNodeVmSize
        osType: 'Linux'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.aksclaw.io/role': 'diamond-hpht-mpcvd-pinn-mpc'
          'agent.aksclaw.io/TargetPlasmaPressureTorr': string(targetPlasmaPressureTorr)
          'agent.aksclaw.io/TargetOesC2HaRatio': targetOesC2ToHalphaRatio
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
        ]
      }
      {
        name: 'sil3safepool'
        count: 3
        vmSize: rtNodeVmSize
        osType: 'Linux'
        mode: 'User'
        enableEncryptionAtHost: true
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.aksclaw.io/role': 'asme-viii3-sil3-plasma-quench-interlock'
          'agent.aksclaw.io/MaxRadialTempGradKPerCm': maxSubstrateRadialTempGradientKPerCm
          'agent.aksclaw.io/SafetyStandard': 'ASME-BPVC-VIII-3-NFPA-55-IEC61508-SIL3'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logWorkspace.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output oesTelemetryEventHubId string = oesPlasmaStream.id
output targetPlasmaPressureOut int = targetPlasmaPressureTorr
output maxRadialTempGradOut string = maxSubstrateRadialTempGradientKPerCm
