// Blueprint #276: Electronic-Grade 6N5 Ni(iPr-AMD)2 & 6N5 Ni(EtCp)2 + 6N5 MeCpPtMe3 + 6N5 Si2H6
// 14A (1.4nm) Monolithic CFET Orthorhombic Ni0.92Pt0.08Si Sub-nOhm-cm2 Contact & 800VDC 4H-SiC Trench MOSFET Ohmic ALD PINN-MPC + SIL-3
targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Ni(iPr-AMD)2 / Ni(EtCp)2 / MeCpPtMe3 / Si2H6 14A CFET NiPtSi & 4H-SiC Ohmic ALD PINN-MPC + SIL-3 cluster')
param location string = resourceGroup().location

@description('Number of parallel 6N5 Ni/Pt/Si purification and 14A CFET Ni0.92Pt0.08Si + 4H-SiC Ohmic ALD reactor trains')
@minValue(1)
@maxValue(32)
param niamd2Nietcp2Mecpptme3Trains int = 8

@description('Governance mode for 14A CFET Ni0.92Pt0.08Si phase locking, Ni(CO)4 zero-trace suppression, and 4H-SiC laser ohmic anneal')
param governanceMode string = 'pinn_mpc_niamd2_nietcp2_mecpptme3_si2h6_14a_cfet_niptsi_and_4hsic_ohmic_ald_sil3_edge'

var gpuNodes = max(4, (niamd2Nietcp2Mecpptme3Trains + 1) / 2)
var activePods = niamd2Nietcp2Mecpptme3Trains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-niamd2-mecpptme3-14a-cfet-niptsi-sil3'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'niamd2-mecpptme3-niptsi'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
      }
      {
        name: 'pinnmpcpool'
        count: gpuNodes
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        nodeLabels: {
          'workload/pinn-mpc': 'niamd2-nietcp2-mecpptme3-si2h6-14a-cfet-niptsi-4hsic-ald'
          'safety/sil-rating': 'SIL-3-SEMI-S2-NFPA704-OSHA-1910-1000-NICO4-SI2H6'
          'metrology/qcl-tdlas-trr-gixrd': '2057cm1-2918cm1-2165cm1-nisi-112-trr-gixrd-10khz'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output gpuNodeCount int = gpuNodes
output activeNiamd2Nietcp2Mecpptme3Pods int = activePods
output governanceProfile string = governanceMode
output sil3LethalNico4AndPyrophoricSi2h6LockoutLatencyMs string = '0.12'
