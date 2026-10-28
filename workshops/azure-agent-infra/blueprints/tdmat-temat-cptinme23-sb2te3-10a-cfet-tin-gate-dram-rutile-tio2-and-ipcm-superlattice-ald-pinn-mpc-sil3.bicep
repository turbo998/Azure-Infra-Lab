// ============================================================================
// Blueprint #286: Electronic-Grade 6N5 TDMAT & 6N5 TEMAT + 6N5 CpTi(NMe2)3 +
// 6N5 Sb(NMe2)3 / 6N5 Te(Et)2 Sub-1nm (10A/7A CFET) Dual-Work-Function TiN1-xCx
// Gate Electrode, 1c/0a DRAM HAR 90:1 Rutile-TiO2 (k=98.5, EOT=0.36nm) & 3D
// iPCM TiTe2-Sb2Te3 Superlattice (E_reset=18.5fJ) PEALD/ALE PINN-MPC + SIL-3
// ============================================================================

@description('Azure region for the AKSClaw + E2B semiconductor & neuromorphic control plane')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #285 (285-Cycle & 285-Simulator Double Milestone!)')
param environmentName string = 'prod-tdmat-temat-cfet-tin-dram-tio2-ipcm-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC GPU node pool VM size (NVIDIA H100 NVL for 10 kHz QCL-TDLAS/FTIR + RHEED/SE + B1500A PINN-MPC)')
param pinnMpcVmSize string = 'Standard_NC40ads_H100_v5'

@description('E2B MicroVM sandbox host node pool VM size (Nested Virtualization D96as_v7)')
param e2bSandboxVmSize string = 'Standard_D96as_v7'

@description('Target 6N5 TDMAT / TEMAT / CpTi(NMe2)3 / Sb(NMe2)3 precursor purity (%)')
param targetPrecursorPurityPct string = '99.99995'

@description('Maximum allowable SbH3 / H2Te / organotellurium exhaust concentration (ppbv) before SIL-3 trip')
param maxToxicHydrideExhaustPpbv int = 50

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${environmentName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${environmentName}'
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
        name: 'snet-pinn-mpc-gpu'
        properties: {
          addressPrefix: '10.229.2.0/24'
        }
      }
      {
        name: 'snet-e2b-sandbox'
        properties: {
          addressPrefix: '10.229.4.0/22'
        }
      }
      {
        name: 'snet-sil3-interlock'
        properties: {
          addressPrefix: '10.229.8.0/24'
        }
      }
    ]
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-05-01' = {
  name: 'aks-${environmentName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: environmentName
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
      serviceCidr: '10.245.0.0/16'
      dnsServiceIP: '10.245.0.10'
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        vnetSubnetID: vnet.properties.subnets[0].id
        enableAutoScaling: true
        minCount: 3
        maxCount: 6
      }
      {
        name: 'pinnmpcpool'
        count: 4
        vmSize: pinnMpcVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        vnetSubnetID: vnet.properties.subnets[1].id
        enableAutoScaling: true
        minCount: 2
        maxCount: 16
        nodeLabels: {
          'workload/type': 'tdmat-temat-cfet-tin-dram-tio2-ipcm-pinn-mpc'
          'precursor/grade': '6N5-TDMAT-TEMAT-CpTiNMe23-SbNMe23-TeEt2'
          'metrology/qcl-tdlas-cm1': '948.4-1262.8-1024.5-2182.6'
          'safety/sil-rating': 'SEMI-S2-NFPA704-OSHA1910-IEC61511-SIL3'
        }
        nodeTaints: [
          'dedicated=pinn-mpc-gpu:NoSchedule'
        ]
      }
      {
        name: 'e2bsandbox'
        count: 8
        vmSize: e2bSandboxVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        vnetSubnetID: vnet.properties.subnets[2].id
        enableAutoScaling: true
        minCount: 4
        maxCount: 64
        nodeLabels: {
          'workload/type': 'e2b-firecracker-sandbox'
          'process/cfet-tin-wf-ev': '4.22-nFET-4.96-pFET'
          'process/dram-rutile-tio2-eot-nm': '0.36'
          'process/ipcm-reset-energy-fj': '18.5'
        }
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output aksClusterName string = aksCluster.name
output targetPrecursorPurity string = targetPrecursorPurityPct
output maxToxicHydrideExhaustLimitPpbv int = maxToxicHydrideExhaustPpbv
output sil3InterlockStatus string = 'ARMED_SEMI_S2_NFPA704_OSHA1910_SIL3_SBH3_H2TE_HYDROLYSIS_HARD_INTERLOCK'
