// blueprints/tma-temaz-temah-dram-zaz-highk-capacitor-gaa-hzo-ald-pinn-mpc-sil3.bicep
// Cycle #263: Electronic-Grade 6N5 TMA (Al2(CH3)6 >=99.99995%), 6N5 TEMAZ (Zr[N(CH3)(C2H5)]4 >=99.99995%) & 6N5 TEMAH (Hf[N(CH3)(C2H5)]4 >=99.99995%)
// 1c/1d DRAM HAR >75:1 ZAZ (ZrO2-Al2O3-ZrO2, k~38, EOT <0.45nm) MIM Capacitor & 2nm GAA HZO Ferroelectric/High-k Supercycle ALD PINN-MPC + SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the AKS Edge + 6N5 TMA / 6N5 TEMAZ / 6N5 TEMAH DRAM ZAZ & 2nm GAA HZO Supercycle ALD cluster')
param location string = resourceGroup().location

@description('Number of 6N5 TMA/TEMAZ/TEMAH vacuum distillation & 300mm 1c DRAM ZAZ / 2nm GAA HZO ALD production trains')
@minValue(1)
@maxValue(32)
param tmaTemazTemahTrains int = 4

@description('AKS GPU node SKU for coupled Lewis-base adduct distillation, Me2AlOMe alkoxide stripping & HAR >75:1 ZAZ/HZO supercycle ALD PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var gpuNodeCount = max(2, (tmaTemazTemahTrains + 1) / 2)
var activeAldPods = tmaTemazTemahTrains * 4

resource aksTmaTemazTemahCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-tma-temaz-temah-zaz-ald-${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'tmatemazald'
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
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'agent-infra/workload': 'tma-temaz-temah-dram-zaz-gaa-hzo-ald-pinn-mpc'
          'agent-infra/metrology': 'qcl-tdlas-10khz-1208-702-1055-982cm1-nmr-icpms-se-gixrd'
          'agent-infra/safety-interlock': 'semi-s2-nfpa704-433w-osha-psm-iec61511-sil3'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

output clusterName string = aksTmaTemazTemahCluster.name
output provisionedGpuNodes int = gpuNodeCount
output activeTmaTemazTemahPods int = activeAldPods
output sil3PyrophoricTmaMethoxideLockoutTargetMs string = '0.13'
output targetMe2AlOMeAlkoxideLimitPpmw string = '0.25'
output targetZrHfCrossContaminationLimitPpmw string = '0.50'
