// =============================================================================
// Blueprint #252: Autonomous Electronic-Grade Hexafluoropropylene Oxide (5N
// HFPO C3F6O >=99.999%, b.p. -27.4C, GWP100 <1.0, CF3CF2COF/CF3COF <=0.20ppmv,
// C3F6 <=0.30ppmv, HF <=0.15ppmv) & Trifluoroacetyl Fluoride (5N TFAF CF3COF
// >=99.999%, GWP100 <1.0) + Carbonyl Sulfide (5N5 COS O=C=S >=99.9995%, b.p.
// -50.2C, H2S <=0.10ppmv, CS2 <=0.20ppmv, CO2 <=0.30ppmv) 1000-Layer 3D NAND
// Low-GWP CF2: Radical Cryogenic Etch, EUV ACL Hardmask (AR 75:1, Bowing
// <0.6nm) & 2nm GAA Self-Aligned Contact (SAC >=42:1) PINN-MPC & SEMI S2 /
// NFPA 55 / OSHA PEL / IEC 61511 SIL-3 Exothermic HFPO Epoxide Ring-Opening
// Isomerization Runaway & Toxic COS/H2S Scrubbing Interlock
// =============================================================================
// Target Architecture:
//   - L2 Run (Cloud/Hybrid): AKS Standard_NC40ads_H100_v5 GPU pool for coupled
//     hexafluoropropylene catalytic liquid-phase epoxidation & Lewis-acid-free
//     passivated rectification (suppressing CF3CF2COF <=0.20ppmv), COS
//     extractive desulfurization rectification (H2S <=0.10ppmv, CS2 <=0.20ppmv),
//     1000-layer 3D NAND HFPO difluorocarbene (CF2:) selective etch, EUV ACL
//     75:1 hardmask COS+O2 sidewall C-S-O passivation & 2nm GAA SAC PINN-MPC.
//   - L2 Edge (Fab Sub-Fab): Azure Local ( Dell XR8620t ) running 10 kHz
//     QCL-TDLAS/FTIR (1552 cm-1 HFPO epoxide ring / 1885 cm-1 CF3COF acyl
//     fluoride / 2062 cm-1 COS v3 / 1361 cm-1 SO2), GC-SCD, OCD & SIL-3 PLC.
//   - L4 Safety: SEMI S2 / SEMI C3 / NFPA 55 / OSHA PEL / IEC 61511 SIL-3
//     0.14 ms hardware lockout for exothermic HFPO epoxide ring-opening
//     isomerization runaway (dH = -108 kJ/mol) and toxic/flammable COS/H2S
//     (IDLH 100 ppmv, LEL 12.0%) leak scrubbing.
// =============================================================================

@description('Deployment Azure region for the 5N HFPO / 5N TFAF / 5N5 COS 3D NAND & EUV ACL Etch control plane')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'hfpo5n-cos5n5-sil3'

@description('AKS node count for H100 PINN-MPC HFPO difluorocarbene & COS ACL hardmask etch solver pool')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 4

@description('Maximum allowable acyl fluoride isomer (CF3CF2COF / CF3COF) impurity in 5N HFPO in ppmv')
param maxAcylFluorideIsomerPpmv string = '0.20'

@description('Maximum allowable hydrogen sulfide (H2S) impurity in 5N5 COS in ppmv')
param maxH2sImpurityPpmv string = '0.10'

@description('Maximum allowable SIL-3 emergency lockout latency in milliseconds')
param maxSil3LockoutLatencyMs string = '0.14'

var vnetName = '${envPrefix}-vnet'
var aksName = '${envPrefix}-aks-pinn-mpc'
var kvName = '${replace(envPrefix, '-', '')}kv${uniqueString(resourceGroup().id)}'
var iotNamespaceName = '${envPrefix}-edge-qcl-scd-bus'

// -----------------------------------------------------------------------------
// 1. Zero-Trust Isolated Virtual Network (Fab Gas Box / Sub-Fab / Cloud Split)
// -----------------------------------------------------------------------------
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.251.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.251.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'edge-qcl-tdlas-gcscd-sil3-subnet'
        properties: {
          addressPrefix: '10.251.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// -----------------------------------------------------------------------------
// 2. Key Vault for Sealed Calibration & SEMI S2 / NFPA 55 SIL-3 Interlock Keys
// -----------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take(kvName, 24)
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// -----------------------------------------------------------------------------
// 3. Event Grid MQTT Namespace for 10 kHz QCL-TDLAS/FTIR, GC-SCD & OCD Edge
// -----------------------------------------------------------------------------
resource edgeTelemetryBus 'Microsoft.EventGrid/namespaces@2024-06-01-preview' = {
  name: iotNamespaceName
  location: location
  sku: {
    name: 'Standard'
    capacity: 4
  }
  properties: {
    isZoneRedundant: true
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumClientSessionsPerAuthenticationName: 16
    }
  }
  tags: {
    qclTdlasWavenumbersCm1: '1552-HFPO-Epoxide,1885-CF3COF,2062-COS-v3,1361-SO2'
    maxAcylFluorideIsomerPpmv: maxAcylFluorideIsomerPpmv
    maxH2sImpurityPpmv: maxH2sImpurityPpmv
    maxSil3LockoutLatencyMs: maxSil3LockoutLatencyMs
    safetyStandard: 'SEMI-S2-SEMI-C3-NFPA-55-OSHA-PEL-IEC-61511-SIL3'
  }
}

// -----------------------------------------------------------------------------
// 4. AKS Cluster with H100 v5 Node Pool for HFPO/TFAF/COS PINN-MPC
// -----------------------------------------------------------------------------
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'workload/pinn-mpc': 'hfpo-tfaa-cos-3dnand-lowgwp-etch-acl-hardmask'
          'safety/sil-rating': 'SEMI-S2-NFPA55-SIL-3'
          'metrology/qcl-tdlas-gcscd-hz': '10000'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      serviceCidr: '10.251.128.0/18'
      dnsServiceIP: '10.251.128.10'
    }
  }
}

output aksClusterName string = aksCluster.name
output edgeTelemetryEndpoint string = edgeTelemetryBus.properties.topicSpacesConfiguration.hostname
output sil3SafetyEnvelope object = {
  maxAcylFluorideIsomerPpmv: maxAcylFluorideIsomerPpmv
  maxH2sImpurityPpmv: maxH2sImpurityPpmv
  maxSil3LockoutLatencyMs: maxSil3LockoutLatencyMs
  interlockTopology: '2oo3 Lewis-Acid-Free Passivated Isolation + -35C Chilled Jacket Quench + KOH/Ca(OH)2 Fluoro-Mineralization & NaOH/NaOCl COS/H2S Oxidative Scrubber'
}
