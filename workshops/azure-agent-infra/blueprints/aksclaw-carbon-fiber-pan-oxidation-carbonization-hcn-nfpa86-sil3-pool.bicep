@description('Azure region for the AKSClaw Carbon-Fiber PAN Precursor Oxidation/Carbonization & NFPA 86 / SIL-3 HCN Off-Gas Interlock Pool')
param location string = resourceGroup().location

@description('Existing AKS cluster name hosting the Aerospace Carbon-Fiber T1100G/M60J Conversion Line Digital Twin control plane')
param aksClusterName string = 'aks-agent-infra-carbonfiber'

@description('VM size for the Exothermic Nitrile Cyclization, Turbostratic Graphene Orientation & Godet Tension PINN-MPC pool')
param vmSize string = 'Standard_NV36ads_A10_v5'

@description('Minimum node count for deterministic multi-zone oxidation oven & LT/HT/UHT carbonization furnace control')
@minValue(3)
param minCount int = 3

@description('Maximum node count for multi-line 12K-50K tow aerospace carbon fiber production bursts')
@minValue(6)
param maxCount int = 18

@description('Maximum oxidation tow exothermic temperature (C) before NFPA 86 / SIL-3 N2 deluge quench & tow cutter trip')
param maxOxidationTowTempC string = '295.0'

@description('Maximum ambient HCN concentration (ppm) before OSHA / SIL-3 emergency scrubber & nitrogen labyrinth boost')
param maxAmbientHcnPpm string = '4.5'

@description('Target Herman crystallite orientation factor f_c from in-line WAXS/Raman metrology')
param targetOrientationFactor string = '0.90'

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource carbonFiberPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'cfpanpool'
  properties: {
    mode: 'User'
    vmSize: vmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    enableAutoScaling: true
    minCount: minCount
    maxCount: maxCount
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'agent.azure.com/workload': 'carbon-fiber-pan-oxidation-carbonization-sil3'
      'agent.azure.com/isolation': 'kata-mshv-vm'
      'agent.azure.com/furnace-standard': 'nfpa-86-en-1539-osha-1910-iec-61511-sil3'
      'agent.azure.com/fiber-grade': 'aerospace-t1100g-m60j-turbostratic-carbon'
      'agent.azure.com/max-oxidation-tow-temp-c': maxOxidationTowTempC
      'agent.azure.com/max-ambient-hcn-ppm': maxAmbientHcnPpm
      'agent.azure.com/target-orientation-fc': targetOrientationFactor
    }
    nodeTaints: [
      'agent.azure.com/carbon-fiber-pan-oxidation-carbonization-sil3=true:NoSchedule'
    ]
    tags: {
      scenario: 'carbon-fiber-pan-oxidation-carbonization-hcn-nfpa86-sil3'
      compliance: 'NFPA-86-EN-1539-OSHA-1910-IEC-61511-SIL3'
      architecture: 'AKSClaw-Kata-CarbonFiber-PAN-WAXS-HCN-Interlock'
    }
  }
}

output poolResourceId string = carbonFiberPool.id
output complianceStandard string = 'NFPA 86 + EN 1539 + OSHA 29 CFR 1910 + IEC 61511 SIL-3'
output safetyInterlockTopology string = 'Oxidation Exotherm <295C N2 Quench + Ambient HCN <4.5 ppm + Muffle O2 <0.3% Labyrinth Boost + DFTO/RTO Off-Gas Interlock'
