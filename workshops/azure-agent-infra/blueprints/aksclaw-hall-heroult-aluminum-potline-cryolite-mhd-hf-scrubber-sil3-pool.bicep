// ============================================================================
// Blueprint #137: Autonomous Primary Aluminum Hall-Héroult 500-600 kA
// Cryolite-Alumina Reduction Potline (960 C Na3AlF6-AlF3-CaF2-Al2O3 MHD
// Metal-Pad Roll Instability, Ledge Freeze Toe & Anode-Effect CF4/C2F6
// Suppression PINN-MPC), Online Individual Anode-Rod Fiber-Bragg Current /
// Bath Ratio Raman Metrology & NFPA 70E / ISO 13849 / IEC 61508 SIL-3 Pot
// Tap-Out Molten Aluminum-Water Explosion, Open-Circuit Potline Arc-Flash &
// HF Dry-Alumina Gas Treatment Center (GTC) Interlock Pool (AKSClaw + Kata)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the Hall-Héroult Aluminum Potline Edge-Cloud Sandbox')
param location string = resourceGroup().location

@description('Environment name (prod-hall-heroult-potline-sil3)')
param environmentName string = 'prod-hall-heroult-potline-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Potline DC busbar amperage (kA, 400-600 kA prebaked / inert-anode cells)')
param potlineAmperageKa int = 550

@description('Target cryolite bath ratio (NaF/AlF3 weight ratio, 1.08-1.15)')
param targetBathRatio string = '1.11'

@description('Target bath temperature & superheat (958 C / +8 C above liquidus)')
param targetSuperheatC int = 8

@description('NFPA 70E / ISO 13849 / IEC 61508 SIL-3 hardware interlock response budget (ms)')
param sil3InterlockBudgetMs string = '0.3'

var clusterName = 'aks-aksclaw-alpotline-${environmentName}'

resource alPotlineAksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'alpotpinn'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'OCIContainer'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/domain': 'hall-heroult-aluminum-potline-cryolite-mhd-gtc'
          'agent.azure.com/pinn-solver': 'sele-mhd-metal-pad-roll-sidewall-ledge-alumina-dissolution'
          'agent.azure.com/metrology': '40-anode-rod-fbg-hall-shunt-shell-ir-laser-hf-open-path'
        }
        nodeTaints: [
          'sku=gpu-alpotline-pinn:NoSchedule'
        ]
      }
      {
        name: 'sil3alpot'
        count: 3
        vmSize: 'Standard_F16s_v2'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/safety-standard': 'NFPA-70E-ISO-13849-OSHA-1910-IEC-61508-SIL3'
          'agent.azure.com/interlock-budget-ms': sil3InterlockBudgetMs
          'agent.azure.com/potline-amperage-ka': string(potlineAmperageKa)
          'agent.azure.com/target-bath-ratio': targetBathRatio
          'agent.azure.com/target-superheat-c': string(targetSuperheatC)
        }
        nodeTaints: [
          'safety=nfpa70e-iso13849-sil3-hard-interlock:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = alPotlineAksCluster.id
output sil3InterlockContract object = {
  standard: 'NFPA 70E / ISO 13849 / OSHA 1910 / IEC 61508 SIL-3'
  maxInterlockLatencyMs: sil3InterlockBudgetMs
  maxSteelCradleShellHotspotLimitC: '430 C (hard pneumatic air-jet cooling + pot shorting wedge switch preparation)'
  potlineOpenCircuitVoltageLimitV: '1,650 V DC Series Busbar Arc-Flash Wedge Bypass Interlock'
  rooflineHfEmissionLimitPpm: '0.5 ppm HF (Dry-Alumina Gas Treatment Center GTC Emergency Draft Boost)'
}
