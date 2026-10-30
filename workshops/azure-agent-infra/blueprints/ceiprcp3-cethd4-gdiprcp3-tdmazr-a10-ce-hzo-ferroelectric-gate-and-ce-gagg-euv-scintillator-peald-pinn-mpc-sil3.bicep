// ============================================================================
// Blueprint #303: Electronic-Grade Ultrapure Tris(isopropylcyclopentadienyl)cerium /
// Tetrakis(2,2,6,6-tetramethyl-3,5-heptanedionato)cerium (6N5 Ce(iPrCp)3 / Ce(thd)4)
// & Tris(isopropylcyclopentadienyl)gadolinium (6N5 Gd(iPrCp)3) + TDMAZr/TEMAHf + TMA
// 300mm A10/A7 Sub-0.38nm EOT Cerium-Doped Hafnium-Zirconium Oxide (Ce0.08Hf0.46Zr0.46O2)
// 10^12-Cycle Ferroelectric Gate, Cryogenic GdAlO3 ADR Micro-Cooler & High-NA EUV
// Actinic Ce3+:Gd3Al2Ga3O12 (Ce:GAGG) Wavefront Scintillator PEALD/ALA PINN-MPC + SIL-3
// ============================================================================

@description('Azure region for the AKS hybrid edge/cloud cluster')
param location string = resourceGroup().location

@description('Deployment environment name')
@allowed([
  'prod-a10-ce-hzo-ferroelectric-ce-gagg-euv-scintillator-sil3'
  'staging-ceiprcp3-gdiprcp3-tdmazr-peald-pinn-twin'
])
param environment string = 'prod-a10-ce-hzo-ferroelectric-ce-gagg-euv-scintillator-sil3'

@description('Number of parallel 300mm Ce(iPrCp)3/Gd(iPrCp)3/TDMAZr/TEMAHf/TMA PEALD & ALA reactor trains')
@minValue(1)
@maxValue(64)
param activeReactorTrains int = 8

@description('Minimum required precursor purity (%) for 6N5 Ce(iPrCp)3 / Ce(thd)4 / Gd(iPrCp)3 / TDMAZr / TEMAHf / TMA')
param minPrecursorPurityPct string = '99.99995'

@description('Target Ce0.08Hf0.46Zr0.46O2 (Ce-HZO) orthorhombic Pca21 remanent polarization 2Pr (uC/cm2)')
param targetCeHzoRemanentPolarization2PrUcCm2 string = '64.0'

@description('Maximum allowed A10 Ce-HZO gate stack Equivalent Oxide Thickness EOT (nm)')
param maxCeHzoGateEotNm string = '0.36'

@description('Minimum required High-NA EUV 13.5nm Ce3+:GAGG actinic scintillator light yield (photons/MeV)')
param minCeGaggScintillatorLightYieldPhMev int = 58000

var clusterName = 'aks-ceiprcp3-gdiprcp3-cehzo-gagg-${uniqueString(resourceGroup().id)}'
var gpuNodeCount = max(2, (activeReactorTrains + 1) / 2)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
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
    dnsPrefix: clusterName
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
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'workload/type': 'pinn-mpc-ceiprcp3-cethd4-gdiprcp3-tdmazr-a10-ce-hzo-ferroelectric-and-ce-gagg-euv-scintillator'
          'safety/tier': 'semi-s2-nfpa704-osha19101200-sil3-pyrophoric-cerium-gadolinium-tma-interlock'
          'metrology/loop': 'qcl-crds-2961p8-2973p5-948p5cm1-sficpms-pund-gixrd-xas-euvrl-10khz'
        }
        nodeTaints: [
          'dedicated=pinn-mpc-ceiprcp3-cehzo-gagg-sil3:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
  tags: {
    Environment: environment
    Cycle: '302'
    Chapter: '307-308'
    BlueprintId: '303'
    PrecursorPurity: minPrecursorPurityPct
    TargetCeHzo2PrUcCm2: targetCeHzoRemanentPolarization2PrUcCm2
    MaxCeHzoGateEotNm: maxCeHzoGateEotNm
    MinCeGaggLightYieldPhMev: string(minCeGaggScintillatorLightYieldPhMev)
    SafetyStandard: 'SEMI-S2-NFPA704-OSHA19101200-IEC61511-SIL3'
  }
}

output clusterResourceId string = aksCluster.id
output pinnMpcNodeCount int = gpuNodeCount
output safetyInterlockProfile string = 'SEMI-S2-NFPA704-OSHA19101200-IEC61511-SIL3-Pyrophoric-Ce-Gd-TMA'
output metrologyFeedbackChannel string = '10kHz-QCL-CRDS-2961.8-2973.5-948.5cm1-SFICPMS-PUND-GIXRD-XAS-EUVRL'
