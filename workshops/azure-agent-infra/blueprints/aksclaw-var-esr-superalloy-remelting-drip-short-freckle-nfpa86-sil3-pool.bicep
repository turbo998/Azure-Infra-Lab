// ============================================================================
// Azure AI Agent Infra Playbook - Blueprint #138
// Autonomous Aerospace Superalloy & Titanium Vacuum Arc Remelting (VAR) &
// Electroslag Remelting (ESR) Triple-Melt (VIM-ESR-VAR) Ingot Solidification
// Drip-Short Gap, Molten-Pool Lorentz-Buoyancy Macrosegregation (Freckle /
// White-Spot) PINN-MPC & NFPA 86 / NADCAP AMS 2750 / IEC 61508 SIL-3
// Copper Crucible Side-Arc Burn-Through & Crowbar Vacuum-Breaker Pool
// ============================================================================
// Scenario:
//   - High-integrity triple-melt (VIM -> ESR -> VAR) remelting furnaces for
//     rotating jet-engine turbine disks (Inconel 718, René 88DT, Waspaloy,
//     Udimet 720Li) and aerospace structural titanium alloys (Ti-6Al-4V,
//     Ti-6246, Beta-21S) up to 1,000 mm ingot diameter and 15 metric tons.
//   - Physics-Informed Neural Network + Model Predictive Control (PINN-MPC)
//     solves the coupled axisymmetric Stefan solidification front, 30-45 kA DC
//     Lorentz electromagnetic stirring force (J x B), thermal-solutal buoyancy
//     Rayleigh number (Ra_m) in the mushy zone, and droplet drip-short transfer
//     frequency (15-60 Hz) across the 6-14 mm diffuse vacuum arc gap at
//     10^-3 to 10^-4 mbar.
//   - Suppresses interdendritic channel segregates ("freckles"), low-density
//     solidification defects ("discrete white spots" from crown/shelf fallback
//     or unmelted electrode chunks), and concentric ring macrosegregation.
//   - Deterministic edge execution on AKS Automatic + Kata Containers +
//     Hardware Security Module (HSM) + FPGA/PLC safety island enforces
//     NFPA 86 (Class D Vacuum Furnaces), NADCAP AMS 2750 pyrometry traceability,
//     and IEC 61508 SIL-3 hard interlocks:
//       * Sub-millisecond (0.2 ms) detection of parasitic side-arcing to the
//         water-cooled copper crucible wall via differential Hall-effect ring
//         sensors, crucible cooling-water delta-T/pressure-pulse acoustic arrays,
//         and disappearance of drip-short signatures ("glow-discharge / long-arc
//         runaway").
//       * Immediate 45 kA DC solid-state IGCT crowbar + coaxial vacuum circuit
//         breaker trip, main vacuum isolation valve closure, and controlled
//         high-purity helium backfill quench, preventing copper crucible wall
//         burn-through and catastrophic water-molten Ti/Ni steam-hydrogen
//         blast-bunker explosions.
// ============================================================================

targetScope = 'resourceGroup'

@description('Deployment Azure region for the VAR/ESR Superalloy Remelting hybrid cloud control plane')
param location string = resourceGroup().location

@description('Environment prefix (e.g., prod-var-esr-remelt, staging-var-esr)')
@minLength(3)
@maxLength(24)
param environmentPrefix string = 'prod-var-esr-remelt'

@description('AKS Kubernetes version for the VAR/ESR PINN-MPC control plane')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemNodeVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC Axisymmetric Stefan-Lorentz-Buoyancy & Drip-Short Wavelet GPU node VM size')
param pinnMpcNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Kata-isolated NFPA 86 / AMS 2750 / SIL-3 Crucible Side-Arc & Crowbar Interlock node VM size')
param kataSafetyNodeVmSize string = 'Standard_F16s_v2'

@description('Number of VAR & ESR furnace bays managed in the melt-shop blast-bunker cell')
@minValue(2)
@maxValue(36)
param furnaceBayCount int = 12

@description('Nominal VAR DC remelting arc current in kA')
@minValue(10)
@maxValue(60)
param nominalVarArcCurrentKa int = 38

@description('Maximum allowable mushy-zone magnetic-buoyancy freckle Rayleigh criterion (Ra_m_max * 100)')
@minValue(50)
@maxValue(250)
param maxFreckleRayleighIndexX100 int = 95

@description('Enable Azure Managed Prometheus & Grafana telemetry for NADCAP AMS 2750 / NFPA 86 audit trails')
param enableTelemetry bool = true

var clusterName = '${environmentPrefix}-aksclaw'
var logWorkspaceName = '${environmentPrefix}-law'
var keyVaultName = take(replace('${environmentPrefix}kv${uniqueString(resourceGroup().id)}', '-', ''), 24)
var storageAccountName = take(replace('${environmentPrefix}st${uniqueString(resourceGroup().id)}', '-', ''), 24)
var iotNamespaceName = '${environmentPrefix}-iot-ns'

var commonTags = {
  workload: 'var-esr-superalloy-remelting-drip-short-freckle-sil3'
  industry: 'aerospace-metallurgy-superalloy-titanium-remelting'
  safetyStandard: 'NFPA-86-Class-D-NADCAP-AMS-2750-IEC-61508-SIL3'
  architecture: 'AKS-Kata-PINN-MPC-Edge-Safety-Island'
  blueprintId: 'blueprint-138-cycle-137'
}

// ----------------------------------------------------------------------------
// 1. Log Analytics Workspace (Immutable NADCAP AMS 2750 & NFPA 86 Class D Audit)
// ----------------------------------------------------------------------------
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logWorkspaceName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 730
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 60
    }
  }
}

// ----------------------------------------------------------------------------
// 2. Key Vault (HSM-backed signing for Melt-Rate Schedules & SIL-3 Interlocks)
// ----------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// ----------------------------------------------------------------------------
// 3. Immutable Blob Storage (100 kHz Drip-Short Wavelet & Ingot Ultrasonic C-Scan Twin)
// ----------------------------------------------------------------------------
resource meltArchiveStorage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    immutableStorageWithVersioning: {
      enabled: true
    }
    encryption: {
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// ----------------------------------------------------------------------------
// 4. Event Grid Namespace (MQTT v5 Broker for Melt-Shop Blast-Bunker Telemetry)
// ----------------------------------------------------------------------------
resource meltShopMqttBroker 'Microsoft.EventGrid/namespaces@2024-06-01-preview' = {
  name: iotNamespaceName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard'
    capacity: 12
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    isZoneRedundant: true
    publicNetworkAccess: 'Disabled'
    topicSpacesConfiguration: {
      state: 'Enabled'
      maximumSessionExpiryInHours: 8
      maximumClientSessionsPerAuthenticationName: 16
    }
  }
}

resource dripShortTopicSpace 'Microsoft.EventGrid/namespaces/topicSpaces@2024-06-01-preview' = {
  parent: meltShopMqttBroker
  name: 'var-esr-drip-short-and-pool-profile-telemetry'
  properties: {
    description: '100 kHz VAR voltage drip-short wavelet spectrum, 0.1 kg load-cell melt-rate derivative, and ESR slag skin impedance'
    topicTemplates: [
      'meltshop/furnace/+/var/drip-short-wavelet'
      'meltshop/furnace/+/var/loadcell-meltrate'
      'meltshop/furnace/+/esr/slag-bath-impedance'
      'meltshop/furnace/+/pinn/pool-depth-freckle-rayleigh'
    ]
  }
}

resource safetyInterlockTopicSpace 'Microsoft.EventGrid/namespaces/topicSpaces@2024-06-01-preview' = {
  parent: meltShopMqttBroker
  name: 'nfpa86-sil3-crucible-sidearc-crowbar-events'
  properties: {
    description: 'NFPA 86 Class D & IEC 61508 SIL-3 copper crucible side-arc differential Hall ring, cooling-water pressure-spike, and IGCT crowbar trip telemetry'
    topicTemplates: [
      'meltshop/safety/+/crucible/differential-hall-sidearc'
      'meltshop/safety/+/cooling/water-jacket-delta-t-pulse'
      'meltshop/safety/+/rectifier/igct-crowbar-vacuum-breaker'
      'meltshop/safety/+/bunker/helium-backfill-hydrogen-sensor'
    ]
  }
}

// ----------------------------------------------------------------------------
// 5. AKS Cluster with System Pool, PINN-MPC GPU Pool & Kata SIL-3 Safety Pool
// ----------------------------------------------------------------------------
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  tags: commonTags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentPrefix}-dns'
    enableRBAC: true
    disableLocalAccounts: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      imageCleaner: {
        enabled: true
        intervalHours: 24
      }
      defender: {
        logAnalyticsWorkspaceResourceId: logAnalytics.id
        securityMonitoring: {
          enabled: true
        }
      }
    }
    addonProfiles: {
      omsagent: {
        enabled: enableTelemetry
        config: {
          logAnalyticsWorkspaceResourceId: logAnalytics.id
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
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
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
  }
}

// PINN-MPC GPU Pool: Axisymmetric Stefan-Lorentz-Buoyancy Pool & Drip-Short Gap Solver
resource pinnMpcGpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'varpinnpool'
  properties: {
    count: 2
    vmSize: pinnMpcNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    availabilityZones: [
      '1'
      '2'
    ]
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'agent-infra/role': 'var-esr-stefan-lorentz-buoyancy-pinn-mpc'
      'metallurgy/furnace-bays': string(furnaceBayCount)
      'metallurgy/nominal-var-current-ka': string(nominalVarArcCurrentKa)
      'metallurgy/max-freckle-rayleigh-x100': string(maxFreckleRayleighIndexX100)
    }
    nodeTaints: [
      'nvidia.com/gpu=true:NoSchedule'
      'metallurgy-pinn-mpc=true:NoSchedule'
    ]
  }
}

// Kata-Isolated SIL-3 Safety Pool: NFPA 86 Crucible Side-Arc & IGCT Crowbar Trip
resource kataSil3SafetyPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-05-01' = {
  parent: aksCluster
  name: 'varsil3pool'
  properties: {
    count: 3
    vmSize: kataSafetyNodeVmSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    workloadRuntime: 'KataMshvVmIsolation'
    mode: 'User'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    enableAutoScaling: true
    minCount: 3
    maxCount: 9
    nodeLabels: {
      'agent-infra/role': 'nfpa86-ams2750-sil3-crucible-sidearc-crowbar-guard'
      'safety/isolation': 'kata-mshv-vm'
      'safety/interlock-budget-ms': '1'
      'safety/standards': 'NFPA86-ClassD-AMS2750-IEC61508-SIL3'
    }
    nodeTaints: [
      'safety-sil3-kata=true:NoSchedule'
    ]
  }
}

// ----------------------------------------------------------------------------
// Outputs
// ----------------------------------------------------------------------------
output aksClusterName string = aksCluster.name
output aksClusterOidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
output pinnMpcPoolName string = pinnMpcGpuPool.name
output kataSil3SafetyPoolName string = kataSil3SafetyPool.name
output meltShopMqttEndpoint string = meltShopMqttBroker.properties.topicSpacesConfiguration.hostname
output immutableMeltArchiveBlobEndpoint string = meltArchiveStorage.properties.primaryEndpoints.blob
output keyVaultUri string = keyVault.properties.vaultUri
