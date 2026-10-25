// ============================================================================
// Blueprint #189: Copper-Anode Slime & Naumannite (Ag2Se-Cu2Se) Sulfating
// Roasting, 6N5 Ultra-Pure Selenium, Large-Aperture CVD ZnSe Laser Optics &
// CIGS Double-Graded Selenization PINN-MPC + SIL-3 H2Se Interlock Pool
// ============================================================================
// Domain: Chalcogenide Metallurgy, High-Power EUV CO2 Laser Optics & Thin-Film PV
// Compute: Azure Arc AKS Edge + Standard_NC40ads_H100_v5 + Kata Confidential Pods
// Safety: NFPA 86 / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3 Hardware Interlock
// ============================================================================

@description('Azure region for regional digital twin and HorizonDB control plane')
param location string = resourceGroup().location

@description('Environment prefix for Selenium 6N5, CVD ZnSe & CIGS AKSClaw pool')
param envPrefix string = 'aksclaw-se-znse-cigs-sil3'

@description('AKS Kubernetes version')
param kubernetesVersion string = '1.30.6'

@description('System node pool VM size')
param systemVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC GPU node pool VM size (NVIDIA H100 NVL for coupled Ag2Se sulfating roasting, H2Se rectification, CVD ZnSe boundary-layer transport & CIGS Ga/(In+Ga) grading)')
param pinnGpuVmSize string = 'Standard_NC40ads_H100_v5'

@description('Deterministic edge safety & 10 kHz Raman/XRF/MIR-Scatterometry/TDLAS metrology node pool VM size')
param metrologyVmSize string = 'Standard_F16s_v2'

@description('Maximum H2Se concentration in exhaust header before SIL-3 dry-bed chemisorption & thermal oxidizer trip (ppb, OSHA/ACGIH TLV-TWA = 50 ppb)')
param maxH2SeExhaustPpb int = 25

@description('Maximum CVD ZnSe retort pressure before SIL-3 H2Se/Zn vapor isolation & argon quench (mbar)')
param maxCvdZnSeRetortPressureMbar int = 85

@description('Maximum CVD ZnSe bulk 10.6 um optical absorption coefficient before boundary-layer supersaturation trim (1e-4 cm^-1)')
param maxZnSeOpticalAbsorption1e4CmInv int = 4

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${envPrefix}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
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
        logAnalyticsWorkspaceResourceId: logAnalytics.id
        securityMonitoring: {
          enabled: true
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: systemVmSize
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
        minCount: 2
        maxCount: 6
        enableAutoScaling: true
        vmSize: pinnGpuVmSize
        osType: 'Linux'
        osSKU: 'Ubuntu'
        mode: 'User'
        workloadRuntime: 'OCIContainer'
        nodeLabels: {
          'aksclaw.io/workload-tier': 'pinn-mpc-se-6n5-znse-cvd-cigs-selenization'
          'aksclaw.io/gpu-accelerator': 'nvidia-h100-nvl'
          'aksclaw.io/process-units': 'sulfating-roaster-so2-precip-h2se-rect-znse-cvd-cigs'
        }
        nodeTaints: [
          'aksclaw.io/pinn-gpu=true:NoSchedule'
        ]
      }
      {
        name: 'sil3metpool'
        count: 3
        minCount: 3
        maxCount: 6
        enableAutoScaling: true
        vmSize: metrologyVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        proximityPlacementGroupID: ppg.id
        nodeLabels: {
          'aksclaw.io/isolation': 'kata-mshv-microvm'
          'aksclaw.io/metrology-loop': '10khz-insitu-raman-xrf-mir-scatter-tdlas-h2se-seo2'
          'aksclaw.io/safety-interlock': 'nfpa86-osha1910119-semis2-iec61511-sil3'
          'aksclaw.io/max-h2se-exhaust-ppb': string(maxH2SeExhaustPpb)
          'aksclaw.io/max-cvd-retort-mbar': string(maxCvdZnSeRetortPressureMbar)
          'aksclaw.io/max-znse-abs-1e4-cminv': string(maxZnSeOpticalAbsorption1e4CmInv)
        }
        nodeTaints: [
          'aksclaw.io/kata-sil3=true:NoSchedule'
        ]
      }
    ]
  }
}

resource ppg 'Microsoft.Compute/proximityPlacementGroups@2023-09-01' = {
  name: '${envPrefix}-ppg'
  location: location
  properties: {
    proximityPlacementGroupType: 'Standard'
  }
}

output aksClusterName string = aksCluster.name
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
output safetyStandard string = 'NFPA 86 / OSHA 1910.119 / SEMI S2 / IEC 61511 SIL-3'
output targetProcess string = 'Ag2Se-Cu2Se Sulfating Roasting, SO2 Reductive Precipitation, H2Se Rectification to 6N5 Se, Large-Aperture CVD ZnSe EUV Laser Optics & CIGS Double-Graded Selenization'
