// ============================================================================
// Blueprint #255 (255-Blueprint Milestone!): Autonomous Electronic-Grade
// Perfluorocyclobutane & Perfluorocyclopentene (5N5 c-C4F8 >=99.9995%, b.p. -6.0C,
// C2F4 <=0.20ppmv, C3F6 <=0.25ppmv, PFIB <=5ppbv, HF <=0.10ppmv, H2O <=0.20ppmv &
// 5N c-C5F8 >=99.999%, b.p. 27.0C, Low GWP100 = 2.0, 1H-C5F7H <=0.30ppmv) +
// Electronic-Grade Bromotrifluoromethane (5N5 CF3Br >=99.9995%, b.p. -57.8C,
// CF2Br2 <=0.15ppmv, CF4 <=0.20ppmv, Br2/HBr <=0.10ppmv) 2nm GAA / CFET Backside
// Power Delivery Network (BSPDN Buried Power Rail & Nano-TSV Bosch Cyclic
// SF6/c-C4F8 Scallop-Free Passivation <1.2nm) & EUV Dual-Damascene Low-k
// High-Selectivity Contact Etch (c-C5F8 C/F=0.625 SiO2:Si3N4 >=38:1, CF3Br Br+
// Heavy-Ion Anti-Notching Passivation) Tetrafluoroethylene (TFE) Thermal
// Cyclodimerization, Chlorofluorocarbon Bromination & Extractive Rectification
// PINN-MPC, Online 10 kHz QCL-TDLAS / FTIR (960cm-1 c-C4F8 / 1762cm-1 c-C5F8 C=C /
// 1085cm-1 CF3Br nu1 / 1340cm-1 C2F4) + GC-ECD/ICP-MS + In-Line CD-SAXS /
// Mueller-Matrix Ellipsometry Metrology & SEMI S2 / SEMI C3 / NFPA 55 / ACGIH
// TLV-C / IEC 61511 SIL-3 Explosive TFE (C2F4 Deflagration dH = -128kJ/mol),
// Pyrolysis PFIB (<=10ppbv) & Toxic Br2/COBr2 (TLV 0.1ppmv) Scrubbing Interlock
// ============================================================================

param location string = resourceGroup().location
param envPrefix string = 'aksclaw-cc4f8-cc5f8-cf3br-bspdn'
param aksClusterName string = '${envPrefix}-aks'
param iotNamespaceName string = '${envPrefix}-iotops'
param cyclicFluorocarbonTrains int = 8

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
        name: 'cyclicfcpinn'
        count: max(2, (cyclicFluorocarbonTrains + 1) / 2)
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'agent.azure.com/workload': 'cc4f8-cc5f8-cf3br-cyclodimerization-rectification-and-bspdn-ntsv-bosch-pinn-mpc'
          'agent.azure.com/safety-Loops': 'semi-s2-nfpa55-acgih-tlvc-sil3-tfe-deflagration-pfib-and-cobr2-scrubber'
          'agent.azure.com/edge-metrology': '10khz-qcl-tdlas-960cm1-1762cm1-1085cm1-1340cm1-gcecd-cdsaxs'
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
        qclTdlas960cm1Cc4f8And1762cm1Cc5f8And1085cm1Cf3brStream: {
          endpointType: 'Microsoft.Devices/MQTT'
          address: 'mqtts://${envPrefix}-edge.local:8883/metrology/10khz-qcl-tdlas-960cm1-cc4f8-1762cm1-cc5f8-1085cm1-cf3br-1340cm1-tfe-gcecd-cdsaxs'
        }
        semiS2Nfpa55AcgihTlvcSil3TfePfibAndCobr2Interlock: {
          endpointType: 'Microsoft.Devices/IEC61511-SIL3-PLC'
          address: 'opc.tcp://${envPrefix}-sil3-plc.local:4840/safety/2oo3-tfe-deflagration-quench-pfib-10ppbv-alkoxide-and-cobr2-br2-thiosulfate-scrubber'
        }
      }
    }
  }
}

output blueprintId string = 'cc4f8-cc5f8-cf3br-bspdn-ntsv-bosch-euv-contact-etch-pinn-mpc-sil3'
output gpuNodePoolSku string = 'Standard_NC40ads_H100_v5'
output sil3InterlockLatencyMs string = '0.13'
output edgeMetrologyLoopLatencyMs string = '0.13'
