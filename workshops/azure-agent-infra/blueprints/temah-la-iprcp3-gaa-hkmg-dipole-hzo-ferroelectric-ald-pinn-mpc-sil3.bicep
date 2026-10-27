// =============================================================================
// Blueprint #243: Electronic-Grade 6N TEMAH & 6N La(iPrCp)3 / La(iPr-FMD)3
// 2nm/A14 GAA Nanosheet Multi-Vth Dipole-First HKMG & Ferroelectric HZO ALD
// PINN-MPC + SEMI S2 / SEMI C3 / NFPA 484 / IEC 61511 SIL-3 Interlock (Cycle #242 · 250-Chapter Milestone!)
// =============================================================================

@description('Azure region for the Electronic-Grade 6N TEMAH & 6N La(iPrCp)3 GAA HKMG Dipole & Ferroelectric HZO ALD PINN-MPC architecture')
param location string = resourceGroup().location

@description('Environment prefix for semiconductor HKMG & ferroelectric precursor resources')
param environmentPrefix string = 'temahla242'

@description('AKS GPU node pool VM size for TEMAH/La(iPrCp)3 wiped-film molecular distillation, La2O3 dipole drive-in & HZO Pca2_1 crystallization PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Maximum Bridged Hydroxide Oligomer La_x(OH)_y(iPrCp)_z impurity threshold in ppmw before SIL-3 ampoule quarantine')
param maxLaOhOligomerPpmw string = '0.06'

@description('Maximum TEMAH DLI vaporizer skin temperature in Celsius before SIL-3 2oo3 cutoff')
param maxTemahDliTempC string = '130.0'

@description('Maximum La(iPrCp)3 heated bubbler temperature in Celsius before SIL-3 pyrophoric thermal cracking lockout')
param maxLaIprcp3BubblerTempC string = '185.0'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${environmentPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${environmentPrefix}-iothub'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 8
      }
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
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
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'temah-la-iprcp3-gaa-hkmg-dipole-hzo-ferroelectric-ald-pinn-mpc'
          'safety/standard': 'SEMI-S2-SEMI-C3-NFPA-484-IEC-61511-SIL3'
          'metrology/edge': '10kHz-QCL-TDLAS-958-2962-3580cm1-ICP-MS-MS-GI-XRD-XPS'
          'milestone/cycle': 'Cycle-242-250-Chapter-Milestone'
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
        ]
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${environmentPrefix}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
  }
}

output aksClusterName string = aksCluster.name
output iotHubHostname string = iotHub.properties.hostName
output sil3InterlockSpec string = 'SEMI-S2/SEMI-C3/NFPA-484/SIL-3: La_x(OH)_y <= ${maxLaOhOligomerPpmw} ppmw | TEMAH DLI <= ${maxTemahDliTempC} C | La(iPrCp)3 Bubbler <= ${maxLaIprcp3BubblerTempC} C | 0.14ms 2oo3 Dry-Graphite/Ar Isolation'
