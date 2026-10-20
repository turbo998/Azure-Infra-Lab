// Blueprint #66: Autonomous Small Modular Reactor (SMR) Core Neutronics, Xenon-135 Digital Twin & IEEE 603 / IEC 61513 Class 1E RTS Pool
// Target Runtime: AKSClaw (Kata Containers VM-Isolated Pods + GPU Pin-by-Pin Neutron Transport & Thermal-Hydraulics Pool + Azure IoT Operations Class 1E Data-Diode Bridge)
// Scenario: 3D OpenMC/PINN Core Neutronics, Xenon-135 Spatial Oscillation Damping, Control-Rod Gray-Bank Micro-Stepping & IEEE 603 / IEC 61513 Class 1E Reactor Trip System (RTS) Interlock

param clusterName string = 'aksclaw-smr-nuclear-grid'
param location string = resourceGroup().location
param kubernetesVersion string = '1.31.2'
param neutronicsGpuVmSize string = 'Standard_NC24ads_A100_v4'
param neutronicsNodeCount int = 3
param smrReactorModulesAndLoops int = 24
param maxReactivityInsertionRatePcmPerSec string = '3.0'
param minDnbrThermalMarginThreshold string = '1.30'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' existing = {
  name: clusterName
}

resource smrNeutronicsPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'smrpinnpool'
  properties: {
    count: neutronicsNodeCount
    vmSize: neutronicsGpuVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 12
    nodeLabels: {
      'agent.azure.com/workload-tier': 'smr-nuclear-neutronics-class1e-rts'
      'agent.azure.com/neutronics-solver': 'openmc-xenon135-dnbr-pinn'
      'agent.azure.com/safety-standard': 'ieee-603-iec-61513-class-1e-rts'
      'agent.azure.com/edge-bridge': 'azure-iot-operations-spnd-data-diode'
      'agent.azure.com/smr-modules-and-loops': string(smrReactorModulesAndLoops)
      'agent.azure.com/max-reactivity-rate-pcm-s': maxReactivityInsertionRatePcmPerSec
      'agent.azure.com/min-dnbr-threshold': minDnbrThermalMarginThreshold
    }
    nodeTaints: [
      'nuclear.azure.com/smr-class1e-sandbox=true:NoSchedule'
    ]
    tags: {
      scenario: 'smr-nuclear-neutronics-class1e-rts'
      isolation: 'kata-microvm-gpu'
      compliance: 'IEEE-603-IEC-61513-Class-1E-NRC-10CFR50'
    }
  }
}

output poolResourceId string = smrNeutronicsPool.id
output isolationRuntime string = smrNeutronicsPool.properties.workloadRuntime
output targetSmrModules int = smrReactorModulesAndLoops
