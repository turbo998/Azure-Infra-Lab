// Blueprint #118: AKSClaw Direct Lithium Extraction (DLE) Brine Sorption & MCDI Pool (Chapter 122)
// Autonomous Salar/Geothermal Brine Ion-Exchange Sorption (20,000-100,000 tpa LCE), Titanium/Manganese Spinel Sieve Breakthrough & Mg/Li Selectivity PINN-MPC,
// In-Line LIBS/ICP-OES Impurity Metrology & API RP 14C / OSHA 1910 / EPA UIC / IEC 61511 SIL-3 HCl/H2S Degassing & Reinjection Wellhead Fracturing Interlock

param clusterName string = 'aksclaw-dle-lithium-sil3'
param location string = resourceGroup().location
param dleColumnTrains int = 16
param vmSize string = 'Standard_NV36ads_A10_v5'

resource dlePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/dlepool'
  properties: {
    count: max(2, (dleColumnTrains + 7) / 8)
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    nodeLabels: {
      'agent.infra/workload': 'dle-lithium-brine-sorption-libs-epauic-sil3'
      'agent.infra/dle-sieve-type': 'lmo-lto-spinel-ion-sieve-mcdi'
      'agent.infra/inline-metrology': 'libs-icp-oes-li-mg-ca-boron'
      'agent.infra/safety-interlock': 'epauic-apirp14c-iec61511-sil3-h2s-hcl-reinjection'
    }
    nodeTaints: [
      'agent.infra/dle-lithium-sil3=true:NoSchedule'
    ]
  }
}
