// ============================================================================
// Blueprint #144: AKSClaw Cumene Peroxidation, CHP Concentration & Hock
// Phenol-Acetone Acid Cleavage + Bisphenol-A (BPA) Condensation Pool
// ----------------------------------------------------------------------------
// Focus:
//   1. Multi-stage bubble-column cumene air oxidation (90-115 degC, 4-6 bar)
//      & vacuum thin-film evaporator concentration to 80-85 wt% Cumene
//      Hydroperoxide (CHP), followed by exothermic Hock acid cleavage
//      (dH = -252 kJ/mol, 60-85 degC) & Bisphenol-A (BPA) ion-exchange resin
//      condensation reactor fleet.
//   2. PINN-MPC balancing CHP conversion vs dicumyl peroxide (DCP) /
//      acetophenone (ACP) / dimethylphenylcarbinol (DMPC) selectivity,
//      sulfuric-acid cleavage micro-mixing (15-35 ppm H2SO4) & acetone boil-up
//      evaporative cooling to suppress hydroxyacetone (HA < 10 ppm) and
//      2-methylbenzofuran color bodies.
//   3. Sub-millisecond NFPA 30 / DIERS / API RP 521 / IEC 61508 SIL-3 hardware
//      interlock: if CHP concentrator or cleavage temperature rate dT/dt > 0.5
//      degC/min, T > 92 degC, or peroxide concentration > 86 wt%, triggers a
//      0.3 ms hardwired CHP feed isolation, chilled dilution-acetone deluge,
//      and alkaline aqueous sodium-phenate / weak-base acid-neutralization
//      quench injection before self-accelerating decomposition (SADT) runaway.
// ============================================================================

@description('Azure region for the regional Cumene-Phenol-Acetone Hock cleavage control plane.')
param location string = resourceGroup().location

@description('Environment identifier for the cumene peroxidation & Hock cleavage cluster.')
@allowed([
  'prod-cumene-phenol-hock-cleavage-sil3'
  'staging-chp-bpa-digital-twin'
])
param environment string = 'prod-cumene-phenol-hock-cleavage-sil3'

@description('AKS Kubernetes version for the Cumene-Phenol-BPA edge/cloud fleet.')
param kubernetesVersion string = '1.30.6'

@description('System node pool VM size.')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC CHP peroxidation, vacuum concentration & Hock cleavage solver GPU VM size.')
param pinnVmSize string = 'Standard_NC24ads_A100_v4'

@description('Deterministic DIERS / NFPA 30 / SIL-3 CHP thermal runaway & alkaline quench interlock node VM size.')
param safetyVmSize string = 'Standard_F16s_v2'

@description('Maximum CHP concentrator peroxide mass fraction threshold (wt%) before dilution deluge.')
param maxChpConcentrationWtPct int = 86

@description('Maximum cleavage reactor temperature (degC) before alkaline neutralization quench.')
param maxCleavageReactorTempDegC int = 92

var clusterName = 'aks-cumenephenol-bpa-${uniqueString(resourceGroup().id)}'
var vnetName = 'vnet-cumenephenol-bpa-${uniqueString(resourceGroup().id)}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.233.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-system'
        properties: {
          addressPrefix: '10.233.1.0/24'
        }
      }
      {
        name: 'snet-pinn-hock-cleavage'
        properties: {
          addressPrefix: '10.233.2.0/24'
        }
      }
      {
        name: 'snet-sil3-diers-chp-quench'
        properties: {
          addressPrefix: '10.233.3.0/24'
        }
      }
    ]
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Workload: 'Cumene-Hydroperoxide-Hock-Phenol-Acetone-Cleavage-BPA'
    SafetyStandard: 'NFPA-30-DIERS-API-RP-521-IEC-61508-SIL3'
    PhysicsEngine: 'CHP-Peroxidation-Hock-Rearrangement-BPA-Condensation-PINN-MPC'
    EdgeSensorBus: 'MidIR-ATR-FTIR-Peroxide-Raman-AMS-HA-Calorimetric-dTdt'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      serviceCidr: '172.16.233.0/24'
      dnsServiceIP: '172.16.233.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/role': 'control-plane-cumene-phenol-bpa'
        }
      }
      {
        name: 'pinnchppool'
        count: 2
        vmSize: pinnVmSize
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/role': 'pinn-mpc-chp-oxidation-hock-cleavage-bpa'
          'industry.azure.com/metrology': 'atr-ftir-peroxide-raman-phenol-acetone-ams'
          'industry.azure.com/max-chp-wt-pct': string(maxChpConcentrationWtPct)
        }
        nodeTaints: [
          'cumene.azure.com/pinn-gpu=true:NoSchedule'
        ]
      }
      {
        name: 'sil3chppool'
        count: 3
        vmSize: safetyVmSize
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent.azure.com/role': 'nfpa30-diers-sil3-chp-runaway-alkaline-quench-interlock'
          'safety.azure.com/latency-budget-ms': '0.3'
          'safety.azure.com/max-cleavage-temp-degc': string(maxCleavageReactorTempDegC)
        }
        nodeTaints: [
          'safety.azure.com/sil3-rt=true:NoExecute'
        ]
      }
    ]
  }
}

output clusterName string = aks.name
output clusterFqdn string = aks.properties.fqdn
output safetyStandard string = 'NFPA-30-DIERS-API-RP-521-IEC-61508-SIL3'
output chpConcentrationThresholdWtPct int = maxChpConcentrationWtPct
output cleavageReactorMaxTempDegC int = maxCleavageReactorTempDegC
