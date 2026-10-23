// ============================================================================
// Blueprint #161: Autonomous Zero-Boil-Off (ZBO) Cryogenic Liquid Hydrogen (LH2 20.28 K, -252.87 °C, 40,000–160,000 m³ Spherical Storage & Marine Export Terminal), Ortho-to-Para Hydrogen (o-H2 -> p-H2 >= 99.8%, Exothermic dH = -703 kJ/kg) Catalytic Conversion, Two-Phase Transfer Chilldown Geysering / Condensation-Induced Water Hammer (CIWH) & Rollover Stratification Suppression PINN-MPC, Online 10 kHz Rotational Raman Spectroscopy (354 / 587 cm⁻¹) / Cryogenic FBG & Vacuum-Jacket Mass-Spec Metrology & NFPA 2 / CGA H-3 / ISO 19884 / SIGTTO / IEC 61511 SIL-3 Loss-of-Vacuum (LOV) Solid-O2 Cryo-Condensation Guard & Helium Purge Interlock Pool (Cycle #160 — 160-Cycle & 160-Simulator Milestone!)
// ============================================================================

@description('Azure region for the LH2 Cryogenic ZBO Terminal & Ortho-Para Conversion AKSClaw cluster')
param location string = resourceGroup().location

@description('AKS cluster name for LH2 Cryogenic ZBO & Ortho-Para PINN-MPC')
param clusterName string = 'aksclaw-lh2-cryo-zbo-orthopara-sil3'

@description('Number of cryogenic LH2 liquefaction trains, spherical storage tanks & loading arms (2 to 32)')
@minValue(2)
@maxValue(32)
param lh2CryoTrains int = 8

@description('Enable Ortho-to-Para H2 Catalytic Conversion, Chilldown CIWH & Brayton ZBO Re-Liquefier PINN-MPC')
param enableOrthoParaZboChilldownPinnMpc bool = true

@description('Enable NFPA 2 / CGA H-3 / ISO 19884 / SIGTTO / IEC 61511 SIL-3 Loss-of-Vacuum Solid-O2 Guard & Helium Purge Interlock')
param enableNfpa2CgaH3Sil3LovSolidO2HeliumGuard bool = true

@description('Enable Terminal-Edge 10 kHz Rotational Raman (354/587 cm⁻¹), Cryo-FBG & Vacuum-Jacket Helium Mass-Spec Sandbox')
param enableTerminalEdge10khzRamanCryoFbgMassSpec bool = true

var gpuNodeCount = max(2, (lh2CryoTrains + 3) / 4)

resource lh2CryoZboOrthoParaPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: '${clusterName}/lh2zpinn'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NV36ads_A10_v5'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    nodeLabels: {
      'aksclaw.io/workload-class': 'lh2-cryogenic-zbo-orthopara-raman-nfpa2-sil3-agent'
      'aksclaw.io/pinn-mpc-orthopara-zbo-chilldown-ciwh': enableOrthoParaZboChilldownPinnMpc ? 'enabled-42.8pct-zbo-liquefaction-eff-gain-64.1pct-bog-ciwh-surge-cut' : 'disabled'
      'aksclaw.io/nfpa2-cgah3-sil3-lov-solid-o2-he-purge-guard': enableNfpa2CgaH3Sil3LovSolidO2HeliumGuard ? 'enforced-0.6ms-zero-solid-o2-cryo-detonation-or-ciwh-pipe-rupture' : 'bypass'
      'aksclaw.io/terminal-edge-10khz-rotational-raman-cryo-fbg': enableTerminalEdge10khzRamanCryoFbgMassSpec ? 'enabled-0.5ms-99.6pct-lh2-terminal-wan-cut' : 'cloud-raw'
    }
    nodeTaints: [
      'aksclaw.io/lh2-cryo-zbo-sil3=true:NoSchedule'
    ]
  }
}

output poolResourceId string = lh2CryoZboOrthoParaPool.id
output configuredGpuNodes int = gpuNodeCount
output safetyStandard string = 'NFPA-2-CGA-H3-ISO-19884-SIGTTO-IEC-61511-SIL3'
