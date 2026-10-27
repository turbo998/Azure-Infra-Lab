// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint #242 (Cycle #241 — 250-Test Milestone!)
// Autonomous Electronic-Grade Trimethylaluminum (6N TMA Al(CH3)3 >=99.9999%,
// b.p. 127.1C, m.p. 15.3C, v.p. 8.4Torr @ 20C) & Triethylgallium (6N TEGa
// Ga(C2H5)3 >=99.9999%, b.p. 142.6C) + Trimethylindium (6N TMIn In(CH3)3
// >=99.9999%, Solid m.p. 88.4C, v.p. 1.78Torr @ 20C) 3D NAND High-k Blocking
// Oxide (Al2O3 ALD EOT <=1.35nm, J_leak <=1.2e-8 A/cm^2) & InGaN/GaN Micro-LED
// / InP EEL Low-Carbon Epitaxy (MOCVD [C] <=8.0e15 cm^-3) Ether-Free
// Sesquichloride Dehalogenation & Adduct-Zone Fractional Vacuum Distillation
// (Si/Zn/Mg/Fe <=0.3pptw, Alkoxide R2MOCH3 <=0.08ppmw), Solution-TMIn /
// Porous-Carrier Sublimation Surface-Area Stabilization (Delta F_TMIn <=+/-0.15%)
// & Parasitic Gas-Phase Pre-Reaction (TMA-NH3 / TMIn-NH3 Adduct Nanoparticle
// <=0.01 particles/cm^2) PINN-MPC, Online 10kHz QCL-TDLAS (1210cm^-1 Al-C
// Dimer Bridge / 772cm^-1 In-C Stretch / 1055cm^-1 M-OCH3 Alkoxide Impurity) +
// 1H/27Al-NMR + ICP-MS/MS Metrology & SEMI S2 / NFPA 30 / CGA P-18 / IEC 61511
// SIL-3 Pyrophoric Liquid TMA/TEGa Air/Moisture Ignition (<0.2s Auto-Ignition)
// & Runaway Hydrolysis Overpressure (>3.5 bar) Hard Interlock
// ============================================================================

@description('Deployment region for the Electronic-Grade 6N TMA/TEGa/TMIn 3D NAND Al2O3 ALD & InGaN/GaN MOCVD PINN-MPC + SIL-3 infrastructure.')
param location string = resourceGroup().location

@description('Environment prefix for resource naming.')
param environmentPrefix string = 'tma3dnand242'

@description('AKS Kubernetes version for the AKSClaw Kata VM & PINN-MPC cluster.')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size.')
param systemNodeVmSize string = 'Standard_D8s_v6'

@description('PINN-MPC coupled 6N TMA/TEGa/TMIn distillation/sublimation & 3D NAND Al2O3 ALD / InGaN MOCVD GPU node VM size.')
param pinnGpuNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('Kata VM isolated agent sandbox node VM size.')
param kataSandboxNodeVmSize string = 'Standard_D64s_v6'

@description('Maximum Alkoxide impurity R2MOCH3 threshold in 6N TMA/TEGa/TMIn before distillation cut-divert (ppmw).')
param maxAlkoxideR2moch3Ppmw string = '0.08'

@description('Maximum TMIn solid-bubbler molar pickup drift before acoustic/pressure compensation (%).')
param maxTminPickupDriftPct string = '0.15'

@description('Maximum moisture/O2 ingress in TMA/TEGa cabinet before SEMI S2 / NFPA 30 / SIL-3 dry-powder & N2 isolation (ppmv).')
param maxCabinetMoistureO2Ppmv string = '0.50'

var aksClusterName = '${environmentPrefix}-aksclaw-cluster'
var iotOperationsNamespaceName = '${environmentPrefix}-iotops-ns'
var eventHubNamespaceName = '${environmentPrefix}-ehns'
var keyVaultName = '${environmentPrefix}-kv'
var adxClusterName = '${environmentPrefix}adx'
var adxDatabaseName = 'TmaTegaTmin3dNandAloAldInganMocvdTelemetry'

// 1. Key Vault for Entra Agent ID mTLS certificates & SEMI S2 / NFPA 30 / SIL-3 hardware interlock keys
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
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// 2. Event Hubs Namespace for 10kHz QCL-TDLAS (1210/772/1055cm^-1), Epison Ultrasonic Pickup & ICP-MS/MS Telemetry
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 4
  }
  properties: {
    isAutoInflateEnabled: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
  }
}

resource tdlasEpisonIcpStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'qcl-tdlas-1210-772-1055cm1-epison-nmr-icp-stream'
  properties: {
    messageRetentionInDays: 7
    partitionCount: 32
  }
}

resource sil3TmaPyrophoricInterlockAuditStream 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: eventHubNamespace
  name: 'semi-s2-nfpa30-sil3-tma-pyrophoric-hydrolysis-interlock-audit'
  properties: {
    messageRetentionInDays: 90
    partitionCount: 8
  }
}

// 3. Azure Data Explorer (Kusto) for 6N TMA/TEGa/TMIn Distillation/Sublimation & 3D NAND Al2O3 / InGaN MOCVD Twins
resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E16d_v5'
    tier: 'Standard'
    capacity: 2
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enableStreamingIngest: true
    enablePurge: false
    enableDiskEncryption: true
    enableDoubleEncryption: true
    publicNetworkAccess: 'Disabled'
  }
}

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2023-08-15' = {
  parent: adxCluster
  name: adxDatabaseName
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
}

// 4. Azure IoT Operations Namespace for Ether-Free TMA/TEGa Distillation, Solution-TMIn Bubbler & 3D NAND Al2O3 ALD / InGaN MOCVD
resource iotOperationsNamespace 'Microsoft.DeviceRegistry/namespaces@2024-09-01-preview' = {
  name: iotOperationsNamespaceName
  location: location
  properties: {
    messaging: {
      endpoints: {
        tmaTegaEtherFreeDistillationOpcUaEndpoint: {
          endpointType: 'Microsoft.OpcUa'
          address: 'opc.tcp://10.244.172.10:4840'
        }
        tminPorousCarrierSublimationEpisonEndpoint: {
          endpointType: 'Microsoft.OpcUa'
          address: 'opc.tcp://10.244.172.11:4840'
        }
        nand3dAl2o3AldAndInganMocvdShowerheadEndpoint: {
          endpointType: 'Microsoft.OpcUa'
          address: 'opc.tcp://10.244.172.12:4840'
        }
        semiS2Nfpa30Sil3PyrophoricTmaSafetyPlcEndpoint: {
          endpointType: 'Microsoft.OpcUa'
          address: 'opc.tcp://10.244.172.20:4840'
        }
      }
    }
  }
}

// 5. AKSClaw Cluster with Kata VM Sandbox Isolation & PINN-MPC GPU Node Pool
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentPrefix}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
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
          enabled: false
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinngpupool'
        count: 2
        vmSize: pinnGpuNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
        ]
        nodeLabels: {
          'agent.azure.com/workload-class': 'pinn-mpc-tma-tega-tmin-3dnand-alo-ald-ingan-mocvd'
          'agent.azure.com/alkoxide-r2moch3-limit-ppmw': maxAlkoxideR2moch3Ppmw
          'agent.azure.com/tmin-pickup-drift-limit-pct': maxTminPickupDriftPct
          'agent.azure.com/cabinet-moisture-o2-limit-ppmv': maxCabinetMoistureO2Ppmv
        }
      }
      {
        name: 'katavmpool'
        count: 4
        vmSize: kataSandboxNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        nodeLabels: {
          'agent.azure.com/runtime-isolation': 'kata-mshv-vm'
          'agent.azure.com/safety-interlock': 'semi-s2-nfpa30-cga-p18-sil3-pyrophoric-tma-tega-tmin'
        }
      }
    ]
  }
}

output aksClusterResourceId string = aksCluster.id
output iotOperationsNamespaceResourceId string = iotOperationsNamespace.id
output adxClusterUri string = adxCluster.properties.uri
output sil3SafetyStandard string = 'SEMI-S2-NFPA-30-CGA-P18-IEC-61511-SIL3-Pyrophoric-TMA-TEGa-TMIn-3DNAND-Al2O3-ALD-InGaN-MOCVD-Interlock'
