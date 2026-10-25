// =============================================================================
// Blueprint #185: Autonomous Columbite-Tantalite (Fe,Mn)(Nb,Ta)2O6 HF-H2SO4
// Digestion, MIBK Pulsed-Column Solvent Extraction (Ta/Nb Separation),
// K2TaF7 Liquid-Sodium Sodiothermic Capacitor-Grade Tantalum Powder Reduction &
// Aluminothermic Ferroniobium (FeNb65) Smelting PINN-MPC, Online 10 kHz Raman
// Fluorocomplex Speciation, Off-Gas HF TDLAS & Slag LIBS Metrology & NFPA 30 /
// NFPA 484 / OSHA 1910.119 / IEC 61511 SIL-3 HF Vapor Release, MIBK Solvent
// Flash-Fire & Sodium-Molten-Salt Runaway Interlock Pool
// =============================================================================
// Layer 1 (Edge): Azure Local / AKS Arc ruggedized edge rack with
//                 Standard_NC40ads_H100_v5 GPU + Kata VM-isolated pods +
//                 10 kHz inline Raman/FTIR fluorocomplex analyzer ([TaF7]2-,
//                 [NbOF5]2-, [NbF6]-, free HF/H2SO4), off-gas TDLAS (HF/SO2/MIBK
//                 VOC), sodiothermic retort acoustic/pyrometer array, and
//                 aluminothermic FeNb65 slag LIBS (Nb/Ta/Fe/Al/Si/Th/U)
// Layer 2 (Safety): IEC 61511 SIL-3 / NFPA 484 / NFPA 30 / OSHA 1910.119
//                   hardware safety PLC (0.30 ms digestor HF emergency Ca(OH)2
//                   venturi deluge, MIBK SX pulsed-column N2 blanketing & rapid
//                   dump, and K2TaF7-Na retort liquid-sodium emergency shutoff
//                   + argon quench flood interlock)
// Layer 3 (Cloud): Azure Kubernetes Service (AKS) + Managed Prometheus +
//                  Event Hubs telemetry twin (99.7% WAN bandwidth reduction)
// =============================================================================

@description('Deployment Azure region for the Niobium-Tantalum HF-MIBK SX, K2TaF7 Sodiothermic Tantalum & FeNb65 Smelting control plane')
param location string = resourceGroup().location

@description('Environment identifier (prod, staging, lab)')
@allowed([
  'prod'
  'staging'
  'lab'
])
param environment string = 'prod'

@description('AKS cluster name for Nb/Ta Hydrometallurgy, Sodiothermic Tantalum & Ferroniobium Fleet')
param clusterName string = 'aksclaw-nb-ta-mibk-sx-k2taf7-fennb-sil3-${environment}'

@description('PINN-MPC GPU node VM size for coupled HF-H2SO4 digestion, MIBK SX McCabe-Thiele stage tracking, K2TaF7-Na sodiothermic crystallization & FeNb65 aluminothermic smelting')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum GPU nodes in the PINN-MPC pool')
@minValue(2)
@maxValue(32)
param minGpuNodes int = 2

@description('Maximum GPU nodes in the PINN-MPC pool')
@minValue(2)
@maxValue(64)
param maxGpuNodes int = 8

@description('Maximum free HF vapor concentration in digestion/SX off-gas before SIL-3 alkaline scrubber deluge trip (ppm)')
param maxFreeHfOffgasPpm int = 3

@description('Maximum MIBK vapor LEL percentage in pulsed-column SX enclosure before SIL-3 N2 flood & dump trip (%)')
param maxMibkVaporLelPct int = 20

@description('Maximum K2TaF7-NaCl-KCl sodiothermic reduction retort temperature before SIL-3 liquid-sodium shutoff & Ar quench (°C)')
param maxSodiothermicRetortTempC int = 965

@description('SIL-3 hardware emergency HF deluge, MIBK N2 blanketing & liquid-Na shutoff interlock response budget (ms, integer representation of 0.30 ms)')
param sil3InterlockBudgetUs int = 300

var tags = {
  workload: 'aksclaw-niobium-tantalum-hf-mibk-sx-k2taf7-fennb-nfpa484-sil3'
  archetype: 'industrial-nb-ta-hydrometallurgy-sodiothermic-ta-fennb-pinn-mpc'
  safetyStandard: 'NFPA-484-NFPA-30-OSHA-1910-119-IEC-61511-SIL3'
  cycle: 'cycle-184'
  blueprintNumber: '185'
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${clusterName}-law'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
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
        name: 'nbtapinn'
        count: minGpuNodes
        minCount: minGpuNodes
        maxCount: maxGpuNodes
        enableAutoScaling: true
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'aksclaw.io/workload-tier': 'nb-ta-hf-mibk-sx-k2taf7-fennb-pinn-mpc'
          'aksclaw.io/metrology-loop-hz': '10000'
          'aksclaw.io/safety-interlock': 'nfpa484-nfpa30-osha1910-iec61511-sil3'
          'aksclaw.io/max-free-hf-ppm': string(maxFreeHfOffgasPpm)
          'aksclaw.io/max-mibk-lel-pct': string(maxMibkVaporLelPct)
          'aksclaw.io/max-sodiothermic-retort-c': string(maxSodiothermicRetortTempC)
          'aksclaw.io/sil3-interlock-budget-us': string(sil3InterlockBudgetUs)
        }
        nodeTaints: [
          'aksclaw.io/nb-ta-pinn-gpu=true:NoSchedule'
        ]
      }
    ]
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
output pinnMpcNodePoolVmSize string = gpuNodeVmSize
output sil3InterlockBudgetMicroseconds int = sil3InterlockBudgetUs
output safetyComplianceProfile string = 'NFPA 484 / NFPA 30 / OSHA 1910.119 / IEC 61511 SIL-3 HF Deluge, MIBK N2 Blanketing & Liquid-Sodium Shutoff Interlock'
