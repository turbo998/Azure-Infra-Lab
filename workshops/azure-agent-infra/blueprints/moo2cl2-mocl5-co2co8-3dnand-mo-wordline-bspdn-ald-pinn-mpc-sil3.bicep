// ============================================================================
// Blueprint #245 (245-Blueprint Milestone!): Autonomous Electronic-Grade
// Molybdenum Dichloride Dioxide (6N MoO2Cl2 >=99.9999%, Sublimation 156C,
// Ultra-Low W <=0.5ppmw, Fe/Cr/Ni <=5.0ppbw) & Molybdenum Pentachloride
// (6N MoCl5 >=99.9999%, m.p. 194C, b.p. 268C, MoCl4/MoCl3 <=0.1ppmw) +
// Dicobalt Octacarbonyl / Cyclopentadienylcobalt Dicarbonyl (6N Co2(CO)8 /
// CpCo(CO)2 >=99.9999%, Ni(CO)4 <=0.05ppmw) 1000-Layer 3D NAND Barrierless
// Molybdenum Wordline (Mo WL rho ~5.3 uOhm-cm, Mean Free Path lambda_Mo = 11.2nm,
// Fluorine-Free Al2O3 Blocking Oxide Preservation, >=38% RC Delay Reduction) &
// A14 Backside Power Delivery Network (BSPDN Buried Power Rail BPR & Selective
// Co Electromigration Cap) Fractional Vacuum Sublimation, Solid-Source Ampoule
// Vapor Delivery, H2 Thermal ALD (AR 65:1 Lateral Recess Step Coverage >=99.6%)
// PINN-MPC, Online 10kHz QCL-TDLAS (968cm-1 Mo=O / 392cm-1 Mo-Cl / 2022cm-1
// Co-C=O / 2586cm-1 HCl) + HR-ICP-MS + 4-Point Probe/TEM Metrology & SEMI S2 /
// SEMI C3 / NFPA 704 / OSHA PEL / IEC 61511 SIL-3 Moisture-Triggered HCl
// Hydrolysis & Toxic Metal Carbonyl (IDLH 2.0ppmv) Scrubbing Hard Interlock
// ============================================================================

@description('Azure region for the 6N MoO2Cl2 / MoCl5 / Co2(CO)8 3D NAND Mo Wordline & A14 BSPDN ALD edge-cloud cluster')
param location string = resourceGroup().location

@description('Environment prefix for naming resources')
param environmentPrefix string = 'moo2cl2-mocl5-bspdn-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemNodeVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC MoO2Cl2/MoCl5 Sublimation & 3D NAND Mo Wordline ALD node pool VM size (AMD EPYC Turin v7)')
param pinnMpcNodeVmSize string = 'Standard_D96as_v7'

@description('Minimum number of PINN-MPC Kata isolated worker nodes')
@minValue(3)
@maxValue(64)
param minPinnNodes int = 6

@description('Maximum number of PINN-MPC Kata isolated worker nodes')
@minValue(6)
@maxValue(128)
param maxPinnNodes int = 36

@description('Minimum electronic-grade 6N MoO2Cl2 / 6N MoCl5 / 6N Co2(CO)8 purity (%)')
param minPrecursorPurityPct string = '99.9999'

@description('Maximum trace tungsten (W in MoO2Cl2/MoCl5) cross-contaminant limit (ppmw)')
param maxTungstenImpurityPpmw string = '0.50'

@description('Maximum heated solid-source ampoule temperature before MoCl5 disproportionation / Co2(CO)8 decomposition interlock (Celsius)')
param maxSolidSourceAmpouleTempC int = 148

@description('Maximum exhaust HCl hydrolysis or toxic metal carbonyl (Co2(CO)8 / Ni(CO)4) leak threshold before SIL-3 trip (ppmv)')
param maxExhaustToxicLeakPpmv string = '0.05'

var clusterName = '${environmentPrefix}-aksclaw'
var vnetName = '${environmentPrefix}-vnet'
var nsgName = '${environmentPrefix}-zero-trust-nsg'

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Deny-Azure-IMDS-169-254-169-254'
        properties: {
          priority: 100
          direction: 'Outbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '169.254.169.254/32'
          destinationPortRange: '*'
          description: 'Hard block IMDS metadata token theft from 3D NAND Mo Wordline & BSPDN ALD sandboxes'
        }
      }
      {
        name: 'Allow-Edge-QCL-TDLAS-968cm1-392cm1-2022cm1-ICPMS-SIL3-PLC'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.245.0.0/16'
          sourcePortRange: '*'
          destinationAddressPrefix: '10.245.8.0/22'
          destinationPortRange: '4840-4848'
          description: 'Allow deterministic OPC-UA PubSub TSN & EtherCAT frames from 10kHz QCL-TDLAS (968/392/2022/2586cm-1), HR-ICP-MS, 4PP/TEM and SIL-3 Solid-Source Ampoule & Carbonyl Scrubbing PLCs'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.245.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'aks-system-subnet'
        properties: {
          addressPrefix: '10.245.0.0/22'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'aks-kata-moo2cl2-mocl5-bspdn-subnet'
        properties: {
          addressPrefix: '10.245.8.0/22'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: environmentPrefix
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
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'mowlald'
        count: minPinnNodes
        minCount: minPinnNodes
        maxCount: maxPinnNodes
        enableAutoScaling: true
        vmSize: pinnMpcNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'agent.azure.com/runtime': 'kata-mshv-vm-isolation'
          'industry.azure.com/domain': 'moo2cl2-mocl5-co2co8-3dnand-mo-wordline-bspdn-ald-sil3'
          'precursor.azure.com/purity-grade': minPrecursorPurityPct
          'precursor.azure.com/max-w-impurity-ppmw': maxTungstenImpurityPpmw
          'safety.azure.com/semi-s2-nfpa704-osha-iec61511': 'sil3-solid-ampoule-hcl-hydrolysis-and-carbonyl-scrubber-interlock'
          'safety.azure.com/max-solid-ampoule-temp-c': string(maxSolidSourceAmpouleTempC)
          'safety.azure.com/max-exhaust-toxic-leak-ppmv': maxExhaustToxicLeakPpmv
        }
        nodeTaints: [
          'ZeroTrustSandboxOnly=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksCluster.id
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
output safetyStandard string = 'SEMI S2 / SEMI C3 / NFPA 704 / OSHA PEL / IEC 61511 SIL-3 (6N MoO2Cl2 & 6N MoCl5 >=${minPrecursorPurityPct}% W <=${maxTungstenImpurityPpmw}ppmw, 6N Co2(CO)8/CpCo(CO)2, Solid Ampoule <=${maxSolidSourceAmpouleTempC}C, HCl/Carbonyl Leak <=${maxExhaustToxicLeakPpmv}ppmv)'
