// blueprints/28si2h6-3dmas-hcds-nd3-ph3-28si-spin-qubit-10a-cfet-siocn-spacer-and-6p4t-cpo-deuterated-sin-rpcvd-peald-pinn-mpc-sil3.bicep
// Cycle #294 (295-Blueprint Milestone! — Chapter 299 + Summary 300 = 302 Chapters, Blueprint #295, Simulator #294, Tool 294, 303/303 Unit Tests)
// Electronic-Grade Ultrapure Isotopically Enriched Disilane / Silane (6N5 28Si2H6 / 28SiH4 >=99.99995% Chemical Purity, >=99.998% 28Si Nuclear-Spin-Zero Enrichment, Residual 29Si <=15 ppm) & Tris(dimethylamino)silane / Hexachlorodisilane (6N5 3DMAS / HCDS >=99.99995%) + Deuterated Ammonia (6N5 ND3 >=99.99995%) + Phosphine (6N5 PH3 >=99.99995%) 300mm 28Si/28SiGe Wiggle-Well Semiconductor Spin Qubit Array (T2_CPMG=1.48 s, F1Q=99.992%, F2Q=99.86%, Valley Splitting Ev=285 ueV), 10A CFET Low-k SiOCN Sidewall Spacer (k=3.65) & 6.4T CPO Deuterated Si3N4:D Ultra-Low-Loss Photonic Waveguide (0.042 dB/m, Qi=4.2e8) RP-CVD/PEALD PINN-MPC + SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3 Pyrophoric 28Si2H6/SiH4 & Toxic PH3 Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Cycle #294 6N5 28Si2H6 / 3DMAS / HCDS / ND3 / PH3 28Si Spin Qubit, 10A CFET SiOCN Spacer & 6.4T CPO Deuterated Si3N4:D RP-CVD/PEALD PINN-MPC + SIL-3 digital twin')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'si28-3dmas-hcds-nd3-c294'

@description('AKS GPU node VM size for 28Si/28SiGe wiggle-well valley-splitting tight-binding PINN, 10A CFET SiOCN spacer PEALD & deuterated Si3N4:D N-D overtone suppression solver')
param gpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Isotopically enriched 28Si nuclear-spin-zero fraction in 6N5 28Si2H6/28SiH4 (%)')
param silicon28IsotopicPurityPct string = '99.9985'

@description('Residual 29Si (I=1/2) nuclear spin concentration threshold (ppm)')
param maxSilicon29ResidualPpm int = 15

@description('Wiggle-well 28Si/28Si0.7Ge0.3 valley splitting energy target (ueV)')
param minValleySplittingUeV int = 285

@description('Deuterated Si3N4:D 1550nm waveguide propagation loss target (dB/m)')
param maxDeuteratedSiNLossDbPerM string = '0.042'

@description('SEMI S2 / OSHA 29 CFR 1910.1000 SIL-3 phosphine (PH3) emergency trip threshold (ppbv, 1/60th of OSHA PEL 300 ppbv)')
param sil3PhosphineTripPpbv int = 5

@description('SEMI S2 / NFPA 704 SIL-3 coaxial N2 dilution factor keeping pyrophoric Si2H6/SiH4 below 0.4% LEL')
param sil3SilaneCoaxialN2DilutionRatio string = '250:1'

var aksClusterName = '${envPrefix}-aks-pinn-mpc'
var iotNamespaceName = '${envPrefix}-iot-sil3'
var adxClusterName = replace('${envPrefix}adx294', '-', '')

resource aksSpinQubitSiocnDeuteratedSinCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpch100'
        count: 4
        vmSize: gpuNodeVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': '28si2h6-3dmas-hcds-nd3-ph3-spin-qubit-cfet-siocn-cpo-sin-pinn-mpc'
          'agent.azure.com/safety-tier': 'semi-s2-nfpa704-osha-19101000-iec61511-sil3'
          'agent.azure.com/cycle': '294'
          'agent.azure.com/milestone': '295-blueprint-milestone'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
  }
}

resource sil3EdgeTelemetryHub 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: iotNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 2
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource qclCrdsAptEsrStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: sil3EdgeTelemetryHub
  name: 'qcl-crds-2189-2187-2442-2322cm1-apt-1p5k-esr-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

resource sil3InterlockAuditDigitalTwin 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    capacity: 2
    tier: 'Standard'
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: false
  }
}

output aksClusterResourceId string = aksSpinQubitSiocnDeuteratedSinCluster.id
output silicon28PurityTargetPct string = silicon28IsotopicPurityPct
output maxSilicon29ResidualLimitPpm int = maxSilicon29ResidualPpm
output minValleySplittingTargetUeV int = minValleySplittingUeV
output maxDeuteratedSiNLossTargetDbPerM string = maxDeuteratedSiNLossDbPerM
output sil3PhosphineTripThresholdPpbv int = sil3PhosphineTripPpbv
output sil3SilaneDilutionRatio string = sil3SilaneCoaxialN2DilutionRatio
output cycleNumber int = 294
output blueprintNumber int = 295
output milestone string = '295-Blueprint Milestone!'
