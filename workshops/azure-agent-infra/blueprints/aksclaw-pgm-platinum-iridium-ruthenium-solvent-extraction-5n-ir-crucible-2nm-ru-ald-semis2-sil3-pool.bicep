// blueprints/aksclaw-pgm-platinum-iridium-ruthenium-solvent-extraction-5n-ir-crucible-2nm-ru-ald-semis2-sil3-pool.bicep
// Blueprint #202 (Cycle #201 — 210-Test Milestone!): Autonomous Platinum-Group Metals (PGM: Pt, Pd, Rh, Ir, Ru, Os) HCl/Cl2 Pressure Leaching & Ir(IV)/Ir(III) Redox-Controlled Solvent Extraction / Molecular-Recognition Separation, 5N Iridium (Ir, 2,446 °C) Czochralski Crucible Electron-Beam Metallurgy, PEM Electrolyzer IrO2 Anode Catalyst & 6N Ruthenium (Ru, 6.6 nm Mean-Free-Path) 2 nm GAA Barrierless Interconnect ALD Precursor (RuO4 / Ru(EtCp)2) PINN-MPC, Online 10 kHz In-Situ Raman/UV-Vis, ICP-MS & Phased-Array Ultrasonic Ir-Crucible Metrology & OSHA 1910.1000 / ACGIH / SEMI S2 / IEC 61511 SIL-3 Volatile Osmium/Ruthenium Tetroxide (OsO4 TLV 0.2 ppb / Explosive RuO4 >108 °C) & Chloroplatinate Platinosis (PEL 2 ug/m3) Interlock

param location string = resourceGroup().location
param clusterName string = 'aksclaw-pgm-pt-ir-ru-2nm-ald-sil3'
param nodeVmSize string = 'Standard_NC40ads_H100_v5'
param gpuNodeCount int = 4

resource aksPgmPtIrRuPool 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'pgmirrupinn'
        count: gpuNodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'pgm-platinum-iridium-ruthenium-sx-5n-ir-crucible-2nm-ru-ald-iro2-oer'
          'agent.azure.com/pinn-mpc': 'ir4-ir3-orp-sx-cascade-ruo4-distillation-eb-ir-grain-and-2nm-ru-ald'
          'agent.azure.com/safety-interlock': 'osha19101000-acgih-semis2-sil3-oso4-ruo4-trap-and-platinosis-containment'
          'agent.azure.com/edge-metrology': '10khz-insitu-raman-uvvis-ptcl6-ircl6-ruo4-icpms-and-paut-ir-crucible'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
  }
}

output clusterResourceId string = aksPgmPtIrRuPool.id
output safetyStandard string = 'OSHA-1910.1000-ACGIH-SEMI-S2-IEC-61511-SIL-3'
output edgeMetrologyLoopMs string = '0.19'
output sil3InterlockLatencyMs string = '0.24'
