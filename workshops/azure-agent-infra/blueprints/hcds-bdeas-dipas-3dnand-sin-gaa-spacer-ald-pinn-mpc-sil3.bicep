// blueprints/hcds-bdeas-dipas-3dnand-sin-gaa-spacer-ald-pinn-mpc-sil3.bicep
// Blueprint #248 (Cycle #247 · 255-Chapter Milestone!): Autonomous Electronic-Grade Bis(diethylamino)silane (6N BDEAS H2Si(N(C2H5)2)2 >=99.9999%, b.p. 72.0C @ 10Torr, Ultra-Low Cl <=0.05ppmw, Schlenk Disproportionation <=0.08mol%) & Diisopropylaminosilane (6N DIPAS H3SiN(iPr)2 >=99.9999%, b.p. 131.0C, v.p. 18.5Torr @ 25C) + Bis(tertiary-butylamino)silane / Tris(dimethylamino)silane (6N BTBAS / 6N 3DMAS >=99.9999%) 2nm GAA Sub-1.5nm Ultrathin Low-k Gate Sidewall Spacer (SiBCN/SiOCN k <=4.1, Dilute HF WERR <0.15nm/min, Chlorine-Free Zero NH4Cl Salt) & EUV Self-Aligned Double/Quadruple Patterning (SADP/SAQP 50-150C Conformal SiO2 Spacer PEALD Preserving Photoresist Mandrel) Halide-Free Aminolysis, Short-Path Vacuum Rectification & Steric-Hindrance Seeded PEALD PINN-MPC, Online 10kHz QCL-TDLAS/FTIR (2145cm-1 Si-H / 938cm-1 Si-N / 1182cm-1 C-N / 3380cm-1 Free Amine N-H) + 1H/29Si-NMR + CIC/ICP-MS/MS Metrology & SEMI S2/SEMI C3/NFPA 30/IEC 61511 SIL-3 Moisture-Catalyzed Aminosilane Exothermic Dehydrogenative Silazane Condensation (Si-H + H2O -> Si-O-Si + H2 + Et2NH Overpressure) & DLI Vaporizer Gelation Hard Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 6N BDEAS & 6N DIPAS + 6N BTBAS/3DMAS 2nm GAA SiBCN/SiOCN Low-k Spacer & EUV SADP/SAQP Conformal PEALD digital twin')
param location string = resourceGroup().location

@description('Environment name (prod / staging)')
@allowed([
  'prod'
  'staging'
])
param environment string = 'prod'

@description('Number of parallel 6N BDEAS / 6N DIPAS / 6N BTBAS short-path vacuum rectification, DLI vapor delivery, and 2nm GAA / EUV SADP-SAQP low-temp PEALD trains (2 to 32)')
@minValue(2)
@maxValue(32)
param hcdsBdeasAldTrains int = 8

var aksClusterName = 'aks-bdeas-dipas-ald-mpc-${environment}'
var iotHubName = 'iothub-bdeas-tdlas-sil3-${environment}'
var adxClusterName = 'adxbdeasald${environment}'
var pinnNodesCount = max(2, (hcdsBdeasAldTrains + 1) / 2)

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: max(2, hcdsBdeasAldTrains / 4)
  }
  properties: {
    minTlsVersion: '1.2'
    disableLocalAuth: true
    cloudToDevice: {
      defaultTtlAsIso8601: 'PT1M'
      maxDeliveryCount: 10
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${aksClusterName}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
    }
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
        name: 'pinnmpch100'
        count: pinnNodesCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'agent.azure.com/workload': 'hcds-bdeas-dipas-3dnand-sin-gaa-spacer-ald-pinn-mpc'
          'agent.azure.com/precursor-purity': '6n5-hcds-si2cl6-6n-bdeas-dipas-pyridine'
          'agent.azure.com/safety-interlock': 'semi-s2-c3-nfpa704-un2987-iec61511-sil3-0.14ms'
          'agent.azure.com/edge-metrology': '10khz-qcl-tdlas-raman-418-612-2145-992cm1-cic-icpms'
        }
      }
    ]
  }
}

resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: false
  }
}

output aksClusterId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output pinnGpuNodes int = pinnNodesCount
output sil3InterlockProfile string = 'SEMI-S2-C3-NFPA704-UN2987-IEC61511-SIL3-0.14ms-6N5-HCDS-Si2Cl6-SilicoOxalicAcid-ExplosiveGel-OxidativeNaOH-H2O2-Scrubber-And-6N-BDEAS-DIPAS-LowTemp-ALD-Interlock'
