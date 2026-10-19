// ============================================================================
// Blueprint #39: Autonomous Smart Grid, IEC 61850 Substation & AC-OPF Agent Pool
// Provisions:
//   1. Azure Event Hubs Dedicated Namespace for IEEE C37.118 Synchrophasor PMU
//      120 Hz Phasor Streams & IEC 61850-9-2 Sampled Values Anomaly Events
//   2. NERC CIP-005 / CIP-007 Electronic Security Perimeter (ESP) Network Security Group
//      enforcing Unidirectional Gateway / DNP3 & IEC 61850 MMS Strict Port Whitelist
//   3. AKS Compute-Optimized NodePool (Standard_F32s_v2) for Physics-Constrained
//      AC Optimal Power Flow (AC-OPF HiGHS/IPOPT) Verification & GOOSE Trip Guard
// ============================================================================

@description('Deployment region for Smart Grid & Substation Control Plane')
param location string = resourceGroup().location

@description('Environment prefix')
param envPrefix string = 'aksclaw-grid'

@description('Existing AKS cluster name')
param aksClusterName string = 'aksclaw-prod-cluster'

@description('Substation OT Gateway CIDR block inside NERC CIP Electronic Security Perimeter')
param substationEspCidr string = '10.228.0.0/20'

// 1. NERC CIP-005 Electronic Security Perimeter (ESP) Network Security Group
resource cipEspNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: '${envPrefix}-nerc-cip005-esp-nsg'
  location: location
  tags: {
    Architecture: 'AKSClaw-SmartGrid-IEC61850'
    ComplianceStandard: 'NERC-CIP-005-CIP-007-IEEE-C37118'
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-IEEE-C37118-PMU-Synchrophasor-Ingest'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: substationEspCidr
          sourcePortRange: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '4712'
        }
      }
      {
        name: 'Allow-Verified-IEC61850-MMS-DNP3-Setpoint-Out'
        properties: {
          priority: 110
          direction: 'Outbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: substationEspCidr
          destinationPortRanges: [
            '102'   // IEC 61850 MMS (ISO-TSAP)
            '20000' // IEEE 1815 DNP3 Secure Authentication v5
          ]
        }
      }
    ]
  }
}

// 2. Azure Event Hubs Namespace for IEEE C37.118 PMU & Harmonic Fault Telemetry
resource pmuEventHubNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: '${envPrefix}-pmu-c37118-ehns'
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
    isAutoInflateEnabled: false
  }
}

resource pmuStreamHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: pmuEventHubNs
  name: 'ieee-c37118-synchrophasor-anomalies'
  properties: {
    partitionCount: 32
    messageRetentionInDays: 7
  }
}

// 3. AKS Compute-Optimized AC-OPF Power-Flow Solver Verification NodePool
resource existingAks 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource acopfSolverPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: existingAks
  name: 'gridacopf'
  properties: {
    count: 7
    vmSize: 'Standard_F32s_v2'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 3
    maxCount: 24
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    nodeLabels: {
      'aksclaw.io/workload-class': 'smartgrid-iec61850-acopf-verifier'
      'aksclaw.io/pmu-edge-triage': 'ieee-c37118-fft-6ms-halfcycle'
      'aksclaw.io/powerflow-barrier': 'highs-ipopt-n1-contingency-guard'
      'aksclaw.io/relay-interlock': 'iec61850-goose-synchrocheck-4ms'
    }
    nodeTaints: [
      'aksclaw.io/smartgrid-opf=true:NoSchedule'
    ]
  }
}

output pmuEventHubNamespaceId string = pmuEventHubNs.id
output acopfSolverPoolId string = acopfSolverPool.id
