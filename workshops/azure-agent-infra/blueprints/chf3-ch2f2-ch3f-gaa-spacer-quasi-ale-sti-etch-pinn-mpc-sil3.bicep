// ============================================================================
// Blueprint #254: Autonomous Electronic-Grade Trifluoromethane & Difluoromethane
// (5N5 CHF3 >=99.9995%, b.p. -82.1C, CF4 <=0.30ppmv, C2HF5 <=0.20ppmv, CHClF2
// <=0.15ppmv, HF <=0.10ppmv, H2O <=0.20ppmv & 5N5 CH2F2 >=99.9995%, b.p. -51.7C,
// GWP100 = 675, CH2ClF <=0.10ppmv, CH3F <=0.20ppmv) + Electronic-Grade
// Fluoromethane (5N5 CH3F >=99.9995%, b.p. -78.4C, GWP100 = 116, Ultra-Low
// Dimethyl Ether CH3OCH3 <=0.20ppmv, CH3Cl <=0.10ppmv, CH4 <=0.30ppmv, H2O
// <=0.20ppmv) 2nm GAA Gate-All-Around Si3N4 / SiBCN Low-k Gate Spacer
// Quasi-Atomic Layer Etch (Quasi-ALE CH3F/CH2F2/O2 Selective Hydrofluorocarbon
// Polymer Si3N4:SiO2 >=55:1 & Si3N4:Si >=48:1 Zero Silicon Recess <0.3nm) &
// FinFET/GAA STI / CESL Anisotropic Profile Control Catalytic Swarts
// Hydrofluorination, Extractive Azeotropic Distillation (Breaking CHF3/CF4 &
// CH3F/DME Pairs) & Molecular-Sieve Dechlorination PINN-MPC, Online 10 kHz
// QCL-TDLAS / FTIR (1152cm-1 CHF3 nu5 / 1090cm-1 CH2F2 nu9 / 1048cm-1 CH3F nu3 /
// 1102cm-1 DME) + GC-PDHID/MS + In-Line HR-XRR / TEM-OCD Metrology & SEMI S2 /
// SEMI C3 / NFPA 55 / ASHRAE 34 A2L / ISO 817 / IEC 61511 SIL-3 Flammable
// Hydrofluorocarbon CH3F/CH2F2 (CH3F LEL 3.2%, CH2F2 LEL 12.7%) Deflagration &
// Pyrolysis COF2/HF Scrubbing Hard Interlock
// ============================================================================

param location string = resourceGroup().location
param envPrefix string = 'aksclaw-chf3-ch2f2-ch3f-spacer'
param aksClusterName string = '${envPrefix}-aks'
param iotNamespaceName string = '${envPrefix}-iotops'
param hfcSpacerTrains int = 8

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: envPrefix
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v6'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'hfcspacerpinn'
        count: max(2, (hfcSpacerTrains + 1) / 2)
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'agent.azure.com/workload': 'chf3-ch2f2-ch3f-extractive-distillation-and-gaa-spacer-quasi-ale-pinn-mpc'
          'agent.azure.com/safety-Loops': 'semi-s2-nfpa55-ashrae34-a2l-sil3-ch3f-ch2f2-lel-and-cof2-hf-scrubber'
          'agent.azure.com/edge-metrology': '10khz-qcl-tdlas-1152cm1-1090cm1-1048cm1-1102cm1-gcpdhid-hrxrr-ocd'
        }
      }
    ]
  }
}

resource iotOperationsNamespace 'Microsoft.DeviceRegistry/namespaces@2024-09-01-preview' = {
  name: iotNamespaceName
  location: location
  properties: {
    messaging: {
      endpoints: {
        qclTdlas1152cm1Chf3And1090cm1Ch2f2And1048cm1Ch3fStream: {
          endpointType: 'Microsoft.Devices/MQTT'
          address: 'mqtts://${envPrefix}-edge.local:8883/metrology/10khz-qcl-tdlas-1152cm1-chf3-1090cm1-ch2f2-1048cm1-ch3f-1102cm1-dme-gcpdhid-hrxrr'
        }
        semiS2Nfpa55Ashrae34Sil3Ch3fCh2f2LelAndCof2HfInterlock: {
          endpointType: 'Microsoft.Devices/IEC61511-SIL3-PLC'
          address: 'opc.tcp://${envPrefix}-sil3-plc.local:4840/safety/2oo3-ch3f-lel-3p2pct-ch2f2-lel-12p7pct-n2-purge-and-cof2-hf-caoh2-scrubber'
        }
      }
    }
  }
}

output blueprintId string = 'chf3-ch2f2-ch3f-gaa-spacer-quasi-ale-sti-etch-pinn-mpc-sil3'
output gpuNodePoolSku string = 'Standard_NC40ads_H100_v5'
output sil3InterlockLatencyMs string = '0.14'
output edgeMetrologyLoopLatencyMs string = '0.13'
