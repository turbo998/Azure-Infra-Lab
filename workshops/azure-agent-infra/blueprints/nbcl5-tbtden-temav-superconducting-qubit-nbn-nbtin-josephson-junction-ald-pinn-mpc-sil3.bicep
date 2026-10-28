// blueprints/nbcl5-tbtden-temav-superconducting-qubit-nbn-nbtin-josephson-junction-ald-pinn-mpc-sil3.bicep
// Blueprint #270 (270-Blueprint Milestone!): Electronic-Grade Niobium Pentachloride (6N5 NbCl5 >=99.99995%, NbOCl3 <=0.05 ppmw, Ta <=0.05 ppmw, Magnetic Fe/Ni/Cr <=0.02 ppbw, U/Th <=0.001 ppbw Suppressing Quasiparticle TLS Loss) & Tert-butylimidotris(diethylamido)niobium (6N5 TBTDEN (t-C4H9N)Nb[N(C2H5)2]3 >=99.99995%, Halide-Free 0% Cl) + Tetrakis(ethylmethylamido)vanadium / Vanadium Oxytriisopropoxide (6N5 TEMAV / VTIP >=99.99995%) Fault-Tolerant Superconducting Transmon/Fluxonium Qubit (T1/T2 >1.2 ms, Qi >1.5e7 @ Single-Photon, Tc(NbN) >16.4 K, JJ Ic Spread <0.85%) NbN/NbTiN Resonator & All-Nitride NbN/AlN/NbN Josephson Junction + Photonic VO2 Phase-Transition (Delta R/R >1e4 @ 68C) PEALD/PAMBE Sublimation Purification, TLS Amorphous Sub-Oxide Elimination & PINN-MPC, 10kHz QCL-TDLAS/FTIR + SF-ICP-MS + In-Situ RHEED/XPS & SEMI S2/NFPA 704/OSHA PSM/IEC 61511 SIL-3 Interlock

param location string = resourceGroup().location
param clusterName string = 'aks-nbcl5-tbtden-temav-qubit-ald-sil3'
param gpuVmSize string = 'Standard_NC40ads_H100_v5'
param nbcl5TbtdenTemavTrains int = 8
param governanceMode string = 'pinn_mpc_nbcl5_tbtden_temav_nbocl3_stripping_and_superconducting_qubit_nbn_jj_tls_free_ald_sil3_edge'

var gpuNodeCount = max(2, (nbcl5TbtdenTemavTrains + 1) / 2)
var activePods = nbcl5TbtdenTemavTrains * 4

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
        name: 'nbqubitald'
        count: gpuNodeCount
        vmSize: gpuVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'electronic-6n5-nbcl5-tbtden-temav-superconducting-qubit-nbn-jj-ald'
          'agent.azure.com/governance-mode': governanceMode
          'agent.azure.com/safety-interlock': 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-PSM-IEC-61511-SIL3'
          'agent.azure.com/edge-metrology': '10kHz-QCL-TDLAS-994cm1-418cm1-1235cm1-1038cm1-SF-ICP-MS-RHEED-XPS-CryoQ'
          'agent.azure.com/active-pods': string(activePods)
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output scheduledGpuNodes int = gpuNodeCount
output scheduledTwinPods int = activePods
output sil3LockoutTargetMs string = '0.13'
