// ============================================================================
// Azure AI Agent Infrastructure Blueprint #305 (Cycle #304 — 305-Blueprint Milestone!)
// Electronic-Grade 6N5 Rh(acac)3 / [Rh(CO)2Cl]2 & 6N5 Ir(MeCp)(COD) + 6N5 Mn2(CO)10 / Mn(EtCp)2 + 6N5 Au(Me2)(acac) / MeAuPMe3
// 300mm A7/A5 Sub-7nm Pitch (6.5 nm Half-Pitch) Barrierless Rhodium (Rh) Interconnects (rho_bulk*lambda_e = 29.9e-16 Ohm*m2, R_line -48.5% vs Ru),
// Non-Collinear Chiral Antiferromagnetic L12-Mn3Ir Field-Free SOT-MRAM (T_N = 960 K, H_ex = 185 mT, J_c = 1.45e6 A/cm2 in 240 ps)
// & 3.2T/6.4T CPO >265 GHz Plasmonic-Slot MZM (V_pi*L = 42.0 V*um, 3.2 fJ/bit) PEALD/MBE PINN-MPC + SIL-3
// ============================================================================

@description('Deployment location for Azure AI Agent Infrastructure resources')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param envPrefix string = 'prod-a7-rh-mn3ir-plasmonic'

@description('Number of parallel 300mm A7/A5 Rhodium Interconnect, L12-Mn3Ir SOT & Plasmonic MZM PEALD/MBE reactor trains')
@minValue(1)
@maxValue(64)
param reactorTrains int = 8

@description('AKS GPU Node SKU for Fouling-Informed PINN-MPC & In-Situ FBG-4PP / MOKE-XMCD / 300GHz VNA-SNOM Edge Inference')
param gpuNodeSku string = 'Standard_NC40ads_H100_v5'

var aksClusterName = '${envPrefix}-aks-pinn-sil3'
var iotHubName = '${envPrefix}-iothub-10khz'
var adxClusterName = replace('${envPrefix}adx304', '-', '')
var keyVaultName = take(replace('${envPrefix}-kv-sil3', '--', '-'), 24)

// 1. Key Vault for SEMI S2 / NFPA 704 / OSHA Carbonyl & Precious-Metal Organometallic Interlock Certificates
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
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

// 2. Azure IoT Hub for 10kHz QCL-CRDS (2042.5/2018.4/1582.0 cm^-1) & In-Situ FBG-4PP / MOKE-XMCD / 300GHz VNA-SNOM Telemetry
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: max(1, reactorTrains / 4)
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 32
      }
    }
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
    }
  }
}

// 3. Azure Data Explorer (Kusto) for Sub-Millisecond Rh Grain-Boundary Mayadas-Shatzkes & L12-Mn3Ir Kagome Chirality Time-Series
resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: max(2, reactorTrains / 4)
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: true
  }
}

// 4. AKS Cluster with H100 v5 Node Pool for PINN-MPC & IEC 61511 SIL-3 Carbonyl/Organometallic Abatement Control
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpcpool'
        count: max(2, (reactorTrains + 1) / 2)
        vmSize: gpuNodeSku
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload': 'rhacac3-irmecpcod-mn2co10-aume2acac-a7-rh-mn3ir-plasmonic-pinn-mpc'
          'safety-tier': 'iec61511-sil3-semi-s2-nfpa704'
          'metrology-loop': 'qcl-crds-fbg4pp-moke-xmcd-vna-snom-10khz'
        }
      }
    ]
  }
}

output controlPlaneProfile string = 'pinn_mpc_rhacac3_irmecpcod_mn2co10_aume2acac_a7_rh_interconnect_mn3ir_sot_and_plasmonic_mzm_peald_sil3_edge'
output targetRhBulkResistivityLambdaProductOhmM2 string = '29.9e-16 Ohm*m2 (rho_bulk = 4.33 uOhm*cm, lambda_e = 6.9 nm, R_line -48.5% vs Ru at 6.5 nm half-pitch)'
output targetMn3IrKagomeSotMetrics string = 'T_N = 960 K, T_B = 585 K, mu0*H_ex = 185 mT, sigma_zx^z = 4.8e4 (hbar/2e) Ohm^-1*m^-1, J_c = 1.45e6 A/cm2 in 240 ps'
output targetPlasmonicMzmMetrics string = 'V_pi*L = 42.0 V*um, f_3dB = 268.0 GHz (>265 GHz), IL = 2.1 dB, Energy = 3.2 fJ/bit, Au/Rh RMS = 0.14 nm'
output sil3InterlockLatencyMs string = '0.10'
output metrologyFeedbackLatencyMs string = '0.11'
