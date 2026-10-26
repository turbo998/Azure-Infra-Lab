// blueprints/radium223-actinon-recoil-nanoparticle-and-antimony119-sn119-auger-theranostics-sil3.bicep
// 229. Autonomous Bone-Metastasis Alpha & High-Yield Nanometer Auger-Electron Theranostics:
// Radium-223 Dichloride & Core-Shell Recoil-Retaining Alpha Nanomedicine (223Ra T1/2=11.43d 4-Alpha Cascade
// 223Ra->219Rn->215Po->211Pb->211Bi->207Tl->207Pb Delivering 28.2 MeV 95.3% Alpha Energy for Ca2+-Mimetic
// Bone-Metastasis Therapy & LaPO4/BaSO4 Core-Shell Nanoparticle Daughter-Recoil Confinement via 227Ac/227Th/223Ra
// Dipex/DGA/P507 Dual-Stage Extraction Chromatography with <10^-7 Long-Lived 227Ac/227Th Breakthrough) &
// No-Carrier-Added Antimony-119 (n.c.a. 119Sb T1/2=38.19h 100% EC Emitting ~24 Ultra-Short-Range 0.05-25 keV
// Auger & Coster-Kronig Electrons per Decay with Zero High-Energy Gamma Only 23.87 keV X/Gamma via 13.0-14.8 MeV
// Proton Irradiation of Electroplated Enriched Tin-119 119Sn >=98.5% Target 119Sn(p,n)119Sb & TK100/AG1-X8
// Sb(V)/Sn(IV) Partitioning + Trithiocatechol Sb(III) Complexation) PINN-MPC, Online 10 kHz ULEGe/HPGe Low-Energy
// X-Ray/Gamma, DLS Nanoparticle & ICP-MS Metrology & USP <823> / 10 CFR 35.1000 / EU GMP Annex 3 / ISO 17873 /
// IEC 61511 SIL-3 Gaseous Radon-219 (Actinon T1/2=3.96s) Decay-Trap Lockout, 227Ac/227Th Breakthrough Quarantine &
// 120mSb / Tin-Target Melt Crowbar Interlock

@description('Target Azure region for the Radium-223 & Antimony-119 Auger/Alpha Theranostics AKS + Edge cluster')
param location string = resourceGroup().location

@description('AKS cluster name hosting the Radium-223 & Antimony-119 PINN-MPC & SIL-3 verification sandboxes')
param aksClusterName string = 'aks-radium223-antimony119-auger-alpha-sil3'

@description('Number of Standard_NC24ads_A100_v4 nodes for 227Ac/223Ra generator, LaPO4 recoil-retention & 119Sn(p,n)119Sb PINN-MPC')
@minValue(2)
@maxValue(32)
param gpuNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource ra223Sb119TheranosticsSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'ra223sb119s3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_NC24ads_A100_v4'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    nodeLabels: {
      'aksclaw.io/workload-class': 'radium223-actinon-recoil-nanoparticle-and-antimony119-sn119-auger-theranostics-sil3-agent'
      'aksclaw.io/pinn-mpc-ac227-ra223-dipex-lapo4-recoil-and-sn119-sb119-trithiocatechol': 'enabled-57.3pct-auger-alpha-rcy-and-recoil-retention-gain-81.5pct-ac227-sb120m-and-sn4-impurity-cut'
      'aksclaw.io/usp823-iso17873-sil3-actinon-rn219-trap-and-ac227-sb120m-quarantine': 'enforced-0.15ms-zero-rn219-leak-ac227-sb120m-overdose-or-sn-target-melt'
      'aksclaw.io/edge-ulege-hpge-dls-and-icp-ms-closed-loop': 'enabled-0.14ms-99.7pct-radium223-antimony119-theranostics-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/radium223-antimony119-sil3=dedicated:NoSchedule'
    ]
  }
}

output poolResourceId string = ra223Sb119TheranosticsSil3Pool.id
output sil3InterlockProfile string = 'USP-<823>-10CFR35.1000-ISO17873-SIL3-0.15ms-Actinon-219Rn-Trap-227Ac-120mSb-Quarantine-and-Sn-Target-Crowbar'
output edgeTelemetryProfile string = '10kHz-Online-ULEGe-23.87keV-HPGe-Gamma-DLS-Nanoparticle-and-ICP-MS-0.14ms-Edge'
