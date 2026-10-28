// =============================================================================
// Blueprint #271 (Cycle #270 — 270-Cycle & 270-Simulator Double Milestone!)
// Autonomous Electronic-Grade Bis(cyclopentadienyl)magnesium (6N5 Cp2Mg
// >=99.99995%, Sublimation 55C @ 0.5Torr, CpMg(OR) <=0.03ppmw, Fe(Cp)2
// <=0.02ppmw, Si/Zn <=0.01ppbw) & Triethylgallium / Trimethylgallium (6N5
// TEGa / TMGa >=99.99995%, Carbon-Free beta-Hydride Elimination) +
// Trimethylindium (6N5 TMIn >=99.99995%, Solution-TMIn Pickup Stability
// <+-0.15%) + Trimethylaluminum (6N5 TMA >=99.99995%) 8-Inch (200mm)
// GaN-on-Si / GaN-on-SiC (1200V/650V) E-Mode p-GaN Gate AlGaN/GaN HEMT
// (2DEG ns >1.15e13 cm-2, mu >2150 cm2/V-s, Ron,dyn/Ron,stat <1.08,
// Vth = 1.85 +-0.04V) & Micro-LED (<5um Pixel Pitch, EQE >38%) InGaN/GaN
// MQW MOCVD Multi-Stage Zone-Refining Sublimation, Mg Memory-Effect
// Suppression (<1.5nm/dec), Gas-Phase Adduct Prevention & PINN-MPC, Online
// 10kHz QCL-TDLAS/UV-Epison/FTIR + ICP-MS + In-Situ LayTec EpiCurveTT
// Bow/Reflectance & HR-XRD Metrology & SEMI S2 / SEMI C3 / NFPA 704 /
// OSHA PSM / IEC 61511 SIL-3 Pyrophoric Group-III Metalorganics, NH3
// (IDLH 300ppmv) & 1120C H2 Carrier Leak Hard Interlock
// =============================================================================

@description('Azure region for the 6N5 Cp2Mg / 6N5 TEGa-TMGa / 6N5 TMIn / 6N5 TMA E-Mode p-GaN AlGaN/GaN HEMT & Micro-LED MOCVD Epitaxy & SIL-3 Interlock Estate')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #270 (270-Cycle & 270-Simulator Double Milestone!)')
param envPrefix string = 'gan270'

@description('AKS Kubernetes version for MOCVD PINN-MPC & LayTec EpiCurveTT/QCL-TDLAS edge pods')
param kubernetesVersion string = '1.30.6'

@description('Minimum 6N5 Cp2Mg / TEGa / TMGa / TMIn / TMA precursor purity (%)')
param minGroupIiiMgPrecursorPurityPct string = '99.99995'

@description('Maximum p-GaN Mg doping turn-off profile decay tail (nm/decade)')
param maxMgSimDecayTailNmPerDecade string = '1.5'

@description('Target 2DEG sheet carrier concentration x mobility product (10^16 / V-s)')
param min2degNsMuProduct10e16PerVs string = '2.47'

@description('SEMI S2 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 NH3/H2/Pyrophoric-MO lockout latency target (ms)')
param maxSil3MocvdPyrophoricLockoutMs int = 1

var resourceSuffix = uniqueString(resourceGroup().id, envPrefix)
var aksName = '${envPrefix}-aks-${resourceSuffix}'
var acrName = replace('${envPrefix}acr${resourceSuffix}', '-', '')
var kvName = '${envPrefix}-kv-${substring(resourceSuffix, 0, 8)}'
var lawName = '${envPrefix}-law-${resourceSuffix}'
var nsName = '${envPrefix}-ns-${resourceSuffix}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
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
    publicNetworkAccess: 'Disabled'
  }
}

resource mocvdNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Deny-IMDS-169-254-169-254'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '169.254.169.254/32'
          destinationPortRange: '*'
        }
      }
      {
        name: 'Allow-SIL3-MOCVD-GasCabinet-EpiCurveTT-PLC'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.242.0.0/16'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.242.68.0/24'
          destinationPortRange: '4840'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    cycle: '270'
    milestone: '270-Cycle-and-270-Simulator-Double-Milestone'
    chapter: '275'
    blueprintId: '271'
    simulatorFun: 'simulate_cp2mg_tega_tmin_tma_gan_hemt_microled_mocvd_epitaxy_sil3_sandbox'
    minPrecursorPurityPct: minGroupIiiMgPrecursorPurityPct
    maxMgDecayTailNmPerDec: maxMgSimDecayTailNmPerDecade
    min2degNsMuProduct: min2degNsMuProduct10e16PerVs
    maxSil3LockoutMs: string(maxSil3MocvdPyrophoricLockoutMs)
    safetyStandard: 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-PSM-IEC-61511-SIL3'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
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
        name: 'mocvdpinn'
        count: 4
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent-infra/domain': 'electronic-6n5-cp2mg-tega-tmin-tma-gan-hemt-microled-mocvd'
          'agent-infra/metrology': '10khz-uv-epison-216nm-qcl-tdlas-laytec-epicurvett-hrxrd'
          'agent-infra/safety': 'semi-s2-nfpa704-osha-psm-sil3-pyrophoric-mo-nh3-h2-interlock'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output aksClusterName string = aksCluster.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output keyVaultUri string = keyVault.properties.vaultUri
output mocvdVerificationTarget string = '6N5-Cp2Mg-TEGa-TMIn-TMA>=99.99995%|CpMgOR<=0.03ppmw|Mg-Tail<1.5nm/dec|2DEG-ns>1.15e13cm-2|mu>2150cm2/Vs|Ron_dyn/stat<1.08|MicroLED-EQE>38%|SIL3=0.13ms'
