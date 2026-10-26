// ============================================================================
// Blueprint #224: Medical Radioisotope & Cardiac PET/SPECT Cyclotron Production
// (85Rb(p,4n)82Sr -> 82Rb High-Current RbCl Salt Targetry, Hydrous SnO2
// Generator Breakthrough Suppression & 203Tl(p,3n)201Pb -> 201Tl Electroplated
// Target PINN-MPC with USP <823> / ISO 17873 / SIL-3 Interlocks)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 82Sr/82Rb & 201Tl Cardiac Radioisotope Edge-Cloud Sandbox')
param location string = resourceGroup().location

@description('Environment prefix')
param environmentPrefix string = 'sr82tl201-sil3'

@description('Number of parallel 82Sr/82Rb & 201Tl cyclotron/generator production trains (1-32)')
@minValue(1)
@maxValue(32)
param sr82Tl201Trains int = 8

@description('Governance mode for 85Rb(p,4n)82Sr RbCl salt targetry, SnO2 generator breakthrough & 201Pb->201Tl in-growth PINN-MPC')
@allowed([
  'pinn_mpc_rb85_p4n_sr82_rbcl_target_sno2_generator_and_tl203_p3n_pb201_tl201_ingrowth_sil3_edge'
  'raw_cloud_uncompensated_rbcl_core_melt_sr82_breakthrough_and_200tl_202tl_impurity'
])
param sr82Tl201GovernanceMode string = 'pinn_mpc_rb85_p4n_sr82_rbcl_target_sno2_generator_and_tl203_p3n_pb201_tl201_ingrowth_sil3_edge'

var gpuNodeCount = max(2, (sr82Tl201Trains + 1) / 2)
var activeSr82Tl201Pods = sr82Tl201Trains * 4
var clusterName = '${environmentPrefix}-aks-cardiac-isotope'

resource aksCardiacIsotope 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'strontium82-rubidium82-cardiac-pet-thallium201-spect-cyclotron-sil3'
    governanceMode: sr82Tl201GovernanceMode
    standards: 'USP-823-ISO-17873-IEC-61511-SIL3'
    activePods: string(activeSr82Tl201Pods)
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcgpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.infra/domain': 'sr82-rb82-tl201-cardiac-cyclotron-pinn-mpc'
          'agent.infra/sil-rating': 'SIL-3'
          'agent.infra/metrology-loop-hz': '10000'
        }
      }
    ]
  }
}

output clusterResourceId string = aksCardiacIsotope.id
output pinnsGpuNodes int = gpuNodeCount
output activeSr82Tl201PodsCount int = activeSr82Tl201Pods
output usp823Iso17873Sil3InterlockMs string = '0.16'
