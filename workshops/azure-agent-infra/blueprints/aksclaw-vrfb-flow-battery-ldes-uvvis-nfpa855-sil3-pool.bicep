// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #119
// AKSClaw Vanadium Redox Flow Battery (VRFB) Long-Duration Energy Storage (LDES),
// Donnan Membrane Crossover & Valence Rebalancing PINN-MPC, In-Line UV-Vis/OCV
// Metrology & UL 1973 / NFPA 855 / IEEE 1547 / IEC 61511 SIL-3 Interlock Pool
// ============================================================================
targetScope = 'resourceGroup'

@description('Deployment region for the VRFB LDES control plane and PINN twin pool')
param location string = resourceGroup().location

@description('Environment identifier for the VRFB long-duration storage plant')
@allowed([
  'prod-vrfb-100mw-1000mwh-ldes'
  'staging-vrfb-digital-twin'
  'lab-stack-membrane-qualification'
])
param environment string = 'prod-vrfb-100mw-1000mwh-ldes'

@description('AKS Kubernetes version for VRFB PINN-MPC and UV-Vis telemetry')
param kubernetesVersion string = '1.31.2'

@description('Number of cell stacks across the VRFB power block')
@minValue(20)
@maxValue(800)
param stackCount int = 240

@description('Minimum voltage efficiency (%) target at rated current density')
param minVoltageEfficiencyPct int = 84

@description('Maximum hydrogen headspace concentration (% LEL) before NFPA 855 / SIL-3 purge')
param maxH2HeadspaceLelPct int = 15

@description('Maximum vanadium pentoxide V2O5 precipitation temperature threshold (deg C)')
param maxElectrolyteTempC int = 40

var clusterName = 'aks-vrfb-ldes-${uniqueString(resourceGroup().id, environment)}'
var lawName = 'law-vrfb-sil3-${uniqueString(resourceGroup().id, environment)}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource aksVrfbCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
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
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      loadBalancerSku: 'standard'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        logAnalyticsWorkspaceResourceId: logAnalytics.id
        securityMonitoring: {
          enabled: true
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'sysvrfb'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
        nodeLabels: {
          'agent.azure.com/role': 'vrfb-control-plane'
          'energy.azure.com/safety-standard': 'ul1973-nfpa855-ieee1547-sil3'
        }
      }
      {
        name: 'pinnvrfb'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: 2
        maxCount: 16
        nodeLabels: {
          'agent.azure.com/workload': 'donnan-crossover-valence-pinn-mpc'
          'energy.azure.com/metrology': 'uv-vis-spectrophotometry-ocv'
          'energy.azure.com/stack-count': string(stackCount)
          'energy.azure.com/min-ve-pct': string(minVoltageEfficiencyPct)
        }
        nodeTaints: [
          'energy.azure.com/gpu-pinn=true:NoSchedule'
        ]
      }
      {
        name: 'katasil3'
        count: 3
        vmSize: 'Standard_D16s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        minCount: 3
        maxCount: 9
        nodeLabels: {
          'agent.azure.com/isolation': 'kata-mshv-vm'
          'energy.azure.com/interlock': 'nfpa855-sil3-h2-purge-shunt-trip'
          'energy.azure.com/max-h2-lel-pct': string(maxH2HeadspaceLelPct)
          'energy.azure.com/max-electrolyte-temp-c': string(maxElectrolyteTempC)
        }
        nodeTaints: [
          'isolation.azure.com/kata=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksVrfbCluster.id
output oidcIssuerUrl string = aksVrfbCluster.properties.oidcIssuerProfile.issuerURL
output safetyInterlockSpec string = 'UL-1973-NFPA-855-IEEE-1547-IEC-61511-SIL3'
