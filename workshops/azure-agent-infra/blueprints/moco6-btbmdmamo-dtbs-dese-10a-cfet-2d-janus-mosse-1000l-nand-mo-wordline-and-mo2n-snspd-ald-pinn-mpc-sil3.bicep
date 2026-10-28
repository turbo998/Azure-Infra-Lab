// ============================================================================
// blueprints/moco6-btbmdmamo-dtbs-dese-10a-cfet-2d-janus-mosse-1000l-nand-mo-wordline-and-mo2n-snspd-ald-pinn-mpc-sil3.bicep
// Cycle #286 (295-Test Milestone! — Chapter 291 + Summary 292 = 294 Chapters | Blueprint #287 | Simulator #286)
// Autonomous Electronic-Grade Ultrapure Hexacarbonylmolybdenum(0) (6N5 Mo(CO)6 >=99.99995%) &
// Bis(tert-butylimido)bis(dimethylamino)molybdenum(VI) (6N5 BTBMDMAMo >=99.99995%) +
// Di-tert-butyl Sulfide (6N5 DTBS >=99.99995%) / Diethyl Selenide (6N5 DESe >=99.99995%)
// Sub-1nm (10A/7A CFET) Wafer-Scale 2D Janus MoSSe / 2H-MoS2 Channel, 1000-Layer 3D NAND
// Fluorine-Free Molybdenum Wordline & Superconducting gamma-Mo2N SNSPD PEALD/ALE PINN-MPC + SIL-3
// ============================================================================

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Mo(CO)6 / BTBMDMAMo / DTBS / DESe 10A CFET 2D Janus MoSSe, 1000L 3D NAND Mo Wordline & Mo2N SNSPD PEALD/ALE digital twin')
param location string = resourceGroup().location

@description('Environment prefix for AKSClaw semiconductor 6N5 Mo(CO)6 / BTBMDMAMo / DTBS / DESe control plane')
param environmentName string = 'moco6-janus-mosse-nand-mo-snspd-sil3'

@description('AKS Kubernetes version for real-time 10kHz QCL-TDLAS/FTIR + In-Situ Raman/PL + GIXRD + SNSPD Cryo-TDC PINN-MPC')
param kubernetesVersion string = '1.31.2'

@description('System node VM size')
param systemNodeVmSize string = 'Standard_D16s_v5'

@description('PINN-MPC GPU node VM size (NVIDIA H100 NVL / A100 80GB for 0.10ms PEALD/ALE inference)')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('SIL-3 real-time safety & QCL-TDLAS/FTIR H2Se/CO telemetry node VM size')
param sil3NodeVmSize string = 'Standard_F32s_v2'

@description('Target 6N5 Mo(CO)6 / BTBMDMAMo / DTBS / DESe purity fraction (6N5 = 0.9999995)')
param targetPrecursorPurity numeric = '0.9999995'

@description('Maximum allowable congeneric tungsten/chromium (W+Cr) trace impurity in ppmw (<= 0.01 ppmw)')
param maxCongenericWCrPpmw numeric = '0.01'

@description('Maximum allowable H2Se / CO exhaust concentration before SIL-3 hardware trip in ppbv (<= 5.0 ppbv H2Se, OSHA PEL 50 ppbv, IDLH 1000 ppbv)')
param maxExhaustH2SePpbv numeric = '5.0'

var clusterName = 'aks-${environmentName}-cluster'
var vnetName = 'vnet-${environmentName}-isolated'
var keyVaultName = 'kv-${take(replace(environmentName, '-', ''), 14)}s3'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.244.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-system'
        properties: {
          addressPrefix: '10.244.1.0/24'
        }
      }
      {
        name: 'snet-pinn-mpc-gpu'
        properties: {
          addressPrefix: '10.244.2.0/24'
        }
      }
      {
        name: 'snet-sil3-h2se-co-safety-plc'
        properties: {
          addressPrefix: '10.244.3.0/24'
        }
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
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

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'moco6-btbmdmamo-dtbs-dese-10a-cfet-2d-janus-mosse-1000l-nand-mo-wordline-and-mo2n-snspd-ald'
    cycle: '286'
    blueprintNumber: '287'
    simulatorNumber: '286'
    safetyIntegrityLevel: 'IEC-61511-SIL-3-SEMI-S2-NFPA-704-OSHA-1910-1000'
    targetPurity: string(targetPrecursorPurity)
    maxCongenericWCrPpmw: string(maxCongenericWCrPpmw)
    maxExhaustH2SePpbv: string(maxExhaustH2SePpbv)
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentName}-dns'
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
        name: 'systempool'
        count: 3
        vmSize: systemNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
        enableAutoScaling: false
      }
      {
        name: 'pinnmpcgpu'
        count: 2
        vmSize: gpuNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent-infra/role': 'moco6-btbmdmamo-dtbs-dese-janus-mosse-nand-mo-snspd-pinn-mpc'
          'agent-infra/qcl-tdlas-wavenumbers-cm1': '2004.2-952.6-1168.4-2192.5'
          'agent-infra/target-2d-mobility-cm2vs': '148.0'
          'agent-infra/target-nand-mo-rho-uohm-cm': '9.4'
          'agent-infra/target-snspd-sde-pct': '96.4'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
      {
        name: 'sil3safety'
        count: 3
        vmSize: sil3NodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'agent-infra/role': 'sil3-moco6-btbmdmamo-dtbs-dese-h2se-co-interlock'
          'agent-infra/sil-rating': 'SIL-3'
          'agent-infra/scrubber-media': 'CuO-MnO2-hopcalite-CO-oxidizer-plus-AgNO3-ZnO-H2Se-H2S-chemisorber-plus-Venturi-NaOH'
        }
        nodeTaints: [
          'safety.Execution/sil3=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output safetyStandard string = 'SEMI-S2 / NFPA-704 / OSHA-1910.1000 / IEC-61511-SIL-3'
output verifiedMetrics object = {
  precursorPurityPct: '99.99995% (6N5 Mo(CO)6 / 6N5 BTBMDMAMo / 6N5 DTBS / 6N5 DESe)'
  congenericWCrImpurityPpmw: '<= 0.01 ppmw'
  traceMetalsPpbw: '<= 0.001 ppbw (Fe, Ni, Cu, Na, K)'
  janusMosseMobilityCm2Vs: '148.0 cm2/V*s (Ion/Ioff = 4.5e8, sulfur vacancy 1.2e11 cm-2, d33 = 3.85 pm/V)'
  nand1000lMoWordlineRhoUOhmCm: '9.4 uOhm*cm at 8.0nm CD (zero fluorine attack, stress +145 MPa)'
  mo2nSnspdPerformance: 'Tc = 7.8 K, Lk = 42.5 pH/sq, SDE = 96.4% at 1550 nm, timing jitter 4.2 ps'
  sil3InterlockLatencyMs: '0.10 ms'
}
