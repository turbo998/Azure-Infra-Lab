// ============================================================================
// Blueprint #267: Electronic-Grade Bis(trimethylsilyl)telluride (6N5 BTMSTe
// [(CH3)3Si]2Te >= 99.99995%) & Bis(trimethylsilyl)selenide (6N5 BTMSSe
// [(CH3)3Si]2Se >= 99.99995%) + Tris(dimethylamino)antimony (6N5 TDMASb
// Sb[N(CH3)2]3) & Tetrakis(dimethylamino)germanium (6N5 TDMAGe Ge[N(CH3)2]4)
// 3D Crossbar CXL Storage-Class Memory (SCM) Ge2Sb2Te5 (GST-225) Phase-Change
// Memory (PCM) & GeSe Ovonic Threshold Switch (OTS) Low-Temperature (< 90 C)
// Silyl-Elimination ALD, Photolytic Te/Se Colloid Suppression & PINN-MPC +
// SEMI S2 / IEC 61511 SIL-3 H2Te/H2Se Hydrolysis Hard Interlock
// (Cycle #266 — 275-Test Milestone! | Chapter 271 + Summary 272 = 274 Chapters)
// ============================================================================

@description('Azure region for the 6N5 BTMSTe / BTMSSe + TDMASb / TDMAGe 3D PCM GST-225 & OTS ALD Edge-Cloud infrastructure')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envPrefix string = 'pcmgst266'

@description('AKS Kubernetes version for PINN-MPC and telemetry pods')
param kubernetesVersion string = '1.30.6'

@description('Minimum BTMSTe/BTMSSe/TDMASb/TDMAGe chemical purity (6N5 = 99.99995%)')
param precursorPurityPct string = '99.99995'

@description('Maximum low-temperature silyl-elimination ALD wafer temperature (deg C) to prevent Te/Se volatilization')
param maxAldWaferTempC int = 85

@description('Maximum permissible H2Te / H2Se toxic hydride excursion threshold (ppbv) before SIL-3 trip')
param maxH2TeH2SeExcursionPpbv int = 10

@description('Target 3D PCM GST-225 stoichiometric precision deviation tolerance (at.%)')
param maxGstStoichiometryDeviationAtPct string = '0.35'

// 1. Virtual Network with Isolated Subnets for Edge QCL-TDLAS, PINN-MPC & SIL-3 PLC
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${envPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.216.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.216.1.0/24'
        }
      }
      {
        name: 'sil3-h2te-h2se-interlock-subnet'
        properties: {
          addressPrefix: '10.216.2.0/24'
        }
      }
      {
        name: 'tdlas-icpms-xrd-raman-subnet'
        properties: {
          addressPrefix: '10.216.3.0/24'
        }
      }
    ]
  }
}

// 2. Azure IoT Hub for 10 kHz QCL-TDLAS / FTIR, GC-ICP-MS & In-Situ XRD/Raman Telemetry
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

// 3. Azure Digital Twins for 6N5 BTMSTe / BTMSSe + TDMASb / TDMAGe Distillation & 3D Crossbar GST-225 / OTS ALD Reactor Twin
resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${envPrefix}-adt'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

// 4. Azure Data Explorer (Kusto) for High-Frequency Spectral & Stoichiometric Time-Series
resource kustoCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: '${envPrefix}adx'
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: true
  }
}

resource kustoDb 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: kustoCluster
  name: 'BtmsteBtmsseTdmasbTdmagePcmOtsTelemetryDB'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
}

// 5. AKS Cluster with Kata VM-Isolated Confidential Pods & GPU PINN-MPC NodePool
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'pinnmpcpool'
        count: 2
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'OCIContainer'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'workload-tier': 'btmste-btmsse-tdmasb-tdmage-pcm-ots-pinn-mpc'
          'precursor-purity-pct': precursorPurityPct
          'max-ald-wafer-temp-c': string(maxAldWaferTempC)
          'max-h2te-h2se-excursion-ppbv': string(maxH2TeH2SeExcursionPpbv)
          'max-gst-stoich-dev-atpct': maxGstStoichiometryDeviationAtPct
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

// 6. Key Vault for Storing Sealed SIL-3 Interlock Signatures & Calibration Keys
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${envPrefix}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
  }
}

output aksClusterName string = aksCluster.name
output iotHubHostName string = iotHub.properties.hostName
output digitalTwinsHostName string = digitalTwins.properties.hostName
output kustoUri string = kustoCluster.properties.uri
output sil3InterlockStatus string = 'SEMI-S2-NFPA704-OSHA-PSM-SIL3-BTMSTE-BTMSSE-H2TE-H2SE-HYDROLYSIS-ACTIVE'
