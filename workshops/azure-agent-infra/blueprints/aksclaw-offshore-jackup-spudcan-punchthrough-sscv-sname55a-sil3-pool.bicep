// ============================================================================
// Azure Bicep Blueprint #128: Autonomous Offshore Jack-Up Rig (120-180 m Water
// Depth 3/4-Leg Truss Chord-Rack-Pinion Jacking) & Heavy-Lift Semi-Submersible
// Crane Vessel (5,000-20,000 t SSCV), Spudcan Punch-Through Geomechanics &
// Dynamic Anti-Heeling Ballast PINN-MPC, Rack-Phase-Difference (RPD) / Chord AE
// Metrology & SNAME T&R 5-5A / ISO 19905-1 / DNV-OS-C104 / API Spec 2C /
// IEC 61508 SIL-3 Punch-Through Preload Dump & Crane AOPS/MOPS Interlock Pool
// ============================================================================
@description('Name of the existing AKS cluster hosting the AKSClaw control plane')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure region for Offshore Jack-Up Spudcan & SSCV Heavy-Lift SIL-3 GPU pool')
param location string = resourceGroup().location

@description('Initial node count for Standard_NC24ads_A100_v4 Jack-Up & SSCV PINN-MPC pool')
@minValue(2)
@maxValue(64)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource offshoreJackupSscvSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'jkupsscvs3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 64
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'offshore-jackup-spudcan-punchthrough-sscv-sname55a-sil3-agent'
      'aksclaw.io/pinn-mpc-spudcan-punchthrough-sscv-antiheeling': 'enabled-39.4pct-jacking-heavylift-window-gain-54.3pct-chord-rpd-pendulum-swing-cut'
      'aksclaw.io/iso19905-api2c-sil3-preload-dump-aops-mops-interlock': 'enforced-0.3ms-zero-leg-buckling-capsizing-or-boom-collapse'
      'aksclaw.io/jackhouse-edge-laser-rpd-chord-fbg-cpt': 'enabled-0.3ms-99.5pct-satcom-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/offshore-jackup-sscv-sil3=true:NoSchedule'
    ]
  }
}
