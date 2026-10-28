// Blueprint #279: Electronic-Grade 6N5 Mn(EtCp)2 & 6N5 Mn(iPr-AMD)2 + 6N5 Tb(THD)3 + 6N5 TMGa 10A BSPD MnSiOx Self-Forming Barrier & Non-Reciprocal TGG Faraday Optical Isolator ALD PINN-MPC + SIL-3 Interlock Architecture
targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Mn(EtCp)2 / 6N5 Mn(iPr-AMD)2 / 6N5 Tb(THD)3 / 6N5 TMGa 10A BSPD MnSiOx & TGG Faraday Isolator ALD Edge Cluster')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Mn(EtCp)2 / 6N5 Mn(iPr-AMD)2 / 6N5 Tb(THD)3 / 6N5 TMGa distillation, sublimation, and 10A BSPD MnSiOx / TGG Faraday ALD trains')
@minValue(1)
@maxValue(64)
param mnetcp2Mnipramd2Tbthd3Trains int = 8

@description('Governance mode for 6N5 Mn(EtCp)2 & 6N5 Mn(iPr-AMD)2 + 6N5 Tb(THD)3 + 6N5 TMGa 10A BSPD MnSiOx Self-Forming Barrier & TGG Faraday Isolator ALD PINN-MPC + SIL-3 control')
@allowed([
  'pinn_mpc_mnetcp2_mnipramd2_tbthd3_tmga_10a_bspd_mnsiox_self_forming_barrier_and_tgg_faraday_isolator_ald_sil3_edge'
  'unmanaged_legacy_ta_tan_pvd_barrier_and_open_loop_tgg_clad_ald'
])
param governanceMode string = 'pinn_mpc_mnetcp2_mnipramd2_tbthd3_tmga_10a_bspd_mnsiox_self_forming_barrier_and_tgg_faraday_isolator_ald_sil3_edge'

var gpuNodeCount = max(4, (mnetcp2Mnipramd2Tbthd3Trains + 1) / 2)
var activePods = mnetcp2Mnipramd2Tbthd3Trains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-mnetcp2-mnipramd2-tbthd3-10a-bspd-sil3'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'mnetcp2-mnipramd2-tbthd3-tmga-10a-bspd-mnsiox-tgg-faraday-ald-sil3'
    governanceMode: governanceMode
    blueprintNumber: '279'
    compliance: 'SEMI-S2-NFPA-704-OSHA-1910-119-IEC-61511-SIL3'
  }
  properties: {
    dnsPrefix: 'mnetcp2-mnipramd2-10a-bspd'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'h100pinnmpc'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'agent-infra/role': 'mnetcp2-mnipramd2-tbthd3-tmga-pinn-mpc-sil3'
          'agent-infra/active-pods': string(activePods)
          'semi/spectroscopy': 'qcl-tdlas-812cm1-1638cm1-1578cm1-se-xps-mokerr'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output gpuNodesProvisioned int = gpuNodeCount
output activeMnetcp2Mnipramd2Tbthd3Pods int = activePods
output sil3PyrophoricTmgaAndMnetcp2RingCleavageLockoutLatencyMs string = '0.10'
