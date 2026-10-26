// Blueprint #214: Autonomous Lithium-7 (7LiOH >=99.95% PWR Reactor Coolant) & Lithium-6 (6Li >=90% Fusion Tritium Blanket) Crown-Ether Centrifugal Extraction & Electromigration Cascade Pool (Cycle #213)
// Architecture: AKSClaw Hybrid Node Pools (Standard_NC24ads_A100_v4 PINN-MPC + Standard_F16s_v2 Deterministic 10 CFR 50 App B / EPRI / NFPA 30 / IEC 61511 SIL-3 PLC Gate)

param location string = resourceGroup().location
param clusterName string = 'aksclaw-li7-pwr-li6-fusion-crown-ether-213'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
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
        // Pool 1: GPU PINN-MPC for 200-Stage Benzo-15-Crown-5 Annular Centrifugal Contactor Hydraulics, 6Li/7Li Cavity Complexation Thermodynamics & Countercurrent Electromigration Cascade
        name: 'li7li6213s3'
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/domain': 'lithium7-pwr-coolant-lithium6-fusion-crown-ether-centrifugal-extraction-pinn-mpc'
          'metrology/edge-loop': '10khz-libs-laas-670nm-doublet-mc-icp-ms-and-phase-entrainment-conductometry'
        }
        nodeTaints: [
          'dedicated=li7-li6-crown-ether-pinn:NoSchedule'
        ]
      }
      {
        // Pool 2: Deterministic Real-Time Kernel Pool for 0.18ms 10 CFR 50 App B / EPRI / NFPA 30 / IEC 61511 SIL-3 6Li Breakthrough Quarantine, N2 Inerting & Cl2/H2 Rectifier Cutoff Interlock
        name: 'li7li6213rt'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        kubeletConfig: {
          cpuManagerPolicy: 'static'
          topologyManagerPolicy: 'single-numa-node'
        }
        nodeLabels: {
          'safety/standard': '10cfr50-app-b-epri-pwr-water-chemistry-nfpa30-iec-61511-sil3'
          'interlock/target-latency-ms': '0.18'
        }
        nodeTaints: [
          'safety=sil3-li7-li6-crown-ether-rt:NoExecute'
        ]
      }
    ]
  }
}
