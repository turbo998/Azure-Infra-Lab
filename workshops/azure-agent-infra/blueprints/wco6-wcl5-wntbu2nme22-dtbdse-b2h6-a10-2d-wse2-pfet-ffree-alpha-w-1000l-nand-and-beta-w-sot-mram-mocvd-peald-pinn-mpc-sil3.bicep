// =============================================================================
// Blueprint #297 (Cycle #296 · 305-Test Milestone! · Chapter 301):
// Autonomous Electronic-Grade Ultrapure Tungsten Hexacarbonyl / Tungsten
// Pentachloride (6N5 W(CO)6 / WCl5 >= 99.99995%, Fe/Ni/Cu/Cr/Mo/Na/K/U/Th <= 0.05 ppbw,
// Alpha <= 0.0001 counts/cm2*hr) & Bis(tert-butylimido)bis(dimethylamino)tungsten
// (6N5 W(NtBu)2(NMe2)2 >= 99.99995%, Halide/Carbonyl-Free) + Di-tert-butyl Diselenide /
// Dimethylselenide (6N5 DTBDSe / DMSe >= 99.99995%) + Triethylboron / Diborane
// (6N5 TEB / B2H6 >= 99.99995%) 300mm A10/A7 Sub-1nm 2D Monolayer 2H-WSe2 p-CFET
// (SS_p = 61.2 mV/dec, mu_h = 148 cm2/V*s, p+-WSe2:V/Pt Contact Rc_p = 42 Ohm*um),
// Fluorine-Free Low-Resistivity Alpha-W 1000-Layer 3D NAND Wordline & MOL Contact
// (rho_alpha_W = 8.8 uOhm*cm @ 12nm CD via a-WBx Nucleation) & Metastable Giant-Spin-Hall
// A15 Beta-W Embedded SOT-MRAM Channel (|theta_SH| = 0.42, Jc0 = 1.65e6 A/cm2)
// MOCVD / PEALD PINN-MPC + SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for the A10 2D WSe2 p-CFET, Fluorine-Free Alpha-W 1000L NAND & Beta-W SOT-MRAM Sandbox')
param location string = resourceGroup().location

@description('Environment name')
@allowed([
  'prod-a10-2d-wse2-pfet-alpha-beta-w-sil3'
  'staging-a10-2d-wse2-pfet-alpha-beta-w-sil3'
])
param environment string = 'prod-a10-2d-wse2-pfet-alpha-beta-w-sil3'

@description('Target 2D WSe2 p-CFET, 1000L NAND Alpha-W Wordline & Beta-W SOT-MRAM Regime')
@allowed([
  'a10-2d-wse2-pfet-61p2mvdec-42ohm-1000l-alpha-w-8p8uohm-and-beta-w-sot-mram-0p42sh'
  'a10-2d-wse2-pfet-van-der-waals-pt-v-contact-42ohm-um'
  '1000l-3dnand-har-120to1-ffree-alpha-w-wordline-8p8uohm-cm'
  'a10-embedded-sot-mram-a15-beta-w-spin-hall-0p42-250ps'
])
param processRegime string = 'a10-2d-wse2-pfet-61p2mvdec-42ohm-1000l-alpha-w-8p8uohm-and-beta-w-sot-mram-0p42sh'

@description('AKS + Kata + GPU Node Pool SKU for PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

@description('Minimum 6N5 W(CO)6 / WCl5 / W(NtBu)2(NMe2)2 / DTBDSe chemical purity (%)')
param minPrecursorPurityPct string = '99.99995'

@description('Maximum room-temperature subthreshold swing SS_p for monolayer 2H-WSe2 p-CFET (mV/dec)')
param maxMonolayerWse2SubthresholdSwingMvDec string = '62.5'

@description('Maximum p-type contact resistance Rc_p for p+-WSe2:V / Pt contact (Ohm*um)')
param maxWse2PtVContactResistanceOhmUm int = 55

@description('Maximum 12nm line resistivity for Fluorine-Free Alpha-W wordline/MOL (uOhm*cm)')
param maxAlphaW12nmResistivityUohmCm string = '9.8'

@description('Minimum spin Hall angle magnitude |theta_SH| for A15 Beta-W SOT-MRAM channel')
param minBetaWSpinHallAngle string = '0.38'

@description('SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3 cabinet B2H6 trip threshold (ppbv)')
param maxCabinetDiboranePpbv string = '15.0'

var clusterName = 'aks-wco6-wcl5-2d-wse2-alpha-beta-w-${uniqueString(resourceGroup().id)}'
var kvName = 'kv-w296-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take(kvName, 24)
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'a10-2d-wse2-pfet-ffree-alpha-w-1000l-nand-and-beta-w-sot-mram-mocvd-peald-pinn-mpc'
    safetyStandard: 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    precursorPurity: '6N5-WCO6-WCl5-WNtBu2NMe22-DTBDSe-TEB-B2H6-99.99995pct'
    monolayerWse2Metrics: 'SSp-61.2mVdec-muh-148cm2Vs-Rcp-42OhmUm-IonIoff-1.9e8'
    alphaBetaWMetrics: 'AlphaW-8.8uOhmCm-12nm-F-Free-BetaW-thetaSH-0.42-Jc0-1.65e6Acm2'
    cycle: '296'
    blueprintNumber: '297'
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
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        logAnalyticsWorkspaceResourceId: null
        securityMonitoring: {
          enabled: false
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'syskata'
        count: 3
        vmSize: 'Standard_D16s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        workloadRuntime: 'KataMshvVmIsolation'
      }
      {
        name: 'pinnw296'
        count: 4
        vmSize: gpuNodeSku
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        nodeLabels: {
          'agent.azure.com/process-regime': processRegime
          'agent.azure.com/precursor-grade': '6n5-wco6-wcl5-wntbu2nme22-dtbdse-teb-b2h6'
          'agent.azure.com/min-purity-pct': minPrecursorPurityPct
          'agent.azure.com/max-wse2-ss-mv-dec': maxMonolayerWse2SubthresholdSwingMvDec
          'agent.azure.com/max-wse2-rc-ohm-um': string(maxWse2PtVContactResistanceOhmUm)
          'agent.azure.com/max-alpha-w-rho-uohm-cm': maxAlphaW12nmResistivityUohmCm
          'agent.azure.com/min-beta-w-theta-sh': minBetaWSpinHallAngle
          'agent.azure.com/max-cabinet-b2h6-ppbv': maxCabinetDiboranePpbv
          'agent.azure.com/metrology-loop': '10khz-qcl-crds-1998-1602-365cm1-sf-icp-ms-raman-pl-xrd-stfmr'
          'agent.azure.com/safety-interlock': 'semi-s2-nfpa704-osha-19101000-sil3-1oo2d-b2h6-wco6-dtbdse-kmno4-cuo-venturi'
        }
      }
    ]
  }
}

output clusterNameOut string = aksCluster.name
output keyVaultNameOut string = keyVault.name
output blueprintId string = 'blueprint-297-wco6-wcl5-wntbu2nme22-dtbdse-b2h6-a10-2d-wse2-pfet-ffree-alpha-w-1000l-nand-and-beta-w-sot-mram-sil3'
