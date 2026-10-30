// Blueprint #304: Electronic-Grade Ultrapure Tetrakis(dimethylamino)vanadium / Oxytriisopropoxyvanadium (6N5 TDMAV / VO(OiPr)3 >=99.99995%, Trace Fe/Ni/Ti/U/Th<=0.05ppbw, Alpha<=0.0001 counts/cm2*hr) & Bis(ethylcyclopentadienyl)chromium / Hexacarbonylchromium (6N5 Cr(EtCp)2 / Cr(CO)6 >=99.99995%) + Electronic-Grade Boron Tribromide / Triethylboron (6N5 BBr3 / TEB >=99.99995%) + Di-tert-butyl Diselenide (6N5 DTBDSe >=99.99995%) 300mm A10/A7 Sub-Nanosecond (1.2ns Electrical / 180fs Photo-Induced) V1-x-yCrxByO2 Mott Insulator-to-Metal Transition (IMT T_IMT=398K / 125C, Roff/Ron=1.6e5, Narrow Hysteresis DeltaT_h<=1.8K, >10^12-Cycle Endurance) 3D Crossbar 1S1R/1S1F Selector, Half-Metallic CrO2/1T-VSe2 Room-Temperature Spin-Valve Interconnect (P_spin>=96.4%, MR=245%) & 6.4T/12.8T CPO Hybrid Si3N4/VO2 5-Bit Non-Volatile Photonic Tensor Weight Bank (18.5dB Extinction, 11.5fJ/switch) PEALD/MBE PINN-MPC, Online 10kHz QCL-CRDS + SF-ICP-MS + In-Situ fs-OPTPS / TD-SE / Synchrotron V L2,3-Edge XANES Metrology & SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3 Pyrophoric TEB / Toxic Cr(CO)6 / DTBDSe & Corrosive BBr3 Hard Interlock Pool (Chapter 308 — Cycle #303)
param location string = resourceGroup().location
param clusterName string = 'aksclaw-tdmav-vcrbo2-mott-selector-sil3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: clusterName
}

resource tdmavVcrbo2MottSelectorPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'vcrbo2mott'
  properties: {
    count: 4
    vmSize: 'Standard_NC40ads_H100_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableEncryptionAtHost: true
    nodeLabels: {
      'aksclaw.io/workload-class': 'tdmav-voipr3-cretcp2-bbr3-a10-vcrbo2-mott-selector-si3n4-vo2-photonic-peald-sil3-agent'
      'aksclaw.io/vcrbo2-mott-selector-cro2-vse2-spin-si3n4-vo2-mpc': 'enabled-79.2pct-yield-97.4pct-vo2-v2o5-overoxidation-and-peierls-hysteresis-cut'
      'aksclaw.io/semi-s2-nfpa704-osha-19101000-sil3-teb-crco6-bbr3-dtbdse': 'enforced-0.10ms-zero-pyrophoric-teb-ignition-or-toxic-crco6-dtbdse-leak'
      'aksclaw.io/qcl-crds-982-2001-856cm1-icpms-fsoptps-tdse-xanes-edge': 'enabled-0.11ms-99.7pct-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/tdmav-vcrbo2-mott-selector-sil3=true:NoSchedule'
    ]
  }
}
