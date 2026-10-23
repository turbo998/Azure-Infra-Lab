// ============================================================================
// AKSClaw Million-Ton Ethylene Steam Cracking Furnace (820-865C Millisecond
// Radiant Coil Naphtha/Ethane Pyrolysis & Transfer-Line Exchanger TLE Quench)
// Free-Radical Severity, Filamentous/Pyrolytic Coke Deposition & Carburization
// Creep PINN-MPC, Online 10 kHz Dual-Wavelength IR Tube-Skin Pyrometry (TMT) /
// TDLAS Metrology & API STD 530 / API RP 556 / NFPA 85 / IEC 61511 SIL-3 Tube
// Rupture, Steam-Air Decoking Spallation & Firebox Trip Blueprint (#170 Milestone!)
// ============================================================================

@description('Azure region for the AKSClaw Ethylene Steam Cracking Furnace & TLE cluster')
param location string = resourceGroup().location

@description('AKS cluster name for Ethylene Steam Cracker Radiant-Coil PINN-MPC & 10 kHz IR TMT/TDLAS edge')
param clusterName string = 'aksclaw-ethylene-cracker-api530-sil3'

@description('Kubernetes version for AKSClaw control plane and node pools')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC & 10 kHz Dual-Wavelength IR Tube-Metal-Temp (TMT) / TDLAS Edge GPU VM size')
param pinnGpuVmSize string = 'Standard_NV36ads_A10_v5'

@description('Kata-isolated API STD 530 / NFPA 85 / SIL-3 Radiant-Tube Rupture & Decoking Interlock VM size')
param safetyKataVmSize string = 'Standard_D16s_v5'

@description('Maximum allowable HP-Mod / Cr-Ni-Al Alloy radiant tube metal temperature TMT (degC)')
param maxAllowableTmtC int = 1110

@description('Minimum target furnace run-length between steam-air decoking cycles (days)')
param targetFurnaceRunLengthDays int = 92

@description('SIL-3 feedstock isolation, dilution-steam purge & firebox burner trip latency (ms)')
param sil3InterlockLatencyMs string = '0.4'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'ethylene-steam-cracker-radiant-coil-coking-tle-pyrometry-api530-sil3'
    industryStandard: 'API-STD-530-API-RP-556-NFPA-85-IEC-61511-SIL3'
    pinnModel: 'free-radical-pyrolysis-coke-deposition-larson-miller-carburization-creep-pinn'
    edgeMetrology: '10khz-dual-wavelength-ir-tmt-pyrometry-tdlas-acoustic-spallation'
    blueprintIndex: '170'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
      outboundType: 'userDefinedRouting'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'crkpinn'
        count: 4
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        enableAutoScaling: true
        minCount: 2
        maxCount: 8
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'aksclaw.io/workload-tier': 'ethylene-cracker-radiant-coil-coking-tle-pinn-mpc-gpu'
          'aksclaw.io/edge-metrology': '10khz-ir-tmt-pyrometry-tdlas-effluent-spallation'
          'aksclaw.io/target-run-length-days': string(targetFurnaceRunLengthDays)
        }
        nodeTaints: [
          'aksclaw.io/gpu-pinn=true:NoSchedule'
        ]
      }
      {
        name: 'crksil3'
        count: 3
        vmSize: safetyKataVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'aksclaw.io/isolation': 'kata-mshv-vm'
          'aksclaw.io/safety-standard': 'API-STD-530-API-RP-556-NFPA-85-IEC-61511-SIL3'
          'aksclaw.io/interlock-target': 'radiant-tube-creep-rupture-tle-plug-decoke-burnthrough-trip'
          'aksclaw.io/max-tmt-c': string(maxAllowableTmtC)
          'aksclaw.io/sil3-latency-ms': sil3InterlockLatencyMs
        }
        nodeTaints: [
          'aksclaw.io/sil3-interlock=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output pinnNodePoolName string = 'crkpinn'
output safetyKataPoolName string = 'crksil3'
output safetyComplianceProfile string = 'API-STD-530_API-RP-556_NFPA-85_IEC-61511-SIL3_${sil3InterlockLatencyMs}ms'
