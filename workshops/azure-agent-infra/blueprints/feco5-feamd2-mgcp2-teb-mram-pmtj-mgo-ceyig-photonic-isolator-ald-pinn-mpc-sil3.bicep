// blueprints/feco5-feamd2-mgcp2-teb-mram-pmtj-mgo-ceyig-photonic-isolator-ald-pinn-mpc-sil3.bicep
// Cycle #274 (275-Blueprint Milestone!) — Blueprint #275: Electronic-Grade 6N5 Fe(CO)5 & 6N5 Fe(iPr-AMD)2 + 6N5 Mg(Cp)2 / Mg(EtCp)2 + 6N5 TEB
// 300mm eSTT-MRAM / SOT-MRAM p-MTJ (CoFeB/MgO/CoFeB TMR > 265%) & 1.6T/3.2T CPO Silicon-Integrated Ce:YIG Non-Reciprocal Optical Isolator Super-Cycle PEALD PINN-MPC & SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Fe(CO)5 / Fe(iPr-AMD)2 / Mg(Cp)2 / TEB PEALD digital twin & SIL-3 edge control plane')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'mram-ceyig-c274'

@description('Number of Fe(CO)5 / Fe(iPr-AMD)2 / Mg(Cp)2 / TEB distillation & 300mm p-MTJ / Ce:YIG PEALD reactor trains')
@minValue(1)
@maxValue(64)
param feco5Feamd2Mgcp2TebTrains int = 8

@description('Target 6N5 Fe(CO)5 / Fe(iPr-AMD)2 / Mg(Cp)2 / TEB purity (%)')
param precursorPurityPct string = '99.99995'

@description('Target p-MTJ TMR (%) and Ce:YIG 1550nm Faraday rotation (deg/cm)')
param targetTmrAndFaradaySpec string = 'TMR>265pct_RA=3.2Ohm_um2_Jc0<1.8MA_cm2_CeYIG_ThetaF>-4800deg_cm_Iso>32dB'

@description('SIL-3 toxic Fe(CO)5 / CO and pyrophoric TEB lockout threshold')
param sil3LockoutPolicy string = '2oo3_DBB_FeCO5>15ppbv_or_CO>10ppmv_or_TEB_Flame_0.13ms'

resource aksPinnsandbox 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks-pinn-mpc'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-aks'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'h100pinnpool'
        count: 4
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'workload/pinn-mpc': 'feco5-feamd2-mgcp2-teb-mram-pmtj-mgo-ceyig-isolator-ald'
          'safety/interlock': 'semi-s2-nfpa704-osha-psm-iec61511-sil3'
          'precursor/purity': precursorPurityPct
        }
      }
    ]
  }
}

resource iotHubMetrology 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub-10khz'
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
      defaultTtlAsIso8601: 'PT1H'
      maxDeliveryCount: 10
    }
  }
}

resource keyVaultHsm 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${envPrefix}-kv-sil3'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
  }
}

output clusterName string = aksPinnsandbox.name
output trainedReactors int = feco5Feamd2Mgcp2TebTrains
output targetMetrics string = targetTmrAndFaradaySpec
output safetyInterlockSpec string = sil3LockoutPolicy
