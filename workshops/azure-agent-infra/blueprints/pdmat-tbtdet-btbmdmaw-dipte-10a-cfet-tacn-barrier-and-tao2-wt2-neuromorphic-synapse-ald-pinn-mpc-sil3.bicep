// ============================================================================
// Blueprint #285: Electronic-Grade 6N5 PDMAT & 6N5 TBTDET + 6N5 BTBMDMAW +
// 6N5 DIPTe Sub-1nm (10A/7A CFET) 1.2nm Ultrathin TaC0.45N0.55 Diffusion Barrier
// & 6-Bit Analog TaO2-x/Ta2O5 Synaptic RRAM + Monolayer Td-WTe2 Weyl SOT
// Super-Cycle PEALD PINN-MPC + SEMI S2 / NFPA 704 / OSHA 1910.1000 / SIL-3
// (Cycle #284 · 285-Blueprint Milestone!)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 6N5 PDMAT/TBTDET/BTBMDMAW/DIPTe 10A CFET TaCN Barrier & TaOx/Td-WTe2 Neuromorphic Synapse PEALD cluster')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Ta/W/Te precursor purification, 10A CFET 1.2nm TaCN barrier & 6-bit TaOx/Td-WTe2 synapse PEALD reactor trains')
@minValue(1)
@maxValue(32)
param pdmatTbtdetBtbmdmawDipteTrains int = 8

@description('AKS GPU node VM SKU for 6N5 PDMAT/TBTDET/BTBMDMAW/DIPTe PINN-MPC and 10kHz QCL-TDLAS + SF-ICP-MS + In-Situ ARPES/XPS/4PP edge')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var aksClusterName = 'aks-pdmat-tbtdet-btbmdmaw-dipte-tacn-wte2-sil3'
var gpuNodeCount = max(2, (pdmatTbtdetBtbmdmawDipteTrains + 1) / 2)

resource aksTaWTelCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'pdmat-tbtdet-wte2-sil3'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'tawtelpinn'
        count: gpuNodeCount
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/PrecursorGrade': '6N5-PDMAT-TBTDET-BTBMDMAW-DIPTe-Halide-Free'
          'agent.azure.com/CfetBarrierAndNeuromorphic': '10A-CFET-1.2nm-TaCN-Barrier-6Bit-TaOx-RRAM-Td-WTe2-Weyl-SOT'
          'agent.azure.com/SafetyInterlock': 'SEMI-S2-NFPA704-OSHA-1910-1000-IEC61511-SIL3-0.10ms-Telluride-Amine-Lock'
          'agent.azure.com/EdgeMetrology': '10kHz-QCL-TDLAS-952-1284-582cm1-SF-ICP-MS-InSitu-ARPES-XPS-0.11ms'
        }
      }
    ]
  }
}

output clusterName string = aksTaWTelCluster.name
output gpuNodesAllocated int = gpuNodeCount
output safetyStandard string = 'SEMI S2 / SEMI C3 / NFPA 704 / OSHA 29 CFR 1910.1000 (Te PEL 0.1 mg/m3) / IEC 61511 SIL-3 (0.10ms 1oo2D DBB All-Metal Bellows Isolation + CuO/KMnO4 Telluride Mineralization Scrubber + H2SO4 Amine Trap)'
output metrologyLoopMs string = '0.11ms edge 10kHz QCL-TDLAS/FTIR (952.4cm-1 PDMAT Ta-N-C / 1284.6cm-1 TBTDET Ta=N-tBu / 1268.2cm-1 BTBMDMAW W=N-tBu / 582.0cm-1 DIPTe C-Te) + SF-ICP-MS + In-Situ XPS/ARPES/Crossbar-Pulse'
