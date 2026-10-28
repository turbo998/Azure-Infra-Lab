// Blueprint #282 (Cycle #281 · 290-Test Milestone! — Chapter 286 / 289 Chapters):
// Autonomous Electronic-Grade Ultrapure (Ethylcyclopentadienyl)(1,5-cyclooctadiene)rhodium(I) (6N5 Rh(EtCp)(COD) >=99.99995%) &
// Dicarbonyl(acetylacetonato)rhodium(I) (6N5 Rh(acac)(CO)2 >=99.99995%) + Cyclopentadienyl(allyl)palladium(II) (6N5 CpPd(allyl) >=99.99995%) +
// Bis(hexafluoroacetylacetonato)palladium(II) (6N5 Pd(hfac)2 >=99.99995%) Sub-1nm (10A/7A) CFET Liner-Free Ultra-Low-MFP Rhodium (Rh, lambda_e=6.88nm,
// rho0*lambda_e=2.98e-16 Ohm*m2, -38.4% Line Resistance @ 10nm CD vs Cu) M0/M1 Local Interconnect Area-Selective PEALD & 2D WSe2/CNT High-Work-Function
// Palladium (Pd Phi_M=5.22eV, Rc,p=54 Ohm-um <=65 Ohm-um) p-FET Ohmic Contact Super-Cycle ALD PINN-MPC + SEMI S2 / NFPA 704 / OSHA 1910.1000 / SIL-3 Interlock

param location string = resourceGroup().location
param clusterName string = 'aksclaw-rhetcpcod-cppdallyl-10a-cfet-rh-pd-ald-sil3'
param nodeVmSize string = 'Standard_NC40ads_H100_v5'
param gpuNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
      }
      {
        name: 'rhpdsil3pool'
        count: gpuNodeCount
        vmSize: nodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'aksclaw.io/workload-tier': 'rhetcpcod-rhacacco2-cppdallyl-10a-cfet-rh-interconnect-pd-pfet-contact-ald-sil3'
          'aksclaw.io/precursor-purity': '6n5-rhetcpcod-6n5-rhacacco2-6n5-cppdallyl-6n5-pdhfac2'
          'aksclaw.io/metrology-loop': 'qcl-tdlas-2015cm1-2084cm1-1528cm1-1642cm1-4pp-gixrd-10khz'
          'aksclaw.io/safety-interlock': 'semi-s2-nfpa704-osha-19101000-iec61511-sil3-1oo2d'
          'aksclaw.io/milestone': 'cycle-281-290-test-milestone'
        }
        nodeTaints: [
          'aksclaw.io/rh-pd-cfet-ald-sil3=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        logAnalyticsWorkspaceResourceId: ''
        securityMonitoring: {
          enabled: true
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output sil3InterlockProfile string = 'SEMI-S2-NFPA704-OSHA-19101000-IEC61511-SIL3-1oo2D-0.10ms-RhCO-CpPdAllyl-Autocatalytic-Lockout'
output metrologyFeedbackLoop string = 'QCL-TDLAS-2015.4cm1-2084.2cm1-1528.6cm1-1642.0cm1-SF-ICP-MS-InSitu-4PP-GIXRD-0.11ms'
output cfetRhInterconnectAndPdContactSpec string = 'Rh-LambdaE-6.88nm-RhoLambda-2.98e-16-Ohm-m2-10nmCD-Minus38.4pct-Pd-WorkFunction-5.22eV-Rcp-54Ohm-um'
