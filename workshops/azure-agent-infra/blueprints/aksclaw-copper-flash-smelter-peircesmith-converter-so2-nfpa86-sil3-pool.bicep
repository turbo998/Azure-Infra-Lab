// =============================================================================
// Blueprint #133 (Cycle #132):
// Autonomous Oxygen-Enriched Copper Flash Smelting (Outokumpu Reaction Shaft
// 1,300 C), Flash/Peirce-Smith Matte Converting (Cu2S-FeS -> 99% Blister Copper),
// Fayalite Slag Fe/SiO2 Magnetite Control & Double-Contact Sulfuric Acid Plant
// (SO2 -> SO3) PINN-MPC, Online LIBS Matte-Grade / Optical Slag-Endpoint
// Metrology & NFPA 86 / ISO 13577 / IEC 61508 SIL-3 Water-Cooled Copper-Element
// Leak Matte-Explosion Trip, Oxygen Tuyere Burn-Back ESD & SO2 Emergency
// Scrubber Interlock Pool
// =============================================================================

@description('Azure region for the copper flash smelting & converting edge-cloud cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envName string = 'coppersmelt132'

@description('AKS Kubernetes version')
param k8sVersion string = '1.31.2'

@description('System node VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('Flash reaction-shaft sulfide combustion, fayalite slag Fe/SiO2 & acid-plant SO2 PINN-MPC GPU VM size')
param pinnGpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('NFPA 86 / ISO 13577 / IEC 61508 SIL-3 cooling-element water-leak trip & converter roll-out Kata VM size')
param safetyKataVmSize string = 'Standard_D16s_v5'

@description('Target flash furnace copper matte grade (% Cu, e.g. 64.0-68.0% Cu)')
param targetMatteGradePct string = '66.0'

@description('Target fayalite slag Fe/SiO2 mass ratio (e.g. 1.25-1.38 to suppress Fe3O4 magnetite viscosity)')
param targetFeSio2Ratio string = '1.32'

@description('Reaction shaft oxygen enrichment (% O2, e.g. 72.0-85.0% O2)')
param oxygenEnrichmentPct string = '78.0'

@description('Cooling-water differential flow leak trip threshold (L/min, SIL-3 matte-water explosion barrier)')
param coolingWaterDiffTripLpm string = '1.5'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${envName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.230.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-system'
        properties: {
          addressPrefix: '10.230.1.0/24'
        }
      }
      {
        name: 'snet-flash-matte-slag-pinn'
        properties: {
          addressPrefix: '10.230.2.0/24'
        }
      }
      {
        name: 'snet-nfpa86-cooling-sil3'
        properties: {
          addressPrefix: '10.230.3.0/24'
        }
      }
    ]
  }
}

resource aksCopperSmelter 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-${envName}-pool'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: k8sVersion
    dnsPrefix: '${envName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'smeltpinn'
        count: 4
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'workload/agent-tier': 'copper-flash-smelter-fayalite-slag-converter-so2-pinn-mpc'
          'smelter/target-matte-grade-pct': targetMatteGradePct
          'smelter/target-fe-sio2-ratio': targetFeSio2Ratio
          'smelter/oxygen-enrichment-pct': oxygenEnrichmentPct
          'metrology/edge-sensors': 'online-libs-matte-pbs-optical-emission-endpoint-uv-so2'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
      {
        name: 'nfpa86sil3'
        count: 3
        vmSize: safetyKataVmSize
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'safety/standard': 'NFPA-86-ISO-13577-IEC-61508-SIL-3'
          'safety/interlock': 'copper-jacket-water-leak-cutoff-converter-rollout-so2-scrubber'
          'cooling/water-diff-trip-lpm': coolingWaterDiffTripLpm
          'safety/latency-target-ms': '0.3'
        }
        nodeTaints: [
          'safety.sil3/isolated=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      serviceCidr: '10.230.128.0/18'
      dnsServiceIP: '10.230.128.10'
    }
  }
}

output clusterName string = aksCopperSmelter.name
output pinnPoolVmSize string = pinnGpuVmSize
output safetyStandard string = 'NFPA-86 / ISO-13577 / IEC-61508-SIL-3'
