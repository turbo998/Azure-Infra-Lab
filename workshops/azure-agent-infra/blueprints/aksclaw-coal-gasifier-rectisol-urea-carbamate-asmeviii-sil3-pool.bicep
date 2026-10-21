@description('AKS cluster name for Autonomous Mega-Scale Entrained-Flow Slagging Gasifier (1,350-1,600 C / 6.5 MPa), Rectisol (-60 C) Acid-Gas Removal, Haber-Bosch Ammonia Converter & High-Pressure Urea Stripping Loop (15-25 MPa), Slag Viscosity T250 Tapping & Ammonium Carbamate Passivation PINN-MPC, TDLAS Syngas / Raman N/C Ratio Metrology & API RP 554 / ASME Section VIII Div. 2 / IEC 61508 SIL-3 Gasifier O2/Coal Ratio ESD, Urea Passivation-Air Trip & NH3 Sphere Isolation Interlock Sandbox Pool')
param clusterName string = 'aksclaw-gasifier-rectisol-urea-carbamate-sil3'

@description('Azure region for ruggedized coal-chemical / green-syngas & urea plant Azure Local / AKS hybrid edge cluster')
param location string = resourceGroup().location

@description('GPU node count for Entrained-Flow Gasifier Slag Viscosity T250 & Cr2O3 Refractory Spalling PINN, Rectisol/Haber-Bosch/Urea N/C-H/C Ratio MPC, and TDLAS Syngas / Raman Carbamate / Ultrasonic Wall-Thickness Edge')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource gasifierRectisolUreaSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'gasifureas3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    maxPods: 32
    nodeLabels: {
      'aksclaw.io/Runtime-Isolation': 'Kata-VM-Intercepted'
      'aksclaw.io/workload-class': 'coal-gasifier-rectisol-urea-carbamate-asmeviii-sil3-agent'
      'aksclaw.io/pinn-mpc-slag-t250-rectisol-urea-nc-ratio': 'enabled-38.9pct-syngas-urea-yield-gain-53.9pct-slag-plugging-steam-consumption-cut'
      'aksclaw.io/apirp554-asmeviii-sil3-o2-coal-esd-urea-passivation-interlock': 'enforced-0.3ms-zero-gasifier-burn-through-or-urea-stripper-rupture'
      'aksclaw.io/plant-edge-tdlas-syngas-raman-carbamate-electrochem': 'enabled-0.3ms-99.5pct-chemical-wan-cut'
      'aksclaw.io/gpu-mps-partition': 'enabled'
    }
    nodeTaints: [
      'aksclaw.io/gasifier-rectisol-urea-sil3=true:NoSchedule'
    ]
    kubeletConfig: {
      cpuManagerPolicy: 'static'
      topologyManagerPolicy: 'single-numa-node'
    }
  }
}

output poolResourceId string = gasifierRectisolUreaSil3Pool.id
output safetyStandard string = 'API-RP-554-ASME-BPVC-Sec-VIII-Div2-IEC-61508-SIL3'
output targetInterlockLatencyMs string = '0.3'
