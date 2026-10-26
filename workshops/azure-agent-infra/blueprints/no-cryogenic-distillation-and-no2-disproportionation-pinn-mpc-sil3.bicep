// ============================================================================
// Blueprint #234: Pharmaceutical-Grade Nitric Oxide (NO) Cryogenic Fractional
// Distillation, Nitrosyl Halide Photochemical Dissociation & High-Pressure
// Cylinder Nitrogen Dioxide (NO2) Disproportionation PINN-MPC, In-Situ Mid-IR
// QCL-TDLAS (5.26 um / 6.25 um) & USP-NF / ISO 11114-1 / CGA G-10.1 / SIL-3
// Pulmonary-Edema Toxic NO2 Breakthrough / Adiabatic Auto-Decomposition Interlock
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the Pharmaceutical-Grade Nitric Oxide (NO) Cryogenic Distillation & NO2 Disproportionation Control Stamp')
param location string = resourceGroup().location

@description('Environment prefix for Pharmaceutical-Grade 5N NO & Inhaled iNO Cylinder Filling Governance')
param environmentPrefix string = 'no5n-ino-sil3'

@description('AKS Automatic + Kata-CC H100 v5 Node VM Size for PINN-MPC Termolecular NO Oxidation & Disproportionation Solver')
param pinnGpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Maximum permissible NO2 concentration in pharmaceutical-grade iNO cylinders (ppmv) before USP-NF / SIL-3 quarantine')
param maxNo2BreakthroughPpmv string = '0.45'

@description('Maximum permissible cylinder transfilling pressure ramp rate (MPa/min) before CGA G-10.1 adiabatic compression lockout')
param maxTransfillingRampMpaPerMin string = '0.15'

@description('SIL-3 Emergency N2 Purge Dilution & Alkaline Na2S2O3/NaOH Chemical Reduction Scrubber Latency Target (ms)')
param sil3ScrubberLatencyMs int = 1

var clusterName = '${environmentPrefix}-aks-kata-cc'
var keyVaultName = take('${replace(environmentPrefix, '-', '')}kv${uniqueString(resourceGroup().id)}', 24)
var iotNamespaceName = '${environmentPrefix}-aio-qcl-crds'
var workspaceName = '${environmentPrefix}-law-uspnf'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 730
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
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
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    dnsPrefix: environmentPrefix
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8ds_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'pinnmpcno'
        count: 2
        vmSize: pinnGpuVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'no-cryogenic-distillation-no2-disproportionation-pinn-mpc'
          'safety.iec61511/sil-rating': 'SIL-3'
          'compliance.pharma/standard': 'USP-NF-ISO11114-1-CGA-G10-1'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
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

output aksClusterResourceId string = aksCluster.id
output keyVaultUri string = keyVault.properties.vaultUri
output sil3InterlockProfile object = {
  iotNamespace: iotNamespaceName
  maxNo2BreakthroughPpmv: maxNo2BreakthroughPpmv
  maxTransfillingRampMpaPerMin: maxTransfillingRampMpaPerMin
  sil3ScrubberLatencyMs: sil3ScrubberLatencyMs
  telemetryChannels: [
    'Mid-IR-QCL-TDLAS-5.26um-NO-6.25um-NO2-4.46um-N2O-10kHz'
    'Cavity-Ring-Down-Spectroscopy-CRDS-1.39um-H2O-50ppbv'
    'Cryogenic-Distillation-Column-119.5K-121.4K-dP-Array'
    'USP-NF-ISO11114-1-SIL3-Na2S2O3-Scrubber-Dump-Actuator'
  ]
}
