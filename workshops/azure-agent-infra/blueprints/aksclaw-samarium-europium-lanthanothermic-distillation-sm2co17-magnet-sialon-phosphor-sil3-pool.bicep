// blueprints/aksclaw-samarium-europium-lanthanothermic-distillation-sm2co17-magnet-sialon-phosphor-sil3-pool.bicep
// Cycle #205 (Blueprint #206): Autonomous Samarium (Sm) & Europium (Eu) Vacuum Lanthanothermic Reduction-Distillation (4N5-5N Sublimation),
// Ultra-High-Temperature Aerospace 2:17 Samarium-Cobalt (Sm2(Co,Fe,Cu,Zr)17, Tc=820C, 550C Cellular 1:5/2:17R/Z-Phase Pinning) Permanent Magnet,
// Hg-Free Electrochemical Eu3+->Eu2+ Reduction & Micro-LED / Quantum-Memory Narrow-Band Phosphor (beta-SiAlON:Eu2+ / 151Eu3+:Y2SiO5) PINN-MPC
// & NFPA 484 / OSHA 1910.1000 / SEMI S2 / IEC 61511 SIL-3 Pyrophoric Sm/Eu Sublimation Condensate, High-Pressure N2 Autoclave & H2 Sintering Interlock

targetScope = 'resourceGroup'

@description('Azure region for the AKS-Claw Samarium-Europium Lanthanothermic Distillation, Sm2Co17 High-Temp Magnet & SiAlON/Eu:YSO Quantum Phosphor cluster')
param location string = resourceGroup().location

@description('Environment tier for the Sm/Eu Vacuum Sublimation, Sm2Co17 Cellular Precipitation & beta-SiAlON/Eu:YSO PINN-MPC pool')
@allowed([
  'prod-sm-eu-sm2co17-sialon-sil3'
  'staging-sm-eu-magnet-phosphor-twin'
])
param environment string = 'prod-sm-eu-sm2co17-sialon-sil3'

@description('Existing AKS cluster resource name hosting the Sm/Eu & Sm2Co17/SiAlON agentic node pools')
param aksClusterName string = 'aks-sm-eu-sm2co17-sialon-sil3'

@description('Number of parallel Sm/Eu vacuum lanthanothermic distillation retorts, Sm2Co17 cellular step-aging furnaces, and beta-SiAlON/Eu:YSO lines (1 to 32)')
@minValue(1)
@maxValue(32)
param smEuSm2co17Lines int = 8

@description('GPU SKU for coupled Sm/Eu lanthanothermic vapor-condensation Stefan-Knudsen transport, Cahn-Hilliard 2:17R/1:5/Z-phase cellular precipitation & Eu2+ phosphor PINN-MPC')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Minimum 500C high-temperature intrinsic coercivity Hcj target in kOe for 2:17 Sm2(Co,Fe,Cu,Zr)17 aerospace magnets')
param minSm2co17HighTemp500cCoercivityKoe int = 10

@description('Minimum internal quantum efficiency (IQE) in percent for narrow-band green beta-SiAlON:Eu2+ Micro-LED phosphor')
param minBetaSialonEu2IqePct int = 92

var gpuNodeCount = max(2, (smEuSm2co17Lines + 1) / 2)
var rtSil3NodeCount = max(3, (smEuSm2co17Lines + 3) / 4)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. GPU Node Pool for Coupled Sm/Eu Vacuum Sublimation, Sm2Co17 Cellular Precipitation & beta-SiAlON/Eu:YSO PINN-MPC
resource smEuPinnGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'smeu205gpu'
  properties: {
    count: gpuNodeCount
    vmSize: gpuNodeVmSize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: gpuNodeCount
    maxCount: gpuNodeCount * 2
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'workload.aksclaw.io/domain': 'sm-eu-lanthanothermic-sm2co17-magnet-sialon-phosphor-pinn-mpc'
      'hardware.aksclaw.io/gpu-tier': 'a100-80gb-mig-pcie'
      'metallurgy.aksclaw.io/sm-eu-sublimation': 'vacuum-lanthanothermic-1150c-1e-3pa-4n5-5n-dendritic-condensate'
      'magnetics.aksclaw.io/sm2co17-cellular': '100nm-2-17r-cell-10nm-cu-rich-1-5-boundary-zr-z-phase-lamellae'
      'photonics.aksclaw.io/eu-phosphor-quantum': 'hg-free-eu2-electrolysis-beta-sialon-535nm-151eu-y2sio5-memory'
    }
    nodeTaints: [
      'sku=sm-eu-sm2co17-sialon-pinn-gpu:NoSchedule'
    ]
  }
}

// 2. Real-Time PREEMPT_RT Node Pool for 10 kHz LIBS/ICP-MS, High-Temp Hysteresisgraph, TRPL & SIL-3 Pyrophoric Sm/Eu / N2-Autoclave Interlock
resource smEuSil3RtPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'smeu205rt'
  properties: {
    count: rtSil3NodeCount
    vmSize: 'Standard_F16s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: false
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      cpuCfsQuota: false
    }
    linuxOSConfig: {
      sysctls: {
        'kernel.sched_rt_runtime_us': -1
        'net.core.busy_poll': 50
        'net.core.busy_read': 50
      }
    }
    nodeLabels: {
      'workload.aksclaw.io/domain': 'sm-eu-nfpa484-osha19101000-semis2-sil3-interlock'
      'safety.aksclaw.io/standard': 'nfpa484-osha19101000-semis2-iec61511-sil3'
      'metrology.aksclaw.io/loop-rate': '10khz-libs-icpms-hightemp-hysteresisgraph-trpl-rga'
      'interlock.aksclaw.io/min-sm2co17-500c-hcj-koe': string(minSm2co17HighTemp500cCoercivityKoe)
      'interlock.aksclaw.io/min-beta-sialon-iqe-pct': string(minBetaSialonEu2IqePct)
    }
    nodeTaints: [
      'safety=sm-eu-sil3-rt:NoExecute'
    ]
  }
}

output smEuGpuPoolResourceId string = smEuPinnGpuPool.id
output smEuSil3RtPoolResourceId string = smEuSil3RtPool.id
output configuredSmEuLines int = smEuSm2co17Lines
output provisionedGpuNodes int = gpuNodeCount
output provisionedSil3RtNodes int = rtSil3NodeCount
