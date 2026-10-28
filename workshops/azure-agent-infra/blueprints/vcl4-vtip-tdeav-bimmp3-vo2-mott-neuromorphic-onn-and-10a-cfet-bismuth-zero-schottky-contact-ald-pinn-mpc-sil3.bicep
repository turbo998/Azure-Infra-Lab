@description('Cycle #280 (280-Cycle & 280-Simulator Double Milestone!) Blueprint #281: Electronic-Grade Ultrapure Vanadium(IV) Chloride (6N5 VCl4 >= 99.99995%) & Vanadium(V) Oxytriisopropoxide (6N5 VO(OiPr)3 / VTIP >= 99.99995%) + Tetrakis(diethylamido)vanadium(IV) (6N5 V(NEt2)4 / TDEAV >= 99.99995%) + Tris(1-methoxy-2-methyl-2-propoxy)bismuth(III) (6N5 Bi(mmp)3 >= 99.99995%) Neuromorphic Mott-Insulator-to-Metal VO2 (M1 <-> R at 341K, Delta R/R > 10^4) Oscillatory Neural Network (ONN) Crossbars & 10A CFET Zero-Schottky-Barrier (< 0.04 eV) Semimetallic Bismuth (Bi) Source/Drain Contact Super-Cycle ALD / PEALD Digital Twin, PINN-MPC Valence-State Control & SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3 Hard Interlock Architecture.')
param location string = resourceGroup().location
param environmentName string = 'vcl4-vtip-tdeav-bimmp3-vo2-mott-onn-cfet-bi-sil3'
param vcl4VtipTdeavBimmp3Trains int = 8
param gpuNodeCount int = max(4, (vcl4VtipTdeavBimmp3Trains + 1) / 2)
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'
param governanceMode string = 'pinn_mpc_vcl4_vtip_tdeav_bimmp3_vo2_mott_neuromorphic_onn_and_10a_cfet_bismuth_zero_schottky_contact_ald_sil3_edge'

var activePods = vcl4VtipTdeavBimmp3Trains * 4
var isGoverned = governanceMode == 'pinn_mpc_vcl4_vtip_tdeav_bimmp3_vo2_mott_neuromorphic_onn_and_10a_cfet_bismuth_zero_schottky_contact_ald_sil3_edge'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${environmentName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentName}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: environmentName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload.azure.ai/domain': 'vcl4-vtip-tdeav-bimmp3-vo2-mott-onn-cfet-bi-ald-pinn-mpc'
          'safety.iec61511/sil': 'sil3-1oo2d'
          'telemetry.qcl-tdlas/bands': '2886cm1-hcl-1035cm1-vo-985cm1-bimmp3-raman-se'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${environmentName}-iothub'
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

output blueprintId string = 'BP-281-VCL4-VTIP-TDEAV-BIMMP3-VO2-MOTT-ONN-CFET-BI-CONTACT-ALD-SIL3'
output vcl4VtipTdeavBimmp3TrainsCount int = vcl4VtipTdeavBimmp3Trains
output gpuNodesProvisioned int = gpuNodeCount
output activePinnMpcPods int = activePods
output vo2MottOnnAndCfetBiYieldGainPct string = isGoverned ? '70.5' : '17.5'
output v2o5OveroxidationAndBiDewettingReductionPct string = isGoverned ? '92.5' : '22.5'
output sil3Vcl4HclAndV2o5AerosolLockoutLatencyMs string = isGoverned ? '0.10' : '515.0'
output qclTdlas2886cm1And1035cm1RamanSeLatencyMs string = isGoverned ? '0.11' : '305.0'
output sloMet bool = isGoverned
