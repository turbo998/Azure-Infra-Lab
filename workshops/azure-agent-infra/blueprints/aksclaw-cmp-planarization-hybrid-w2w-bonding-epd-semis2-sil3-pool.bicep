// ============================================================================
// Blueprint #107: Autonomous 3D IC Chemical-Mechanical Planarization (CMP) &
// Sub-Micron Hybrid Cu-SiO2 Wafer-to-Wafer (W2W) Bonding PINN-MPC, Eddy-Current /
// Multi-Wavelength Optical Endpoint & IR Void Interferometry & SEMI S2 / S8 /
// IEC 61511 SIL-3 Wafer-Slip & Chuck Vacuum Interlock Pool (Chapter 111)
// ============================================================================
targetScope = 'resourceGroup'

@description('Azure region for the 3D IC CMP & Hybrid W2W Bonding control cluster')
param location string = resourceGroup().location

@description('Environment name (fab-prod, pilot-3dic, hil-sim)')
@allowed([
  'fab-prod'
  'pilot-3dic'
  'hil-sim'
])
param environment string = 'fab-prod'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.31.2'

@description('Maximum Cu dishing recess window (nm) for hybrid Cu-Cu direct bonding')
param maxCuDishingNm string = '3.5'

@description('Maximum W2W bonding post-anneal overlay distortion 3-sigma (nm)')
param maxOverlayDistortionNm string = '35.0'

@description('Maximum carrier head lateral friction shear ratio before SEMI S2 SIL-3 wafer-slip trip')
param maxShearFrictionRatio string = '0.85'

var clusterName = 'aks-cmp-w2w-hybrid-bonding-${environment}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${clusterName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: clusterName
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
      networkPolicy: 'cilium'
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
        vmSize: 'Standard_D8s_v5'
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
        // Multi-Zone CMP Preston-Reynolds & Eddy-Current/Optical EPD Sandbox Pool
        name: 'cmpepd'
        count: 4
        vmSize: 'Standard_F32s_v2'
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
          'agent.azure.com/workload-class': 'cmp-multi-zone-preston-reynolds-epd'
          'agent.azure.com/isolation': 'kata-mshv-vm-isolation'
          'agent.azure.com/max-cu-dishing-nm': maxCuDishingNm
          'agent.azure.com/sensor-bus': 'eddy-current-multi-wavelength-epd-ethercat'
        }
        nodeTaints: [
          'agent.azure.com/cmp-epd=true:NoSchedule'
        ]
      }
      {
        // Hybrid Cu-SiO2 W2W Bonding Wavefront & IR Interferometry GPU Pool
        name: 'w2wpinn'
        count: 2
        vmSize: 'Standard_NV36ads_A10_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        availabilityZones: [
          '1'
          '2'
        ]
        nodeLabels: {
          'agent.azure.com/workload-class': 'w2w-hybrid-bonding-wavefront-ir-pinn'
          'agent.azure.com/gpu-accelerator': 'nvidia-a10-24gb'
          'agent.azure.com/max-overlay-distortion-nm': maxOverlayDistortionNm
        }
        nodeTaints: [
          'nvidia.com/gpu=true:NoSchedule'
        ]
      }
      {
        // SEMI S2 / S8 / IEC 61511 SIL-3 Wafer-Slip, Slurry Leak & Chuck Vacuum Guard Pool
        name: 'semis2sil3'
        count: 3
        vmSize: 'Standard_D16ds_v5'
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
          'agent.azure.com/workload-class': 'semi-s2-s8-sil3-wafer-slip-vacuum-interlock'
          'agent.azure.com/safety-standard': 'SEMI-S2-S8-IEC-61511-SIL3'
          'agent.azure.com/max-shear-friction-ratio': maxShearFrictionRatio
        }
        nodeTaints: [
          'agent.azure.com/semi-s2-sil3=true:NoSchedule'
        ]
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

output clusterName string = aksCluster.name
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
