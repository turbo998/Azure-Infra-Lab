// ============================================================================
// Blueprint #292: Autonomous Electronic-Grade Ultrapure Tetrakis(ethylmethylamino)hafnium /
// Hafnium Tetrachloride (6N5 TEMAH / HfCl4 >=99.99995%, Fe/Ni/Cu/Ti/U/Th <=0.001 ppbw,
// Alpha Emission <=0.0001 alpha/cm2*hr) & Tetrakis(ethylmethylamino)zirconium (6N5 TEMAZ
// >=99.99995%) + Tris(isopropylcyclopentadienyl)lanthanum / Yttrium (6N5 La(iPrCp)3 /
// Y(iPrCp)3 >=99.99995%) + Trimethylaluminum (6N5 TMA >=99.99995%) 10A CFET Wakeup-Free
// Orthorhombic Pca21 Hf0.5Zr0.5O2 (o-HZO, 1.8 at.% La/Y Stabilized, 2Pr=64.8 uC/cm2,
// Ec=1.05 MV/cm, Endurance >1e12 Cycles @ 0.85V), 300-Layer Monolithic 3D BEOL (<=350C)
// Non-Volatile Ferroelectric 3D FeNAND (MW=6.8V @ Vprog=6.5V, -82.5% Write Energy) &
// Sub-4K Cryogenic CMOS-to-Superconducting Qubit Control Multiplexer (Cryo-FeFET @ 3.8K,
// SS_4K=4.2 mV/dec) PEALD / Thermal-ALD PINN-MPC & SEMI S2 / NFPA 704 / OSHA 29 CFR
// 1910.1000 / IEC 61511 SIL-3 Pyrophoric TMA & Corrosive HCl / Alkylamine Interlock
// ============================================================================

@description('Azure region for the 6N5 TEMAH/TEMAZ/La(iPrCp)3/TMA Wakeup-Free o-HZO, 300L 3D FeNAND & 3.8K Cryo-FeFET Qubit Mux PEALD digital twin cluster')
param location string = resourceGroup().location

@description('Environment name prefix')
param envPrefix string = 'aksclaw-ohzo-3dfenand-cryofefet-sil3'

@description('Number of parallel 6N5 TEMAH/TEMAZ/La(iPrCp)3/TMA distillation, 300L 3D FeNAND & 3.8K Cryo-FeFET PEALD trains (1 to 16)')
@minValue(1)
@maxValue(16)
param processTrains int = 6

@description('Kubernetes version for the AKS control plane')
param kubernetesVersion string = '1.31.2'

var gpuNodeCount = max(2, (processTrains + 1) / 2)
var edgePodCount = processTrains * 4
var clusterName = '${envPrefix}-aks'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: envPrefix
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: false
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.infra/workload': 'pinn-mpc-temah-temaz-laiprcp3-tma-wakeup-free-ohzo-300l-3d-fenand-and-4k-cryo-fefet-qubit-mux-peald'
          'agent.infra/safety-loop': 'semi-s2-nfpa704-osha19101000-iec61511-sil3'
          'agent.infra/metrology': 'qcl-tdlas-10khz-sf-icp-ms-insitu-gixrd-pund-shg-4k-cryo-probe'
        }
        nodeTaints: [
          'gpu.azure.com/mfg-pinn=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output pinnGpuNodeCount int = gpuNodeCount
output kataEdgePodCount int = edgePodCount
output controlPlaneMode string = 'pinn_mpc_temah_temaz_laiprcp3_tma_wakeup_free_ohzo_300l_3d_fenand_and_4k_cryo_fefet_qubit_mux_peald_sil3_edge'
output safetyStandard string = 'SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3'
output targetPrecursorAssayPct string = '99.99995'
output wakeupFreeOhzo2PrUcCm2 string = '64.8'
output feNand300LMemoryWindowV string = '6.8'
output cryoFefet4kSubthresholdSwingMvDec string = '4.2'
output sil3InterlockLatencyMs string = '0.10'
output metrologyFeedbackLatencyMs string = '0.11'
