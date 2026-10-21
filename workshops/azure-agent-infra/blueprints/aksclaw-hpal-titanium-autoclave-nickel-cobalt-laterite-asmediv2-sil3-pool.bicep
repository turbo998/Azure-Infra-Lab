// ============================================================================
// Blueprint #134: Autonomous High-Pressure Acid Leach (HPAL Titanium-Clad
// Autoclave 255 C / 4.5 MPa Nickel-Cobalt Laterite Hydrometallurgy, Acid-to-Ore
// Stoichiometry, Alunite/Hematite Scale Suppression & Ceramic Letdown Valve
// Cavitation PINN-MPC, Online PGNAA Ore-Grade / High-Temp ORP Metrology &
// ASME BPVC Sec VIII Div 2 / API 521 / IEC 61508 SIL-3 Titanium Pyrophoric
// Ignition, Autoclave Over-Pressure & H2S Gas Interlock Pool)
// ============================================================================

@description('Azure region for the HPAL nickel-cobalt autoclave edge-cloud control plane')
param location string = resourceGroup().location

@description('Environment prefix for HPAL laterite hydrometallurgy resources')
param environmentName string = 'prod-hpal-nico-sil3'

@description('AKS Kubernetes version for real-time HPAL autoclave PINN-MPC and letdown choke pods')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC GPU node pool VM size (NVIDIA A100/H100 for multi-compartment autoclave hydrothermal & flash-letdown two-phase CFD PINN)')
param pinnGpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('Deterministic real-time edge node pool VM size for PGNAA ore mineralogy, acoustic cavitation & SIL-3 autoclave safety interlock')
param rtHydrometVmSize string = 'Standard_F16s_v2'

@description('Target HPAL autoclave operating pressure in MPa (gauge)')
param autoclavePressureMpa string = '4.5'

@description('Target HPAL autoclave operating temperature in Celsius')
param autoclaveTempC string = '255'

@description('Target nickel and cobalt leaching extraction recovery (%)')
param targetNiCoExtractionPct string = '96.0'

var clusterName = 'aks-${environmentName}'
var lawName = 'law-${environmentName}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'autonomous-hpal-titanium-autoclave-nickel-cobalt-laterite-sil3'
    safetyStandard: 'ASME-BPVC-VIII-Div2-API-521-IEC-61508-SIL3'
    autoclavePressureMpa: autoclavePressureMpa
    autoclaveTempC: autoclaveTempC
    targetNiCoExtractionPct: targetNiCoExtractionPct
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcgpu'
        count: 2
        vmSize: pinnGpuVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        nodeLabels: {
          'agent-infra/role': 'hpal-autoclave-leach-letdown-cavitation-pinn-mpc'
          'nvidia.com/gpu': 'true'
        }
        nodeTaints: [
          'dedicated=hpal-pinn-gpu:NoSchedule'
        ]
      }
      {
        name: 'rthydromet'
        count: 3
        vmSize: rtHydrometVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        kubeletConfig: {
          cpuManagerPolicy: 'static'
          topologyManagerPolicy: 'single-numa-node'
        }
        nodeLabels: {
          'agent-infra/role': 'pgnaa-mineralogy-orp-asmediv2-sil3'
          'safety.iec61508/sil': 'sil-3'
        }
        nodeTaints: [
          'rt-hpal=true:NoSchedule'
        ]
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

output clusterName string = aksCluster.name
output safetyStandard string = aksCluster.tags.safetyStandard
output targetNiCoExtractionPct string = targetNiCoExtractionPct
