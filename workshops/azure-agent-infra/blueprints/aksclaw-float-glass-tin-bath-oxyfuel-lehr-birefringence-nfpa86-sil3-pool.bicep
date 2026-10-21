// Blueprint #131: Autonomous Ultra-Thin Display & Architectural Float Glass Oxy-Fuel Melting Furnace (1,600 C), Molten Tin-Bath Ribbon Attenuation (1,100 -> 600 C) & Annealing Lehr Stress Birefringence PINN-MPC, Laser Moire Deflectometry & NFPA 86 / EN 746-2 / IEC 61508 SIL-3 Forming-Gas H2/O2 Purge, Crown Over-Temperature & Tin-Bath Leak Interlock Pool
targetScope = 'resourceGroup'

@description('Azure region for the float glass oxy-fuel melting furnace & molten tin-bath ribbon control pool')
param location string = resourceGroup().location

@description('Environment tier for NFPA 86 / EN 746-2 / IEC 61508 SIL-3 float glass tin-bath safety interlocks')
@allowed([
  'prod-nfpa86-en746-sil3'
  'staging-tinbath-lehr-twin'
])
param environment string = 'prod-nfpa86-en746-sil3'

@description('Float glass line throughput in metric tons per day (t/d)')
@minValue(200)
@maxValue(1200)
param pullRateTpd int = 850

@description('Target glass ribbon thickness in millimeters (mm, 0.3 mm TFT-OLED substrate to 12.0 mm architectural)')
param targetThicknessMm string = '0.50'

@description('Maximum allowable optical distortion power in millidiopters (mD)')
param maxOpticalDistortionMd string = '18.0'

var clusterName = 'aksclaw-floatglass-tinbath-${uniqueString(resourceGroup().id)}'

resource floatGlassIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${clusterName}-id'
  location: location
}

resource floatGlassAks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${floatGlassIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'syspool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'tinbathpinn'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'float-glass-tin-bath-oxyfuel-lehr-birefringence'
          'agent.azure.com/safety-standard': 'nfpa-86-en-746-2-iec-61508-sil3'
          'agent.azure.com/metrology': 'laser-moire-deflectometry-photoelastic-birefringence'
          'agent.azure.com/pull-rate-tpd': string(pullRateTpd)
          'agent.azure.com/target-thickness-mm': targetThicknessMm
        }
        nodeTaints: [
          'dedicated=float-glass-sil3:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterResourceId string = floatGlassAks.id
output safetyStandard string = 'NFPA 86 / EN 746-2 / IEC 61508 SIL-3'
output maxOpticalDistortionThresholdMd string = maxOpticalDistortionMd
output environmentTier string = environment
