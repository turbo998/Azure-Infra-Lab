// blueprints/scmecp3-sciprcp3-tma-eriprcp3-ymecp3-alscn-3d-fefet-6g-baw-er-y2o3-quantum-peald-pinn-mpc-sil3.bicep
// Cycle #273 — Blueprint #274: Electronic-Grade 6N5 Sc(MeCp)3 / 6N5 Sc(iPrCp)3 + 6N5 TMA + 6N5 Er(iPrCp)3 / 6N5 Y(MeCp)3
// 300mm BEOL 3D FeFET/FeRAM Al1-xScxN (2Pr > 220 uC/cm2) & 6G FR3 XBAW RF Filter + Telecom C-Band 1536nm Er3+:Y2O3/Si3N4 Quantum-Photonic PEALD/MOCVD PINN-MPC & SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Sc/Al/Er/Y PEALD/MOCVD digital twin & SIL-3 edge control plane')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'alscn-ery2o3-c273'

@description('Number of Sc(MeCp)3 / Sc(iPrCp)3 / TMA / Er(iPrCp)3 / Y(MeCp)3 distillation & 300mm PEALD/MOCVD reactor trains')
@minValue(1)
@maxValue(64)
param scmecp3TmaEriprcp3Trains int = 8

@description('Target 6N5 Sc(MeCp)3 / Sc(iPrCp)3 / TMA / Er(iPrCp)3 purity (%)')
param precursorPurityPct string = '99.99995'

@description('Target Al1-xScxN remanent polarization 2Pr (uC/cm2) and Er3+:Y2O3 1536nm quantum optical coherence T2 (ms)')
param target2PrAndCoherenceT2 string = '2Pr>220uC/cm2_Ec=3.8MV/cm_AOG<0.02um-2_Er_T2>4.2ms@1.5K'

@description('SIL-3 pyrophoric TMA / lanthanide metallocene & heated ampoule lockout threshold')
param sil3LockoutPolicy string = '2oo3_DBB_Line_O2_H2O>0.2ppmv_or_Ampoule>155C_or_NH3>20ppmv_0.13ms'

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
          'workload/pinn-mpc': 'scmecp3-sciprcp3-tma-eriprcp3-ymecp3-alscn-ery2o3-peald'
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
output trainedReactors int = scmecp3TmaEriprcp3Trains
output targetMetrics string = target2PrAndCoherenceT2
output safetyInterlockSpec string = sil3LockoutPolicy
