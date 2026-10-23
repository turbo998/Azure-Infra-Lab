// Blueprint #155: Autonomous Subsea ±525 kV HVDC Extruded XLPE Power Cable Vertical Continuous Vulcanization (VCV) Catenary Curing Tower, Peroxide Cross-Linking & Space-Charge PINN-MPC, Online 50 kHz THz / Ultrasonic / PEA Metrology & CIGRE TB 852 / IEC 62895 / DNV-ST-F101 / IEC 61508 SIL-3 Curing-Tube Relief, CH4 Degassing Purge & HV Impulse Crowbar Pool
targetScope = 'resourceGroup'

@description('Azure region for the subsea HVDC XLPE cable VCV tower & PEA space-charge edge-cloud control plane')
param location string = resourceGroup().location

@description('Environment tier for the CIGRE TB 852 / IEC 62895 / SIL-3 subsea HVDC cable pool')
@allowed([
  'prod-cigre852-iec62895-sil3'
  'staging-vcv-digital-twin'
])
param environment string = 'prod-cigre852-iec62895-sil3'

@description('AKS cluster name hosting the Kamal-Sourour crosslink & bipolar charge transport (BCT) PINN-MPC pods')
param aksClusterName string = 'aks-hvdc-xlpe-vcv-pea-sil3'

@description('VCV tower rating and HVDC voltage class')
param hvdcCableClass string = '525kv-2gw-180m-vcv-triple-extrusion-dc-xlpe'

@description('Maximum electric field enhancement factor (FEF) allowed under DC polarity/load transients')
param maxFieldEnhancementFactor string = '1.15'

resource vcvVnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: 'vnet-${aksClusterName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.249.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-pinn-mpc-vcv'
        properties: {
          addressPrefix: '10.249.1.0/24'
        }
      }
      {
        name: 'snet-cigre852-sil3-interlock'
        properties: {
          addressPrefix: '10.249.2.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'hvdc-subsea-xlpe-cable-vcv-curing-pea-spacecharge'
    safetyStandard: 'CIGRE-TB-852-IEC-62895-DNV-ST-F101-IEC-61508-SIL3'
    hvdcClass: hvdcCableClass
    maxFef: maxFieldEnhancementFactor
    environment: environment
  }
  properties: {
    dnsPrefix: aksClusterName
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      serviceCidr: '10.249.128.0/18'
      dnsServiceIP: '10.249.128.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        vnetSubnetID: vcvVnet.properties.subnets[0].id
      }
      {
        name: 'pinnvcvgpu'
        count: 4
        vmSize: 'Standard_NV36ads_A10_v5'
        mode: 'User'
        osType: 'Linux'
        vnetSubnetID: vcvVnet.properties.subnets[0].id
        nodeLabels: {
          'agent-infra/role': 'kamal-crosslink-bct-spacecharge-pinn-mpc'
          'agent-infra/metrology': '50khz-thz-ultrasonic-pea-tdlas'
        }
        nodeTaints: [
          'hvdc.cable.azure.com/pinn-mpc=true:NoSchedule'
        ]
      }
      {
        name: 'sil3crowbar'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        vnetSubnetID: vcvVnet.properties.subnets[1].id
        nodeLabels: {
          'agent-infra/role': 'cigre852-iec62895-sil3-n2-relief-ch4-purge-crowbar'
          'agent-infra/latency-sla': '200us-2oo3-hardware-voted'
        }
        nodeTaints: [
          'safety.cable.azure.com/sil3-interlock=true:NoSchedule'
        ]
      }
    ]
  }
}

output aksClusterResourceId string = aksCluster.id
output safetyInterlockStandard string = 'CIGRE-TB-852-IEC-62895-DNV-ST-F101-SIL3-0.2ms'
