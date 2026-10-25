// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #197 (Cycle #196)
// Cryogenic Air Separation Unit (ASU) Rare Noble Gas (6N Electronic-Grade
// Neon Ne, Krypton Kr & Xenon Xe) Multi-Column Rectification, Catalytic
// De-Hydrogenation / Methane Oxidation, 193nm ArF & 248nm KrF DUV Excimer
// Lithography Laser Gas Blending, 3D NAND Xe/Kr Plasma Etch Exhaust Recycling
// PINN-MPC & CGA P-8.9 / EIGA Doc 147 / NFPA 55 / SEMI S2 / IEC 61511 SIL-3
// Liquid-Oxygen (LOX) Kr/Xe Reboiler Hydrocarbon/Acetylene (C2H2/CH4/N2O)
// Freeze-Out Detonation & Cryogenic Overpressure Hard Interlock Pool
// ============================================================================

@description('Azure region for the Cryogenic ASU 6N Ne/Kr/Xe Rare Noble Gas & Excimer Lithography AKSCluster.')
param location string = resourceGroup().location

@description('Environment name tag.')
param environment string = 'prod-ne-kr-xe-cryo-asu-6n-excimer-sil3'

@description('AKS Kubernetes version.')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size.')
param systemNodeVmSize string = 'Standard_D16ds_v5'

@description('PINN-MPC GPU node pool VM size for cryogenic Ne/Kr/Xe rectification & LOX hydrocarbon detonation PINN.')
param pinnGpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum GPU nodes for Cryogenic ASU 6N Ne/Kr/Xe & excimer laser gas digital twin.')
@minValue(2)
param minGpuNodes int = 4

@description('Maximum GPU nodes for Cryogenic ASU 6N Ne/Kr/Xe & excimer laser gas digital twin.')
@maxValue(32)
param maxGpuNodes int = 16

@description('EIGA Doc 147 / CGA P-8.9 / SIL-3 LOX Kr/Xe reboiler total hydrocarbon (THC as CH4) trip threshold (ppm).')
param loxReboilerHydrocarbonTripPpm int = 450

@description('EIGA Doc 147 / SIL-3 LOX Kr/Xe sump acetylene (C2H2) freeze-out trip threshold (ppb).')
param loxReboilerAcetyleneTripPpb int = 200

@description('Target 6N electronic-grade Ne/Kr/Xe purity (99.9999% = 6N, total CF4/CH4/N2O/O2/H2O < 1000 ppb).')
param targetRareGasImpurityCapPpb int = 1000

@description('Target 3D NAND HAR Xe/Kr plasma etch exhaust closed-loop recovery rate (%).')
param targetXeKrEtchRecyclePercent int = 92

var clusterName = 'aks-nekrxe-6n-asu-excimer-sil3-${uniqueString(resourceGroup().id)}'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'neon-krypton-xenon-cryogenic-asu-6n-rare-gas-arf-krf-excimer-lithography-sil3'
    cycle: '196'
    blueprint: '197'
    safetyStandard: 'CGA-P8.9-EIGA-Doc147-NFPA-55-SEMI-S2-IEC-61511-SIL3'
    environment: environment
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
        nodeLabels: {
          'agent.azure.com/role': 'system-control-plane'
          'safety.iec61511/sil-level': 'SIL-3'
        }
      }
      {
        name: 'nekrxeasu'
        count: minGpuNodes
        vmSize: pinnGpuNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: minGpuNodes
        maxCount: maxGpuNodes
        enableEncryptionAtHost: true
        nodeLabels: {
          'agent.azure.com/workload': 'ne-kr-xe-cryogenic-asu-6n-rare-gas-excimer-laser-pinn-mpc'
          'hardware.safety/eiga147-lox-thc-trip-ppm': string(loxReboilerHydrocarbonTripPpm)
          'hardware.safety/eiga147-lox-c2h2-trip-ppb': string(loxReboilerAcetyleneTripPpb)
          'process.target/rare-gas-impurity-cap-ppb': string(targetRareGasImpurityCapPpb)
          'process.target/xe-kr-etch-recycle-pct': string(targetXeKrEtchRecyclePercent)
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
          'industrial.sil3/ne-kr-xe-asu-excimer=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output clusterFqdn string = aksCluster.properties.fqdn
output sil3SafetyProfile object = {
  standard: 'CGA P-8.9 / EIGA Doc 147 / NFPA 55 / SEMI S2 / IEC 61511 SIL-3'
  loxReboilerHydrocarbonTripPpm: loxReboilerHydrocarbonTripPpm
  loxReboilerAcetyleneTripPpb: loxReboilerAcetyleneTripPpb
  targetRareGasImpurityCapPpb: targetRareGasImpurityCapPpb
  targetXeKrEtchRecyclePercent: targetXeKrEtchRecyclePercent
  interlockLatencyMs: '0.25'
}
