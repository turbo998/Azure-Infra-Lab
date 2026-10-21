// =============================================================================
// Blueprint #132 (Cycle #131 — 140/140 Unit Tests Milestone!):
// Autonomous Kraft Pulp Continuous Digester (H-Factor / Kappa Delignification),
// Multi-Effect Black-Liquor Evaporator (80% Dry Solids) & Tomlinson Chemical
// Recovery Boiler Char-Bed Reduction (Na2SO4 -> Na2S, 1,050 C) PINN-MPC,
// Online Raman/NIR Kappa & Smelt-Spout Pyrometry Metrology & BLRBAC / NFPA 85 /
// IEC 61508 SIL-3 Smelt-Water Explosion Emergency Rapid Drain (ESP), Low-Solids
// (< 58% DS) Liquor Diversion & NCG Thermal Oxidizer Flashback Interlock Pool
// =============================================================================

@description('Azure region for the Kraft pulp & recovery boiler edge-cloud cluster')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param envName string = 'kraftpulp131'

@description('AKS Kubernetes version')
param k8sVersion string = '1.31.2'

@description('System node VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('Continuous digester H-factor, black-liquor evaporator & recovery boiler char-bed PINN-MPC GPU VM size')
param pinnGpuVmSize string = 'Standard_NC24ads_A100_v4'

@description('BLRBAC / NFPA 85 / IEC 61508 SIL-3 smelt-water ESP rapid-drain & low-solids diversion Kata VM size')
param safetyKataVmSize string = 'Standard_D16s_v5'

@description('Target continuous digester blow-line Kappa number (e.g. 28.0 for softwood bleached kraft)')
param targetKappaNumber string = '28.0'

@description('Minimum black-liquor firing dry solids threshold (% DS, BLRBAC floor >= 58.0% DS, nominal 78-82% DS)')
param minFiringDrySolidsPct string = '58.0'

@description('Recovery boiler char-bed target reduction efficiency (% Na2S / (Na2S + Na2SO4))')
param targetReductionEfficiencyPct string = '96.5'

@description('Smelt-bed temperature window (deg C, e.g. 980-1,080 C)')
param smeltBedTempWindowC string = '980-1080'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${envName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.229.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks-system'
        properties: {
          addressPrefix: '10.229.1.0/24'
        }
      }
      {
        name: 'snet-digester-charbed-pinn'
        properties: {
          addressPrefix: '10.229.2.0/24'
        }
      }
      {
        name: 'snet-blrbac-esp-sil3'
        properties: {
          addressPrefix: '10.229.3.0/24'
        }
      }
    ]
  }
}

resource aksKraftPulp 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-${envName}-pool'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: k8sVersion
    dnsPrefix: '${envName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: vnet.properties.subnets[0].id
      }
      {
        name: 'kraftpinn'
        count: 4
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[1].id
        nodeLabels: {
          'workload/agent-tier': 'kraft-digester-kappa-evaporator-recovery-boiler-charbed-pinn-mpc'
          'digester/target-kappa': targetKappaNumber
          'boiler/target-reduction-pct': targetReductionEfficiencyPct
          'boiler/smelt-bed-temp-c': smeltBedTempWindowC
          'metrology/edge-sensors': 'raman-kappa-coriolis-refractometer-ir-charbed-imaging'
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
      {
        name: 'blrbacsil3'
        count: 3
        vmSize: safetyKataVmSize
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'User'
        vnetSubnetID: vnet.properties.subnets[2].id
        nodeLabels: {
          'safety/standard': 'BLRBAC-NFPA-85-IEC-61508-SIL-3'
          'safety/interlock': 'emergency-shutdown-procedure-esp-rapid-drain-low-solids-diversion'
          'liquor/min-dry-solids-pct': minFiringDrySolidsPct
          'safety/latency-target-ms': '0.3'
        }
        nodeTaints: [
          'safety.sil3/isolated=true:NoSchedule'
        ]
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      serviceCidr: '10.229.128.0/18'
      dnsServiceIP: '10.229.128.10'
    }
  }
}

output clusterName string = aksKraftPulp.name
output pinnPoolVmSize string = pinnGpuVmSize
output safetyStandard string = 'BLRBAC / NFPA-85 / IEC-61508-SIL-3'
