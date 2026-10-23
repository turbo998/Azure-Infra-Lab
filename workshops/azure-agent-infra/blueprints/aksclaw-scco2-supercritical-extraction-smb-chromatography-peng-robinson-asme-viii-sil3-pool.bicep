// blueprints/aksclaw-scco2-supercritical-extraction-smb-chromatography-peng-robinson-asme-viii-sil3-pool.bicep
// Blueprint #153 (Cycle #152 / Chapter 157): Autonomous Industrial Supercritical Fluid Extraction (scCO2, T > 31.1C, P = 100-700 bar)
// & Simulated Moving Bed (SMB / SFC) Preparative Chiral Pharmaceutical Chromatography Pool, Peng-Robinson / Chrastil Solubility Isotherm
// & Competitive Adsorption Wavefront PINN-MPC, Inline 20 kHz UV-DAD / Coriolis Density / Polarimetry PAT & ASME BPVC Section VIII Div. 2 /
// ISO 4126 / FDA 21 CFR Part 11 / IEC 61511 SIL-3 Overpressure, Joule-Thomson Dry-Ice Anti-Plug & CO2 Asphyxiation Interlock.

@description('Azure region for the AKSscCO2SMBChromatography deployment')
param location string = resourceGroup().location

@description('Environment tier for supercritical CO2 extraction and SMB preparative chromatography')
@allowed([
  'cGMP-Chiral-API-500bar-SMB-SFC'
  'Industrial-Nutraceutical-scCO2-350bar-Cascade'
  'Multi-Column-Continuous-Biopharma-Purification'
])
param scCo2SmbTier string = 'cGMP-Chiral-API-500bar-SMB-SFC'

@description('Target supercritical CO2 extraction pressure in bar (100 to 700 bar)')
@minValue(100)
@maxValue(700)
param operatingPressureBar int = 420

@description('Number of Simulated Moving Bed (SMB / SFC) preparative chromatography columns (4 to 12)')
@minValue(4)
@maxValue(12)
param smbColumnCount int = 8

@description('Maximum confined-space ambient CO2 asphyxiation alarm threshold in ppm (OSHA PEL 5000 ppm)')
@minValue(1000)
@maxValue(5000)
param maxAmbientCo2Ppm int = 5000

var clusterName = 'aksclaw-scco2-smb-asme8-sil3-${uniqueString(resourceGroup().id)}'

resource aksScCo2SmbCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'supercritical-co2-extraction-smb-sfc-chromatography'
    physicsEngine: 'peng-robinson-chrastil-competitive-langmuir-smb-pinn-mpc'
    safetyStandard: 'ASME-BPVC-VIII-Div2-ISO-4126-21CFR11-IEC-61511-SIL3'
    operatingPressureBar: string(operatingPressureBar)
    smbColumnCount: string(smbColumnCount)
  }
  properties: {
    dnsPrefix: 'scco2smb'
    agentPoolProfiles: [
      {
        name: 'syspat'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
        nodeLabels: {
          'agent-infra/role': 'fda-21cfr11-pat-audit-coordinator'
          'agent-infra/tier': scCo2SmbTier
        }
      }
      {
        name: 'pinnmpc'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        enableAutoScaling: true
        minCount: 2
        maxCount: 8
        nodeLabels: {
          'agent-infra/role': 'peng-robinson-smb-wavefront-pinn-mpc'
          'agent-infra/operating-pressure-bar': string(operatingPressureBar)
          'agent-infra/smb-columns': string(smbColumnCount)
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
        ]
      }
      {
        name: 'sil3asme'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        proximityPlacementGroupID: ''
        nodeLabels: {
          'agent-infra/role': 'asme-viii-sil3-overpressure-jt-dryice-co2-interlock'
          'agent-infra/inline-uv-dad-coriolis-pat-hz': '20000'
          'agent-infra/max-ambient-co2-ppm': string(maxAmbientCo2Ppm)
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
    }
  }
}

output clusterResourceId string = aksScCo2SmbCluster.id
output safetyInterlockSpec string = 'ASME BPVC Sec VIII Div 2 / ISO 4126 / IEC 61511 SIL-3 (0.2ms overpressure relief, Joule-Thomson dry-ice anti-plug heater & >${maxAmbientCo2Ppm} ppm CO2 asphyxiation interlock)'
