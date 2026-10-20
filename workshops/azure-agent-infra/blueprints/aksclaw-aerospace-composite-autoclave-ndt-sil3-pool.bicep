// Blueprint #69: Aerospace Composite Autoclave Curing, AFP Laser Thermography, PAUT NDT & NADCAP AC7118 / AMS2750G / IEC 61508 SIL-3 Interlock Sandbox Pool
// Models Kamal-Sourour thermochemical cure kinetics MPC, AFP in-situ laser thermography, Phased-Array Ultrasonic (PAUT) FMC/TFM C-scan, and SIL-3 exothermic runaway & vacuum-bag breach interlock.

param clusterName string = 'aksclaw-aero-composite-sil3'
param location string = resourceGroup().location
param autoclaveAfpCureZones int = 16
param cureNdtGovernanceMode string = 'thermochemical_cure_mpc_paut_nadcap_sil3_edge'

var gpuNodeCount = max(2, ((autoclaveAfpCureZones + 7) / 8))

resource aksCompositeCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'compositendt'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'aerospace-composite-autoclave-ndt-sil3'
          'agent.azure.com/cure-ndt-mode': cureNdtGovernanceMode
          'agent.azure.com/pyrometry-standard': 'nadcap-ac7118-ams2750g-as9100'
          'agent.azure.com/safety-interlock': 'iec-61508-sil3-exotherm-vacuum'
        }
        nodeTaints: [
          'aerospace.azure.com/composite-autoclave-sandbox=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
  }
}

output compositeClusterId string = aksCompositeCluster.id
output autoclaveAfpCureZonesConfigured int = autoclaveAfpCureZones
output nadcapSil3Profile string = 'NADCAP-AC7118-AMS2750G-AS9100-IEC61508-SIL3'
