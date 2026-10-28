// ============================================================================
// Blueprint #289: Autonomous Electronic-Grade Ultrapure Borazine (6N5 B3N3H6)
// & Tris(dimethylamino)borane (6N5 TDMAB) + Bis(N,N'-diisopropylacetamidinato)nickel(II)
// (6N5 Ni(iPr-AMD)2) + Dimethylamine Alane (6N5 DMAA) Sub-1nm (10A/7A CFET) 2D
// Hexagonal Boron Nitride (h-BN) Van der Waals Dielectric Interface, M0/M1 B2-NiAl
// Intermetallic Interconnect & Room-Temperature h-BN Quantum Single-Photon Emitter
// PEALD / ALE PINN-MPC & SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3
// (Cycle #288 — Chapter 293 + Summary 294 = 296 Chapters)
// ============================================================================

@description('Azure region for the 6N5 B3N3H6 / TDMAB / Ni(iPr-AMD)2 / DMAA 10A CFET 2D h-BN & B2-NiAl PEALD/ALE digital twin')
param location string = resourceGroup().location

@description('Environment prefix for 6N5 Borazine / Nickel-Aluminide PEALD/ALE control plane')
param environmentPrefix string = 'b3n3h6-nial-10a'

@description('AKS system node VM size for deterministic edge telemetry & SIL-3 safety PLC orchestration')
param systemNodeVmSize string = 'Standard_D16s_v5'

@description('GPU node VM size for 2D h-BN van der Waals epitaxy & B2-NiAl ordering PINN-MPC solver')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Maximum 10A CFET 2D h-BN / 2D TMD interface trap density Dit in cm^-2*eV^-1')
param maxInterfaceTrapDensityCm2Ev int = 10000000000

@description('Maximum M0/M1 7nm B2-NiAl intermetallic interconnect resistivity in nOhm*m (11.0 uOhm*cm = 110 nOhm*m)')
param maxB2NiAlResistivityNOhmM int = 110

@description('Maximum exhaust diborane / borazine hydride concentration before SIL-3 1oo2D DBB trip in ppbv (OSHA PEL B2H6 = 100 ppbv)')
param maxDiboraneTripPpbv int = 10

@description('SIL-3 emergency 1oo2D DBB valve isolation and Alane/Borazine quench response budget in microseconds')
param sil3InterlockBudgetUs int = 100

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemNodeVmSize
        osType: 'Linux'
        mode: 'System'
        workloadRuntime: 'KataMshvVmIsolation'
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: gpuNodeVmSize
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent-infra/workload': 'b3n3h6-tdmab-niipramd2-dmaa-10a-cfet-hbn-b2-nial-spe-ald-pinn-mpc'
          'agent-infra/safety-tier': 'semi-s2-nfpa704-osha1910-iec61511-sil3'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
    AutoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
  }
  tags: {
    Cycle: '288'
    Chapter: '293'
    BlueprintId: '289'
    Precursors: '6N5-B3N3H6-6N5-TDMAB-6N5-Ni-iPr-AMD-2-6N5-DMAA'
    MaxInterfaceTrapDitCm2Ev: string(maxInterfaceTrapDensityCm2Ev)
    MaxB2NiAlResistivityNOhmM: string(maxB2NiAlResistivityNOhmM)
    MaxDiboraneTripPpbv: string(maxDiboraneTripPpbv)
    Sil3InterlockBudgetUs: string(sil3InterlockBudgetUs)
  }
}

output clusterName string = aksCluster.name
output pinnMpcWorkloadLabel string = 'b3n3h6-tdmab-niipramd2-dmaa-10a-cfet-hbn-b2-nial-spe-ald-pinn-mpc'
output sil3SafetyStandard string = 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-1910.1000-IEC-61511-SIL-3'
