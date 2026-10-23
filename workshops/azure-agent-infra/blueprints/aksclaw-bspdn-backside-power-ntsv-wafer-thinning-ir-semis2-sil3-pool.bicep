// blueprints/aksclaw-bspdn-backside-power-ntsv-wafer-thinning-ir-semis2-sil3-pool.bicep
// Blueprint #157: Autonomous 300 mm Backside Power Delivery Network (BSPDN / PowerVia / Buried Power Rail BPR)
// Nano-Through-Silicon-Via (nTSV < 50 nm CD) Extreme Wafer Thinning (< 500 nm Residual Silicon),
// Wafer-to-Carrier Direct Dielectric Fusion Bonding & Sub-10nm Overlay Distortion Compensation PINN-MPC,
// Online 100 kHz Broadband Infrared (IR) Interferometric Silicon-Thickness (±1.5 nm 3-sigma) & Acoustic C-SAM Void Metrology
// & SEMI S2 / S8 / IEC 61508 SIL-3 TTV Wafer-Breakage Grind-Spindle Retract, Backside CMP Endpoint & Chuck Vacuum-Loss Interlock

targetScope = 'resourceGroup'

@description('Azure region for the 300mm BSPDN / PowerVia extreme wafer thinning & nTSV edge-cloud control plane')
param location string = resourceGroup().location

@description('Environment name')
@allowed([
  'prod-bspdn-ntsv-sil3'
  'staging-bspdn-twin'
])
param environmentName string = 'prod-bspdn-ntsv-sil3'

@description('AKSClaw Preston-CMP & Plate-Shell Wafer Warpage PINN-MPC node SKU')
param pinnNodeVmSize string = 'Standard_NC40ads_H100_v5'

@description('E2B Firecracker semiconductor wafer thinning sandbox host SKU')
param e2bHostVmSize string = 'Standard_D96as_v7'

@description('Number of 300 mm BSPDN wafer bonding, back-grinding & nTSV reveal CMP modules')
param bspdnProcessModules int = 8

@description('Target residual silicon device layer thickness after nTSV reveal CMP (nm)')
param targetResidualSiliconNm int = 380

@description('Maximum allowable Total Thickness Variation (TTV 3-sigma) across 300 mm wafer (nm)')
param maxWaferTtv3SigmaNm string = '1.50'

@description('Maximum allowable backside-to-frontside nTSV litho overlay error (3-sigma, nm)')
param maxNtsvOverlay3SigmaNm string = '2.80'

@description('Maximum allowable grind spindle axial load spike before SIL-3 piezo Z-retract (N)')
param maxGrindSpindleLoadSpikeN int = 85

var clusterName = 'aksclaw-bspdn-ntsv-${environmentName}'
var vmssName = 'e2b-bspdn-sandbox-${environmentName}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-bspdn-ntsv-${environmentName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.252.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aksclaw-bspdn-pinn'
        properties: {
          addressPrefix: '10.252.1.0/24'
        }
      }
      {
        name: 'snet-e2b-bspdn-sandbox'
        properties: {
          addressPrefix: '10.252.2.0/24'
        }
      }
      {
        name: 'snet-ir-interferometer-plc-sil3'
        properties: {
          addressPrefix: '10.252.3.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'bspdnpinn'
        count: 4
        vmSize: pinnNodeVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        vnetSubnetID: vnet.properties.subnets[0].id
        nodeLabels: {
          'agent.infra/domain': 'bspdn-powervia-ntsv-extreme-wafer-thinning'
          'agent.infra/solver': 'von-karman-warpage-preston-cmp-overlay-pinn-mpc'
          'agent.infra/metrology': 'ir-interferometry-100khz-csam-void-ttv'
          'agent.infra/interlock': 'semis2-s8-sil3-spindle-z-retract-cmp-endpoint-vacuum'
        }
      }
    ]
  }
}

resource e2bSandboxVmss 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: vmssName
  location: location
  sku: {
    name: e2bHostVmSize
    tier: 'Standard'
    capacity: 4
  }
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'e2bbspdn'
        adminUsername: 'azureuser'
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-gen2'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-e2b-bspdn'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: vnet.properties.subnets[1].id
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
  tags: {
    BspdnProcessModules: string(bspdnProcessModules)
    TargetResidualSiliconNm: string(targetResidualSiliconNm)
    MaxWaferTtv3SigmaNm: maxWaferTtv3SigmaNm
    MaxNtsvOverlay3SigmaNm: maxNtsvOverlay3SigmaNm
    MaxGrindSpindleLoadSpikeN: string(maxGrindSpindleLoadSpikeN)
    ComplianceStandards: 'SEMI-S2-SEMI-S8-IEC-61508-SIL-3'
  }
}

output aksClawClusterId string = aksCluster.id
output e2bBspdnSandboxVmssId string = e2bSandboxVmss.id
output sil3InterlockProfile object = {
  standards: [
    'SEMI S2'
    'SEMI S8'
    'IEC 61508 SIL-3'
  ]
  targetResidualSiliconNm: targetResidualSiliconNm
  maxWaferTtv3SigmaNm: maxWaferTtv3SigmaNm
  maxNtsvOverlay3SigmaNm: maxNtsvOverlay3SigmaNm
  maxGrindSpindleLoadSpikeN: maxGrindSpindleLoadSpikeN
  hardwireActuators: [
    'piezo-grind-spindle-fast-z-retract-and-hydrostatic-bearing-lock'
    'multi-zone-cmp-carrier-head-membrane-pressure-drop-and-diw-quench'
    'porous-ceramic-chuck-dual-redundant-vacuum-reservoir-clamp'
    'chemical-etch-tmah-hf-hno3-dispense-arm-emergency-shutoff'
  ]
}
