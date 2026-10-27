// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #259 (Cycle #258)
// Electronic-Grade Diborane (5N B2H6 >=99.999%), Isotopically Enriched
// Germanium Tetrafluoride (5N 72GeF4 >=99.999%) & Phosphorus Trifluoride
// (5N5 PF3 >=99.9995%) 2nm GAA Ultra-Shallow Junction (USJ <4.5nm) Pre-
// Amorphization Implantation (PAI) & In-Situ p+ SiGe:B Epitaxy PINN-MPC +
// SEMI S2 / SEMI C3 / NFPA 55 / NFPA 318 / OSHA PSM / IEC 61511 SIL-3 Sandbox
// ============================================================================

@description('Azure region for primary cloud control plane and digital twin')
param location string = resourceGroup().location

@description('Environment prefix for naming')
param environmentPrefix string = 'b2h6-gef4-pf3-usj-pai-sil3'

@description('Number of parallel 5N B2H6 / 5N 72GeF4 / 5N5 PF3 synthesis, SAP sub-atmospheric packaging & 2nm GAA USJ PAI / SiGe:B epitaxy trains (1 to 32)')
@minValue(1)
@maxValue(32)
param b2h6Gef4Pf3UsjTrains int = 8

@description('Cold-chain B2H6 storage jacket temperature setpoint in Celsius (-25 to -10 C to suppress B4H10/B5H9 polymerization)')
param b2h6ColdStorageTempC int = -20

@description('Sub-atmospheric microporous carbon delivery cylinder (SAP/VAC) pressure ceiling in Torr (<650 Torr)')
param sapCylinderMaxPressureTorr int = 600

@description('SEMI S2 / NFPA 55 / NFPA 318 / OSHA PSM / IEC 61511 SIL-3 hardware interlock max latency in microseconds')
param sil3InterlockMaxLatencyUs int = 130

// 1. Virtual Network with strict isolated subnets for Control, Kata Sandboxes, and Edge Safety PLC
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${environmentPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.258.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-kata-pinn-mpc-subnet'
        properties: {
          addressPrefix: '10.258.1.0/24'
        }
      }
      {
        name: 'azure-local-sil3-plc-subnet'
        properties: {
          addressPrefix: '10.258.2.0/24'
        }
      }
      {
        name: 'horizondb-telemetry-subnet'
        properties: {
          addressPrefix: '10.258.3.0/24'
        }
      }
    ]
  }
}

// 2. Azure Key Vault for Keyless Pod & Entra Agent ID Certificates
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: take('${replace(environmentPrefix, '-', '')}kv259', 24)
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

// 3. Azure IoT Hub / Event Hubs for 10 kHz QCL-TDLAS/FTIR (2520/1602/800/892 cm-1), GC-MS/ICP-MS & SIMS/Therma-Probe Edge Telemetry
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${environmentPrefix}-ehns'
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

resource telemetryHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'qcl-tdlas-2520cm1-1602cm1-800cm1-892cm1-sims-thermaprobe-10khz'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 16
  }
}

// 4. AKS Cluster with Kata Pod VM Isolation & GPU Node Pool for B2H6/72GeF4/PF3 USJ PAI & SiGe:B PINN-MPC
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: environmentPrefix
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
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'katapinnpool'
        count: b2h6Gef4Pf3UsjTrains
        vmSize: 'Standard_NC24ads_A100_v4'
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-vm-isolation'
          'industry.azure.com/process': '5n-b2h6-5n-72gef4-5n5-pf3-usj-pai-ion-implant-sige-boron-pinn-mpc'
          'safety.azure.com/standard': 'semi-s2-nfpa55-nfpa318-osha-psm-iec61511-sil3'
        }
      }
    ]
  }
}

output aksClusterName string = aksCluster.name
output sil3TargetLatencyMicroseconds int = sil3InterlockMaxLatencyUs
output b2h6ColdStorageSetpointCelsius int = b2h6ColdStorageTempC
output sapCylinderPressureLimitTorr int = sapCylinderMaxPressureTorr
