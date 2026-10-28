// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #293 (Cycle #292 - 300-Chapter Milestone!)
// Electronic-Grade Ultrapure 6N5 PDMAT / Ta(OEt)5 & 6N5 Sr(iPr3Cp)2 / Ba(iPr3Cp)2
// + 6N5 TDMAT + 6N5 TMBi 0a-Node (<10nm) Ultra-High-k Perovskite Ba0.7Sr0.3TiO3 (BST)
// Capacitor, Fatigue-Free Aurivillius Layered Perovskite SrBi2Ta2O9 (SBT) FeRAM &
// 3.2T/6.4T CPO Heterogeneously Integrated BaTiO3 (BTO) Pockels Electro-Optic Modulator
// & 4K Quantum Microwave-to-Optical Transducer PEALD / MBE PINN-MPC + SIL-3
// ============================================================================

@description('Azure region for the 6N5 PDMAT/Sr(iPr3Cp)2/Ba(iPr3Cp)2/TDMAT/TMBi BST/SBT/BTO PEALD/MBE PINN-MPC digital twin cluster')
param location string = resourceGroup().location

@description('Environment tag for the 300-Chapter Milestone 0a-Node BST/SBT & 6.4T CPO BTO Pockels facility')
@allowed([
  'prod-sil3'
  'staging-twin'
  'compliance-audit'
])
param environment string = 'prod-sil3'

@description('Target 0a-Node Ba0.7Sr0.3TiO3 (BST) dielectric constant k_BST (unitless)')
param targetBstDielectricConstant int = 385

@description('Target 3.2T/6.4T CPO BaTiO3 (BTO) Pockels electro-optic coefficient r42 (pm/V)')
param targetBtoPockelsR42PmPerV int = 920

@description('Maximum OSHA 29 CFR 1910.1000 / NIOSH REL Tantalum/Bismuth/Barium metal-oxide aerosol & amine exhaust threshold (mg/m3)')
param maxExhaustMetalOxideMgPerM3 string = '0.50'

var clusterName = 'aks-pdmat-srba-tdmat-tmbi-bst-sbt-bto-${environment}'
var kvName = 'kv-bst-bto-292-${uniqueString(resourceGroup().id)}'
var iothubName = 'iot-pdmat-srba-bto-sil3-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
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
  name: iothubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    minTlsVersion: '1.2'
    disableLocalAuth: true
    features: 'RootCertificateV2'
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Cycle: '292'
    Milestone: '300-Chapter-Milestone'
    BlueprintId: '293'
    Precursors: '6N5-PDMAT-TaOEt5-Sr_iPr3Cp2-Ba_iPr3Cp2-TDMAT-TMBi'
    ProcessNode: '0a-BST-DRAM-SBT-FeRAM-6p4T-CPO-BTO-Pockels-4K-Transducer'
    SafetyStandard: 'SEMI-S2-NFPA-704-OSHA-1910-1000-IEC-61511-SIL3'
    TargetBstDielectricConstant: string(targetBstDielectricConstant)
    TargetBtoPockelsR42PmPerV: string(targetBtoPockelsR42PmPerV)
    MaxExhaustMetalOxideMgPerM3: maxExhaustMetalOxideMgPerM3
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
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
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnmpcgpu'
        count: 4
        vmSize: 'Standard_ND96isr_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'pinn-mpc-rheed-se-shg-piezo-bto-bst-sbt'
          'safety/sil': 'sil3-iec61511'
          'milestone/chapters': '300'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      ebpfDataplane: 'cilium'
    }
  }
}

output clusterResourceId string = aksCluster.id
output iotHubHostname string = iotHub.properties.hostName
output keyVaultUri string = keyVault.properties.vaultUri
