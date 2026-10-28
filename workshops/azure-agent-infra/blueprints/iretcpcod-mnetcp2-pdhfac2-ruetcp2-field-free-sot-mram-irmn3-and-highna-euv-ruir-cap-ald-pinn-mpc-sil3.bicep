// Blueprint #277: Autonomous Electronic-Grade Ultrapure (Ethylcyclopentadienyl)(1,5-cyclooctadiene)iridium(I) (6N5 Ir(EtCp)(COD) >=99.99995%, Halide-Free Liquid Precursor, m.p. 14C, Rh/Ru/Os/Pd/Pt <=0.005ppbw) & Bis(ethylcyclopentadienyl)manganese(II) (6N5 Mn(EtCp)2 >=99.99995%, Pyrophoric Liquid/Low-Melting Solid, Cr/Fe/Co/Ni <=0.005ppbw) + Bis(hexafluoroacetylacetonato)palladium(II) (6N5 Pd(hfac)2 >=99.99995%) + Bis(ethylcyclopentadienyl)ruthenium(II) (6N5 Ru(EtCp)2 >=99.99995%) 300mm Field-Free Deterministic Spin-Orbit-Torque MRAM (Field-Free SOT-MRAM) Ordered L12-IrMn3 (111) & Non-Collinear Kagome Weyl Semimetal Mn3Sn Antiferromagnetic Pinning Layer (H_ex >1.85 kOe, T_B >385C, |theta_SH| >0.38, J_sw <0.85 MA/cm2 @250ps, Zero Mn Out-Diffusion into 0.95nm MgO via 0.4nm Ru/Pd Barrier) & High-NA EUV (0.55 NA) Collector/Multilayer Mirror 1.8nm Ru1-xIrx Overcoat Capping Layer (13.5nm Actinic Reflectance >68.5%, Zero SnH4 Blistering) Super-Cycle PEALD PINN-MPC & SEMI S2/NFPA 704/OSHA PSM/SIL-3 Sandbox
param location string = resourceGroup().location
param environmentName string = 'prod-iretcpcod-mnetcp2-pdhfac2-ruetcp2-sot-mram-euv-sil3'
param iretcpcodMnetcp2Pdhfac2Trains int = 8

var gpuNodeCount = max(4, (iretcpcodMnetcp2Pdhfac2Trains + 1) / 2)
var activePods = iretcpcodMnetcp2Pdhfac2Trains * 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-${environmentName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: environmentName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
      }
      {
        name: 'pinnmpcgpu'
        count: gpuNodeCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        nodeLabels: {
          'workload/type': 'pinn-mpc-iretcpcod-mnetcp2-pdhfac2-ruetcp2-sot-mram-irmn3-highna-euv-ald'
          'spectroscopy/qcl-tdlas-ftir': '2964cm1-iretcpcod-3081cm1-mnetcp2-1604cm1-pdhfac2-10khz'
          'metrology/insitu-gixrd-stfmr-euv': 'l12-irmn3-order-0p88-thetasheff-0p38-13p5nm-refl-68p5pct'
          'safety/interlock': 'semi-s2-nfpa704-osha-psm-iec61511-sil3-0p12ms'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output gpuNodesAllocated int = gpuNodeCount
output activeIretcpcodMnetcp2Pdhfac2Pods int = activePods
output safetyInterlockSpec string = 'SEMI S2 / NFPA 704 / OSHA 1910.119 / IEC 61511 SIL-3 (0.12ms Pyrophoric Mn(EtCp)2 Auto-Ignition, Pd(hfac)2 HF Abatement & High-NA EUV H2* Radical Overpressure Lockout)'
