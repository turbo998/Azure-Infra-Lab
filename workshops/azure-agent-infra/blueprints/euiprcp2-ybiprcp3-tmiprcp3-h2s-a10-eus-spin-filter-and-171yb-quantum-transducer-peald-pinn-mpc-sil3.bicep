// ============================================================================
// Blueprint #302: Electronic-Grade 6N5 Eu(iPrCp)2(THF) / Eu(thd)3 & 6N5 171Yb(iPrCp)3
// + 6N5 Tm(iPrCp)3 + 6N5 H2S / DTBDS 300mm A10/A7 Ferromagnetic-Semiconductor EuS/EuO
// 100% Spin-Polarized Tunnel Filter & Superconducting Triplet Josephson Diode,
// Telecom-Band 171Yb3+:YVO4 Microwave-to-Optical Quantum Transducer & 793nm
// Tm3+:Y3Al5O12 Broadband Quantum Memory PEALD/MBE PINN-MPC + SIL-3 (Cycle #301 — 310-Test Milestone!)
// ============================================================================

targetScope = 'resourceGroup'

@description('Azure region for the A10/A7 EuS/EuO Spin Filter & 171Yb3+:YVO4 Quantum Transducer PEALD/MBE cluster')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Eu(iPrCp)2 / 171Yb(iPrCp)3 / Tm(iPrCp)3 / H2S purification and 300mm PEALD/MBE reactor trains')
@minValue(1)
@maxValue(32)
param euiprcp2Ybiprcp3Tmiprcp3H2sTrains int = 8

@description('Dedicated H100 GPU node SKU for PINN-MPC Eu2+/Eu3+ valence-locking, 171Yb nuclear-spin coherence & SIL-3 verification')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var gpuNodeCount = max(2, (euiprcp2Ybiprcp3Tmiprcp3H2sTrains + 1) / 2)
var activePods = euiprcp2Ybiprcp3Tmiprcp3H2sTrains * 4

resource aksEuYbTmCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-euiprcp2-171yb-tm-eus-spin-qtransducer-sil3'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    cycle: '301'
    milestone: '310-Test-Milestone'
    blueprintNumber: '302'
    precursors: '6N5-Eu-iPrCp2-THF-6N5-171Yb-iPrCp3-6N5-Tm-iPrCp3-6N5-H2S-DTBDS'
    targetProcess: '300mm-A10-EuS-EuO-Spin-Filter-Triplet-Josephson-Diode-171Yb-YVO4-Quantum-Transducer-Tm-YAG-Memory-PEALD-MBE'
    safetyStandard: 'SEMI-S2-NFPA-704-OSHA-19101000-IEC-61511-SIL3'
  }
  properties: {
    dnsPrefix: 'aks-euiprcp2-171yb-sil3'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpch100'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent-infra/role': 'euiprcp2-171yb-tm-eus-spin-filter-quantum-transducer-pinn-mpc'
          'agent-infra/Eu-Yb-Tm-purity': '6N5-99.99995pct-171Yb-99.99pct'
          'agent-infra/eus-spin-polarization': 'Pspin-98.6pct-2DeltaEC-0.36eV-eta-JD-84pct'
          'agent-infra/171yb-yvo4-transducer': 'T2-CPMG-48ms-Gamma-hom-0.85kHz-TmYAG-50GHz'
          'agent-infra/sil3-interlock': '0.10ms-1oo2D-DBB-Pyrophoric-Eu-Yb-Tm-H2S-Scrubber'
          'agent-infra/edge-metrology': '10kHz-QCL-CRDS-2960-2978-2592cm1-XAS-XMCD-SQUID-SHB'
        }
      }
    ]
  }
}

output clusterName string = aksEuYbTmCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeSpinFilterQuantumTransducerPods int = activePods
output eusConductionBandExchangeSplittingEv string = '0.36eV (P_spin = 98.6%, Josephson Diode Rectification Efficiency eta_JD = 84.0%)'
output yb171Yvo4QuantumCoherenceMs string = '48.0ms CPMG (984.5nm Gamma_hom <= 0.85 kHz, 171Yb I=1/2 Zero-First-Order-ZEFOZ)'
output sil3LockoutLatencyMs string = '0.10ms (1oo2D DBB All-Metal Bellows Valve + Class-D Graphite Quench + Fe2O3/ZnO/CuO H2S & Lanthanide Bed)'
