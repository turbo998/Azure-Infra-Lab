// ============================================================================
// Blueprint #244: Electronic-Grade 5N5 C4F6 (Hexafluoro-1,3-butadiene) &
// 5N5 COS (Carbonyl Sulfide) + 6N c-C4F8 400-Layer+ 3D NAND UHAR Cryogenic
// Dielectric Etch & 2nm GAA Self-Aligned Contact (SAC) ALE PINN-MPC + SIL-3
// ============================================================================

@description('Azure region for 5N5 C4F6 & 5N5 COS 400-Layer+ 3D NAND UHAR Cryo-Etch & 2nm GAA SAC ALE hybrid edge-cloud control plane')
param location string = resourceGroup().location

@description('Environment prefix for 5N5 C4F6 / 5N5 COS / 6N c-C4F8 UHAR Cryo-Etch & GAA SAC ALE deployment')
param environmentPrefix string = 'c4f6cos3dnand'

@description('Target 5N5 C4F6 purity (%) for 400-Layer+ 3D NAND UHAR AR >= 100:1 cryo-etch')
param targetC4f6PurityPct string = '99.9995'

@description('Maximum H2S + CS2 impurity in 5N5 COS (ppmv)')
param maxCosSulfurImpurityPpmv string = '0.15'

@description('Maximum 3D NAND 400-layer channel hole bowing/twisting CD deviation (nm)')
param maxChannelBowingCdNm string = '0.8'

@description('SEMI S2 / NFPA 55 / IEC 61511 SIL-3 C4F6 autopolymerization & COS neurotoxic leak lockout latency target (ms)')
param sil3LockoutLatencyMs string = '0.14'

var aksClusterName = '${environmentPrefix}-aks-arc-sil3'
var iotHubName = '${environmentPrefix}-iothub-10khz'
var adxClusterName = '${environmentPrefix}adxtwin'
var keyVaultName = '${environmentPrefix}-kv-sil3'

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

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
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

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
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
        count: 4
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          workload: 'c4f6-cos-3dnand-uhar-cryo-etch-gaa-sac-ale-pinn-mpc'
          safetyIntegrity: 'semi-s2-nfpa55-iec61511-sil3'
          targetC4f6PurityPct: targetC4f6PurityPct
          maxCosSulfurImpurityPpmv: maxCosSulfurImpurityPpmv
          maxChannelBowingCdNm: maxChannelBowingCdNm
          sil3LockoutLatencyMs: sil3LockoutLatencyMs
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
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
    enablePurge: true
  }
}

output aksClusterId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output keyVaultUri string = keyVault.properties.vaultUri
output sil3SafetyProfile object = {
  blueprintNumber: 244
  processDomain: '5N5_C4F6_5N5_COS_6N_cC4F8_400Layer_3DNAND_UHAR_Cryo_Etch_2nm_GAA_SAC_ALE'
  targetC4f6PurityPct: targetC4f6PurityPct
  maxCosSulfurImpurityPpmv: maxCosSulfurImpurityPpmv
  maxChannelBowingCdNm: maxChannelBowingCdNm
  sil3LockoutLatencyMs: sil3LockoutLatencyMs
}
