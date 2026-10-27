// ============================================================================
// Blueprint #251 (Cycle #250 — 250-Cycle & 250-Simulator Milestone!):
// Autonomous Electronic-Grade Nitrous Oxide (5N5 N2O >=99.9995%, b.p. -88.48C,
// NO <=0.10ppmv, NO2 <=0.05ppmv, NH3 <=0.10ppmv, CO <=0.15ppmv, H2O <=0.20ppmv)
// & Electronic-Grade Nitric Oxide (5N NO >=99.999%, b.p. -151.7C, NO2/N2O4 <=0.20ppmv,
// N2O <=0.50ppmv, CO2 <=0.30ppmv) + Isotopically Enriched Deuterated Ammonia
// (5N5 ND3 >=99.9995%, D Isotopic Enrichment >=99.90at%) 8G+ OLED/MicroLED IGZO
// & Low-Temp SiO2/SiON PECVD Oxygen-Vacancy Passivation, 1200V/1700V 4H-SiC MOSFET
// (1280C NO Post-Oxidation Annealing POA SiC/SiO2 Carbon-Cluster Passivation,
// Dit <=1.5e11 cm-2eV-1, mu_FE >=42 cm2/Vs) & 2nm GAA Si-D Giant Kinetic Isotope
// Effect (KIE 45x) Hot-Carrier/BTI Immunity Anneal Cryogenic Rectification PINN-MPC,
// Online 10 kHz QCL-TDLAS / FTIR (2224 cm-1 N2O / 1876 cm-1 NO / 1617 cm-1 NO2 /
// 2420 cm-1 N-D) + CRDS + In-Line CV/DLTS Metrology & SEMI S2 / SEMI C3 / CGA G-8.3 /
// NFPA 55 / OSHA PEL / IEC 61511 SIL-3 High-Pressure N2O Exothermic Self-Sustaining
// Decomposition Explosion & Toxic Oxidizer NO/NO2 (NO IDLH 100ppmv, NO2 IDLH 13ppmv)
// Scrubbing Hard Interlock
// ============================================================================

@description('Azure region for the Electronic-Grade 5N5 N2O, 5N NO & 5N5 ND3 IGZO PECVD, SiC Gate POA & 2nm GAA Deuterium Anneal AI Agent Infra')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param environmentPrefix string = 'n2o-no-nd3-sic-poa-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Target 5N5 N2O chemical purity (%)')
param targetN2oPurityPct string = '99.9995'

@description('Maximum NO2/N2O4 impurity in 5N NO (ppmv)')
param maxNo2ImpurityPpmv string = '0.20'

@description('Maximum SiC/SiO2 interface trap density Dit after NO POA (cm^-2 eV^-1)')
param maxSicGateDitPerCm2Ev string = '1.5e11'

@description('SIL-3 high-pressure N2O exothermic decomposition & toxic NO/NO2 leak interlock latency target (ms)')
param sil3InterlockLatencyMs string = '0.14'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: '${environmentPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.251.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-h100-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.251.1.0/24'
        }
      }
      {
        name: 'azure-local-sil3-edge-subnet'
        properties: {
          addressPrefix: '10.251.2.0/24'
        }
      }
      {
        name: 'qcl-tdlas-crds-cv-dlts-subnet'
        properties: {
          addressPrefix: '10.251.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'n2o-no-nd3-igzo-pecvd-and-sic-gate-poa-pinn-mpc'
    targetN2oPurityPct: targetN2oPurityPct
    maxNo2ImpurityPpmv: maxNo2ImpurityPpmv
    maxSicGateDitPerCm2Ev: maxSicGateDitPerCm2Ev
    sil3InterlockLatencyMs: sil3InterlockLatencyMs
    safetyStandard: 'SEMI-S2-SEMI-C3-CGA-G8.3-NFPA-55-OSHA-PEL-IEC-61511-SIL3'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16ds_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'h100pinn'
        count: 4
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent-infra/role': 'n2o-no-nd3-igzo-pecvd-sic-gate-poa-pinn-mpc'
          'agent-infra/metrology': 'qcl-tdlas-2224-1876-1617-2420cm1-crds-cv-dlts'
          'agent-infra/safety': 'cga-g8-3-nfpa55-sil3-n2o-decomp-no-no2-scrubber'
        }
      }
      {
        name: 'katasbx'
        count: 6
        vmSize: 'Standard_D64s_v6'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${replace(environmentPrefix, '-', '')}ehns251'
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 4
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }
}

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'qcl-tdlas-2224-1876-1617-2420cm1-crds-cv-dlts-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

output aksClusterName string = aksCluster.name
output pinnMpcTargetN2oPurityPct string = targetN2oPurityPct
output maxSicGateDitTarget string = maxSicGateDitPerCm2Ev
output sil3InterlockGateMs string = sil3InterlockLatencyMs
