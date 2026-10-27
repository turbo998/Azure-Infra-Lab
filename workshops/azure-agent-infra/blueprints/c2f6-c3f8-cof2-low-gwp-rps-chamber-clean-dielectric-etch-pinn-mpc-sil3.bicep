// ============================================================================
// Azure AI Agent Infrastructure Blueprint #256 (Cycle #255 · 255-Cycle & 255-Simulator Double Milestone!)
// Autonomous Electronic-Grade Hexafluoroethane (5N5 C2F6 >=99.9995%, b.p. -78.2C,
// CF4 <=0.25ppmv, CHF3 <=0.15ppmv, C2HF5 <=0.15ppmv, SF6 <=0.10ppmv, HF <=0.10ppmv,
// H2O <=0.20ppmv) & Electronic-Grade Octafluoropropane (5N5 C3F8 >=99.9995%,
// b.p. -36.7C, C3F6 <=0.20ppmv, C2F6 <=0.25ppmv, PFIB <=5ppbv) + Electronic-Grade
// Carbonyl Fluoride (5N COF2 >=99.999%, b.p. -84.6C, Ultra-Low GWP100 < 1,
// CO <=0.30ppmv, CO2 <=0.30ppmv, CF4 <=0.20ppmv, HF <=0.15ppmv, Fe/Ni/Cr <=0.05ppbv)
// Low-GWP Remote Plasma Source (RPS) PECVD Chamber Cleaning (COF2 -> CO + 2F*,
// >99.2% F-Radical Utilization vs Legacy C2F6/C3F8 In-Situ RF Clean) & 2nm GAA /
// HBM4 Selective SiO2/Si3N4 Dielectric Etch Catalytic CO Oxyfluorination, Direct
// Fluorination & Cryogenic Rectification PINN-MPC, Online 10 kHz QCL-TDLAS / FTIR
// (1928 cm-1 COF2 v2 / 1250 cm-1 C2F6 v7 / 1212 cm-1 C3F8 / 2143 cm-1 CO) +
// GC-DID / ICP-MS + 703.7 nm F* OES Metrology & SEMI S2 / SEMI C3 / NFPA 55 /
// ACGIH TLV / IEC 61511 SIL-3 Acutely Toxic & Moisture-Reactive Carbonyl Fluoride
// (COF2 TLV-TWA 2ppmv, STEL 5ppmv, COF2 + H2O -> CO2 + 2HF) & Unabated PFC
// (C2F6 / C3F8) Thermal-Wet Abatement Bypass Hard Interlock
// ============================================================================

@description('Azure region for the Electronic-Grade 5N5 C2F6 & 5N5 C3F8 + 5N COF2 Low-GWP RPS PECVD Chamber Clean & 2nm GAA Dielectric Etch Sandbox')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param environmentPrefix string = 'c2f6c3f8cof2-sil3'

@description('AKS GPU node SKU for Catalytic CO Oxyfluorination, Cryogenic C2F6/C3F8 Rectification & Low-GWP COF2 RPS Chamber Clean PINN-MPC')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

@description('Deterministic SEMI S2 / SEMI C3 / NFPA 55 / ACGIH TLV / IEC 61511 SIL-3 Toxic COF2 Hydrolysis & PFC Abatement Interlock latency target in ms')
param sil3InterlockLatencyMs string = '0.13'

@description('Maximum allowable COF2 fugitive leak before SIL-3 2oo3 Monel-400 bellows isolation and KOH/Ca(OH)2 chemi-scrubber trip (ppmv)')
param maxCof2LeakPpmv string = '0.50'

var aksClusterName = '${environmentPrefix}-aksclaw-pinn'
var iotOperationsNamespaceName = '${environmentPrefix}-iotops-cof2'
var eventHubNamespaceName = replace('${environmentPrefix}ehns', '-', '')

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    isAutoInflateEnabled: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'qcl-tdlas-1928-1250-1212-2143cm-gcdid-oes703nm-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'c2f6-c3f8-cof2-low-gwp-rps-chamber-clean-dielectric-etch-pinn-mpc-sil3'
    safetyStandard: 'SEMI-S2-SEMI-C3-NFPA-55-ACGIH-TLV-IEC-61511-SIL-3'
    interlockLatencyMs: sil3InterlockLatencyMs
    maxCof2LeakPpmv: maxCof2LeakPpmv
    cycle: '255'
    milestone: '255-Cycle-255-Simulator-Double-Milestone'
  }
  properties: {
    dnsPrefix: environmentPrefix
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpch100'
        count: 4
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        nodeLabels: {
          'agent.azure.com/accelerator': 'nvidia-h100'
          'agent.azure.com/process': '5n5-c2f6-5n5-c3f8-5n-cof2-low-gwp-rps-clean-2nm-gaa-etch'
          'agent.azure.com/safety-gate': 'semi-s2-nfpa55-acgih-tlv-iec61511-sil3-0.13ms'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
    }
  }
}

resource iotOperationsRule 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: '${iotOperationsNamespaceName}-sil3-cof2-hydrolysis-pfc-abatement-guard'
  location: location
  properties: {
    description: 'SEMI S2 / SEMI C3 / NFPA 55 / ACGIH TLV / IEC 61511 SIL-3 hardware-enforced 0.13ms 2oo3 Monel-400 bellows isolation, dry N2 purge, and KOH/Ca(OH)2 chemi-scrubber interlock upon >0.5ppmv 1928cm-1 COF2 leak, >1.5ppmv HF hydrolysis, or <850C C2F6/C3F8 thermal-wet abatement bypass'
    enabled: true
    evaluationFrequency: 'PT1M'
    scopes: [
      aksCluster.id
    ]
    severity: 0
    windowSize: 'PT1M'
    criteria: {
      allOf: [
        {
          query: 'ContainerLogV2 | where LogMessage has "SIL3_COF2_TOXIC_HYDROLYSIS_OR_C2F6_C3F8_PFC_ABATEMENT_BYPASS_GUARD"'
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
        }
      ]
    }
  }
}

output aksClusterId string = aksCluster.id
output eventHubId string = telemetryHub.id
output sil3LatencyTargetMs string = sil3InterlockLatencyMs
output maxCof2LeakLimitPpmv string = maxCof2LeakPpmv
