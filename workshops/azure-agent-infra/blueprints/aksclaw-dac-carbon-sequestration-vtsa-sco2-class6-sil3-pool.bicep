// =============================================================================
// Blueprint #72: AKSClaw Direct Air Capture (DAC), V-TSA Sorbent Array, Supercritical CO2 Pipeline & EPA Class VI Wellbore SIL-3 Pool
// Chapter 76 — V-TSA Adsorption-Desorption MPC, sCO2 Phase-Envelope & ISO 27914 / EPA Class VI Caprock BHP SIL-3 Interlock
// =============================================================================

@description('Azure region for the AKSClaw DAC & EPA Class VI Geological Sequestration pool')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-dac6'

@description('VM SKU for Vacuum-TSA & TOUGH3/ECLIPSE Multiphase CO2 Plume PINN GPU nodes')
param gpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('Number of GPU nodes in the DAC & Class VI reservoir simulation pool')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 2

@description('DAC Contactor-Sorbent Modules & Class VI Injection Wells')
param dacModulesAndWells int = 16

@description('DAC & Class VI Reservoir Governance Mode')
@allowed([
  'vtsa_mpc_sco2_class6_bhp_sil3_edge'
  'unmanaged_fixed_steam_unthrottled_bhp_cloud'
])
param dacGovernanceMode string = 'vtsa_mpc_sco2_class6_bhp_sil3_edge'

@description('Maximum Bottomhole Pressure Fraction of Caprock Fracture Gradient (EPA Class VI <= 0.90)')
param maxBhpFractureGradientRatio string = '0.90'

@description('Supercritical CO2 Pipeline Minimum Pressure Floor (MPa, > 7.38 MPa critical point)')
param minSco2PipelinePressureMpa string = '8.50'

@description('IEC 61511 SIL-3 Wellhead Emergency Shut-In Valve (ESDV) & Choke Interlock Budget (ms)')
param sil3WellheadEsdvMaxMs int = 15

resource aksDacCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
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
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'dacvtsapinn'
        count: gpuNodeCount
        vmSize: gpuVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'aksclaw.io/workload-tier': 'dac-vtsa-sco2-class6-pinn'
          'aksclaw.io/dac-governance-mode': dacGovernanceMode
          'aksclaw.io/epa-class-vi-iso27914': 'enforced'
          'aksclaw.io/iec61511-sil3-wellhead-esdv': 'hardware-veto'
          'aksclaw.io/sco2-phase-envelope-guard': 'enabled'
        }
        nodeTaints: [
          'aksclaw.io/dac-class6-gpu=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
  tags: {
    Architecture: 'AKSClaw-DAC-VTSA-sCO2-ClassVI-SIL3-Sandbox'
    Chapter: 'Chapter-76'
    ModulesAndWells: string(dacModulesAndWells)
    GovernanceMode: dacGovernanceMode
    MaxBhpFractureRatio: maxBhpFractureGradientRatio
    MinSco2PressureMpa: minSco2PipelinePressureMpa
    Sil3WellheadEsdvMaxMs: string(sil3WellheadEsdvMaxMs)
  }
}

output clusterName string = aksDacCluster.name
output dacPoolNodeCount int = gpuNodeCount
output governanceProfile string = dacGovernanceMode
