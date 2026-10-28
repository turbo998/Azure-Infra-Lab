// blueprints/cuhfacvtms-cudmap2-temaz-dezn-hhfac-a10-3dic-hbm4-ntcu-hybrid-bonding-and-cu-zr-barrier-peald-ale-pinn-mpc-sil3.bicep
// Cycle #298: Electronic-Grade 6N5 Cu(hfac)(VTMS)/Cu(dmap)2 + 6N5 TEMAZ/DEZn + 6N5 Hhfac
// 300mm A10/A7 3D-IC HBM4 Sub-400nm (111) Nanotwinned Cu Hybrid Bonding, Self-Forming 0.8nm Cu-Zr/Zn Barrier & Thermal Cu-ALE PINN-MPC + SIL-3

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 6N5 Cu(hfac)(VTMS)/Cu(dmap)2/TEMAZ/DEZn/Hhfac 3D-IC Hybrid Bonding & Cu-ALE sandbox')
param location string = resourceGroup().location

@description('Environment prefix for 300mm A10/A7 3D-IC HBM4 (111) nt-Cu Hybrid Bonding & Self-Forming Cu-Zr Barrier resources')
param envPrefix string = 'cuhfacvtms-ntcu-3dic-sil3'

@description('AKS node SKU for PINN-MPC + 10 kHz QCL-CRDS + SF-ICP-MS + In-Situ EBSD/4D-STEM/SAM/SE Edge')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
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
        osType: 'Linux'
      }
      {
        name: 'pinngpupool'
        count: 4
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'workload-tier': 'cuhfacvtms-cudmap2-temaz-dezn-hhfac-3dic-ntcu-hybrid-bonding-pinn-mpc'
          'safety-interlock': 'semi-s2-nfpa704-osha-19101000-sil3-pyrophoric-dezn-corrosive-hhfac-dbb'
          'metrology-loop': 'qcl-crds-10khz-1645cm1-sficpms-insitu-ebsd-4dstem-sam-se-0p11ms'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
  }
}

output aksClusterId string = aksCluster.id
output safetyInterlockSpec string = 'SEMI-S2-NFPA704-OSHA-19101000-IEC61511-SIL3-0.10ms-1oo2D-DBB-DEZn-Hhfac-CuO-CaO-CaF2-Scrubber'
output hybridBondingTarget string = 'Sub-400nm-nt-Cu-111-gt96.5pct-180C-Bonding-0.0pct-Void-Rpad-0.08Ohm-0.8nm-CuZr-Barrier-jmax-4.2e7Acm2'
