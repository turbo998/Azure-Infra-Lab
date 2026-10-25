// =============================================================================
// Blueprint #184: Autonomous Vanadium-Titanomagnetite Duplex Converter Selective
// Vanadium Extraction (1,340–1,390 °C FeO·V2O3 Spinel Slag without Carbon Boil),
// Rotary-Kiln Sodium/Calcium Roasting, APV Deammoniation Fusion Flaking to 99.5%
// V2O5 & Aluminothermic Ferrovanadium (FeV80) Smelting PINN-MPC, Online 10 kHz
// Lance Acoustic / Off-Gas TDLAS / Vanadium-Slag LIBS Metrology & NFPA 86 /
// ISO 13577 / OSHA 1910.119 / IEC 61511 SIL-3 Carbon-Temperature Inversion Slop,
// Kiln Sodium-Vanadate Ringing & FeV80 Thermite Blowout Interlock Pool (Cycle #183)
// =============================================================================

@description('Azure region for the Vanadium Slag Converter & V2O5/FeV80 AKSClaw pool')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the Kata + GPU node pools')
param clusterName string = 'aksclaw-prod-cluster'

@description('GPU VM SKU for Duplex Converter Vanadium Slag, Rotary-Kiln Roasting & FeV80 Thermite PINN-MPC')
param vmSize string = 'Standard_NC40ads_H100_v5'

@minValue(2)
@maxValue(32)
@description('Initial GPU node count for vanadium extraction and FeV80 smeltingtrains')
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource vanadiumSlagPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'vanslagpool'
  properties: {
    vmSize: vmSize
    count: nodeCount
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    workloadRuntime: 'KataMshvVmIsolation'
    nodeLabels: {
      'agent.azure.com/workload': 'vanadium-slag-converter-roasting-v2o5-fev80-smelting'
      'agent.azure.com/pinn-mpc': 'duplex-converter-c-temp-inversion-kiln-roast-fev80-thermite'
      'agent.azure.com/safety-interlock': 'nfpa86-iso13577-osha1910119-sil3-0p31ms'
      'agent.azure.com/edge-metrology': '10khz-lance-acoustics-tdlas-co-nh3-slag-libs-v-ti-fe'
    }
    nodeTaints: [
      'agent.azure.com/vanadium-slag-fev80=true:NoSchedule'
    ]
    tags: {
      chapter: '188'
      cycle: '183'
      blueprint: '184'
      domain: 'vanadium-titanomagnetite-converter-roasting-v2o5-fev80'
    }
  }
}

output poolResourceId string = vanadiumSlagPool.id
output safetyStandard string = 'NFPA 86 / ISO 13577 / OSHA 1910.119 / IEC 61511 SIL-3 (0.31 ms)'
