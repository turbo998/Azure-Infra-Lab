// blueprints/tdmaz-cpzrnme23-temah-1c-dram-har-zaz-hzo-capacitor-and-10a-cfet-ncfet-ald-pinn-mpc-sil3.bicep
// Cycle #282 (290-Chapter Milestone! — Chapter 287 + Summary 288 = 290 Chapters, Blueprint #283, Simulator #282)
// Electronic-Grade Ultrapure Tetrakis(dimethylamino)zirconium(IV) (6N5 TDMAZ Zr(NMe2)4 >=99.99995%, Hf <=0.05ppmw, Fe/Cr/Ni/Na/K <=0.001ppbw)
// & Cyclopentadienyltris(dimethylamino)zirconium(IV) (6N5 CpZr(NMe2)3 >=99.99995%, thermal decomposition >320C for AR 85:1 step coverage >98.5%)
// + Tetrakis(ethylmethylamino)hafnium(IV) (6N5 TEMAH Hf(NMeEt)4 >=99.99995%) + Trimethylaluminum (6N5 TMA Al2(CH3)6 >=99.99995%)
// 300mm High-Aspect-Ratio (AR 85:1, 2.55um Trench / 30nm CD) 1c/0a-Node DRAM ZAZ/HZO-AZA Capacitor (k_eff=46.8, EOT=0.42nm, J_leak=3.2e-8 A/cm2)
// & Sub-1nm (10A) CFET Negative-Capacitance (NC-FET, SS=52.4 mV/dec < 60 mV/dec) Gate Stack Super-Cycle ALD PINN-MPC + SIL-3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 TDMAZ/CpZr(NMe2)3/TEMAH/TMA 1c-DRAM HAR Capacitor & 10A CFET NC-FET ALD edge-cloud digital twin')
param location string = resourceGroup().location

@description('Environment identifier for the 300mm 1c/0a-DRAM HAR 85:1 ZAZ/HZO-AZA & 10A CFET NC-FET ALD control plane')
@allowed([
  'prod-300mm-1cdram-cfet-ncfet-sil3'
  'staging-har85-zaz-hzo-twin'
])
param environment string = 'prod-300mm-1cdram-cfet-ncfet-sil3'

@description('Target 6N5 TDMAZ / CpZr(NMe2)3 / TEMAH / TMA metallic purity fraction (>=0.9999995 = 6N5)')
param targetPrecursorPurityFraction string = '0.9999995'

@description('Maximum nuclear-grade Zr/Hf cross-impurity ceiling in TDMAZ (Hf <= 0.05 ppmw) and trace transition/alkali metals (<= 0.001 ppbw)')
param maxHafniumCrossImpurityPpmw string = '0.05'

@description('Maximum HAR 85:1 (2.55um depth / 30nm CD) 1c-DRAM ZAZ/HZO-AZA equivalent oxide thickness EOT ceiling (nm)')
param maxDramCapacitorEotNm string = '0.48'

@description('Maximum 10A CFET NC-FET subthreshold swing SS ceiling at 300K (mV/decade, < 60 mV/dec Boltzmann limit)')
param maxNcfetSubthresholdSwingMvDec string = '55.0'

@description('SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3 pyrophoric TMA & alkylamide amine-outgassing interlock trip threshold')
param sil3PyrophoricAlkylamideTmaTripPpmv string = '1.0'

var clusterName = 'aksclaw-tdmaz-temah-dram-ncfet-${environment}'
var horizondbNamespace = 'hdb-tdmaz-cpzr-temah-282'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.30.4'
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
        name: 'katapinnmpc'
        count: 12
        vmSize: 'Standard_D96as_v7'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv-vm-isolation'
          'fab.semi.org/process-module': 'tdmaz-cpzr-temah-tma-har85-dram-10a-ncfet-ald'
          'safety.iec61511.org/sil-rating': 'SIL-3'
          ' metrology.qcl-tdlas.org/wavenumbers-cm-1': '2782.4-2864.8-1456.2-1208.5'
        }
        nodeTaints: [
          'KataPodVmOnly=true:NoSchedule'
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
        logAnalyticsWorkspaceResourceId: logWorkspace.id
        securityMonitoring: {
          enabled: true
        }
      }
    }
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${clusterName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource telemetryEventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'ehns-tdmaz-temah-dram-ncfet-282'
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 4
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource qclTdlasTelemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: telemetryEventHubNamespace
  name: 'qcl-tdlas-10khz-tdmaz-temah-tma-har85-ald'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

output aksClusterName string = aksCluster.name
output kataPinMpcPoolVmSize string = 'Standard_D96as_v7'
output precursorPurityTarget string = targetPrecursorPurityFraction
output hafniumCrossImpurityCeilingPpmw string = maxHafniumCrossImpurityPpmw
output dramHar85CapacitorMaxEotNm string = maxDramCapacitorEotNm
output ncfetMaxSubthresholdSwingMvDec string = maxNcfetSubthresholdSwingMvDec
output sil3PyrophoricAlkylamideTmaTripThresholdPpmv string = sil3PyrophoricAlkylamideTmaTripPpmv
output horizondbCheckpointNamespace string = horizondbNamespace
