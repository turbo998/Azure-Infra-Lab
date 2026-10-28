// blueprints/wco6-btbmdmaw-dtbdse-teb-10a-cfet-2d-wse2-pfet-dram-bwl-alpha-w-and-sot-mram-beta-w-ald-pinn-mpc-sil3.bicep
// Cycle #287 (295-Chapter Milestone! — Chapter 292 + Summary 293 = 295 Chapters, Blueprint #288, Simulator #287):
// Autonomous Electronic-Grade Ultrapure Hexacarbonyltungsten(0) (6N5 W(CO)6 >=99.99995%, Mo/Cr<=0.01ppmw, Fe/Ni/Cu<=0.001ppbw, U/Th<=0.0005ppbw, F-/Cl-<=0.01ppmw)
// & Bis(tert-butylimido)bis(dimethylamino)tungsten(VI) (6N5 BTBMDMAW >=99.99995%) + Di-tert-butyl Diselenide (6N5 DTBDSe >=99.99995%) / Triethylborane (6N5 TEB >=99.99995%)
// Sub-1nm (10A/7A CFET) Complementary 2D Monolayer 2H-WSe2 (mu_p=162cm2/V*s, Ion/Ioff=5.2e8, V_Se=1.1e11cm-2) p-FET Nanosheet Channel,
// 1c/0a DRAM Fluorine-Free Buried Wordline (bWL) Low-Resistivity alpha-W (rho=8.8 uOhm*cm @ 9nm CD, 0% WF6 Fluorine Attack) & Giant Spin-Hall-Angle beta-W (theta_SH=-0.42, Jc0=1.4e6 A/cm2) SOT-MRAM PEALD/CVD PINN-MPC + SIL-3

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 W(CO)6 / BTBMDMAW / DTBDSe / TEB 10A CFET 2D WSe2 p-FET, DRAM bWL alpha-W & SOT-MRAM beta-W PEALD/CVD digital twin')
param location string = resourceGroup().location

@description('Environment name (prod-10a-wse2-pfet-dram-bwl-sot-mram-sil3 or staging-w-se-b-ald)')
@allowed([
  'prod-10a-wse2-pfet-dram-bwl-sot-mram-sil3'
  'staging-w-se-b-ald'
])
param environment string = 'prod-10a-wse2-pfet-dram-bwl-sot-mram-sil3'

@description('AKS node pool VM size for PINN-MPC 2D 2H-WSe2 p-FET, DRAM bWL alpha-W & SOT-MRAM beta-W solver')
param pinnGpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Minimum Electronic-Grade 6N5 W(CO)6 / 6N5 BTBMDMAW / 6N5 DTBDSe / 6N5 TEB assay (%)')
param minWco6BtbmdmawDtbdseTebAssayPct string = '99.99995'

@description('Maximum congeneric Mo/Cr impurity in 6N5 W(CO)6 / BTBMDMAW (ppmw)')
param maxMoCrImpurityPpmw string = '0.01'

@description('Maximum trace Fe/Ni/Cu/Na and F-/Cl- in 6N5 W(CO)6 (ppbw / ppmw)')
param maxTraceMetalPpbwAndHalidePpmw string = '0.001 / 0.01'

@description('Target 10A CFET monolayer 2H-WSe2 p-FET hole mobility (cm2/V*s) and selenium vacancy density (cm-2)')
param targetWse2HoleMobilityAndVse string = '162.0 / 1.1e11'

@description('Target 1c/0a DRAM buried wordline fluorine-free alpha-W resistivity at 9.0nm CD (uOhm*cm) and SOT-MRAM beta-W Spin-Hall angle')
param targetDramAlphaWResistivityAndBetaWSpinHall string = '8.8 / -0.42'

@description('SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3 H2Se (ppbv) & pyrophoric TEB / CO (ppmv) trip thresholds')
param maxH2seExhaustPpbvAndCoPpmv string = '5.0 / 5.0'

var clusterName = 'aks-wco6-wse2-dram-bwl-sot-${uniqueString(resourceGroup().id)}'
var workspaceName = 'law-wco6-wse2-dram-bwl-sot-${uniqueString(resourceGroup().id)}'
var iotHubName = 'iothub-wco6-wse2-dram-sot-${uniqueString(resourceGroup().id)}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
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
    Workload: 'Electronic-Grade-6N5-WCO6-BTBMDMAW-DTBDSe-TEB-10A-CFET-2D-WSe2-pFET-DRAM-bWL-Alpha-W-and-SOT-MRAM-Beta-W'
    PrecursorPurity: '6N5-99.99995pct-Mo-Cr-le-0.01ppmw-Fe-Ni-Cu-le-0.001ppbw-F-Cl-le-0.01ppmw'
    SafetyStandard: 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-1910.1000-IEC-61511-SIL3'
    Cycle: '287'
    BlueprintNumber: '288'
    Milestone: '295-Chapter-Milestone'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: pinnGpuVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'agent-infra/role': 'wco6-btbmdmaw-dtbdse-teb-2d-wse2-pfet-dram-bwl-sot-mram-pinn-mpc'
          'agent-infra/precursor-grade': '6N5-99.99995pct'
        }
      }
      {
        name: 'sil3edgepool'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent-infra/role': 'qcl-tdlas-icpms-raman-gixrd-moke-h2se-teb-co-sil3-interlock'
          'agent-infra/sil-rating': 'SIL-3-1oo2D-DBB-AllMetal-AgNO3-ZnO-CuO-MnO2-Scrubber'
        }
      }
    ]
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output wco6BtbmdmawDtbdseTebSpec object = {
  environment: environment
  minWco6BtbmdmawDtbdseTebAssayPct: minWco6BtbmdmawDtbdseTebAssayPct
  maxMoCrImpurityPpmw: maxMoCrImpurityPpmw
  maxTraceMetalPpbwAndHalidePpmw: maxTraceMetalPpbwAndHalidePpmw
  targetWse2HoleMobilityAndVse: targetWse2HoleMobilityAndVse
  targetDramAlphaWResistivityAndBetaWSpinHall: targetDramAlphaWResistivityAndBetaWSpinHall
  maxH2seExhaustPpbvAndCoPpmv: maxH2seExhaustPpbvAndCoPpmv
  qclTdlasWavenumbersCm1: '1998.4 (W(CO)6 C=O) / 956.2 (BTBMDMAW W=N-tBu) / 1154.8 (DTBDSe C-Se) / 2192.5 (H2Se Se-H)'
  sil3InterlockLatencyMs: '0.10'
}
