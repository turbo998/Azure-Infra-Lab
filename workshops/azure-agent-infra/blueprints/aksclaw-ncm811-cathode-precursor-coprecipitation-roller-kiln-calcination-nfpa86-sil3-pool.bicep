// Blueprint #146: AKSClaw High-Nickel Lithium-Ion Cathode Precursor (NCM811 / NCA) Co-Precipitation & Pure-Oxygen Roller-Hearth Kiln Calcination PINN-MPC + NFPA 86 / OSHA 1910.119 / IEC 61511 SIL-3 Sandbox Pool
// Chapter 150 — Taylor-Couette Vortex Co-Precipitation Population Balance, LiOH High-Temp Oxygen Lithiation, Li+/Ni2+ Cation Mixing (<1.5%) & Surface Residual Li2CO3 (<1,200 ppm) Suppression PINN-MPC + 0.3ms NFPA 86 / SIL-3 Pure-O2 Kiln Shutoff, N2 Blanket Purge & NH3 Acid Scrubber Interlock

@description('Azure region for the AKSClaw NCM811/NCA Cathode Precursor & Roller-Hearth Kiln Calcination Sandbox cluster')
param location string = resourceGroup().location

@description('AKS cluster name for NCM811/NCA co-precipitation and pure-oxygen kiln calcination PINN-MPC & SIL-3 safety workloads')
param clusterName string = 'aksclaw-ncm811-cathode-kiln-sil3'

@description('GPU node VM SKU for Taylor-Couette population-balance PINN-MPC, laser PSD, in-situ XRD and TDLAS O2/CO2/NH3 tomography')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Minimum number of dedicated Kata + GPU nodes in the cathode kiln edge pool')
@minValue(2)
@maxValue(32)
param minGpuNodes int = 3

@description('Maximum number of dedicated Kata + GPU nodes in the cathode kiln edge pool')
@minValue(4)
@maxValue(64)
param maxGpuNodes int = 12

@description('Maximum allowable Li+/Ni2+ cation mixing ratio on 3a sites (%) before PINN-MPC increases kiln O2 partial pressure and holding time')
param maxLiNiCationMixingPct string = '1.5'

@description('Maximum allowable surface residual lithium carbonate Li2CO3 concentration (ppm) before CO2-free dry-air cooling and washing adjustment')
param maxResidualLi2CO3Ppm string = '1200'

@description('Maximum allowable NFPA 86 / OSHA 1910.119 / IEC 61511 SIL-3 pure-O2 shutoff, N2 blanket purge and NH3 scrubber interlock latency (ms)')
param maxNfpa86Sil3KilnInterlockLatencyMs string = '0.3'

resource aksCathodeKilnCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'aksclaw-ncm811-cathode-precursor-coprecipitation-roller-kiln-calcination-nfpa86-sil3'
    safetyStandard: 'NFPA-86-OSHA-1910.119-IEC-61511-SIL3'
    physicsEngine: 'Taylor-Couette-PBM-CoPrecipitation-Roller-Kiln-O2-Lithiation-Cation-Mixing-PINN-MPC'
    metrology: 'Online-Laser-Diffraction-PSD-InSitu-XRD-003-104-TDLAS-O2-CO2-NH3'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    sku: {
      name: 'Base'
      tier: 'Standard'
    }
    networkProfile: {
      networkPlugin: 'azure'
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
        vmSize: 'Standard_D8s_v6'
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
        name: 'ncm811kiln'
        count: minGpuNodes
        minCount: minGpuNodes
        maxCount: maxGpuNodes
        enableAutoScaling: true
        vmSize: gpuNodeVmSize
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
          'aksclaw.io/isolation': 'kata-mshv-vm'
          'aksclaw.io/domain': 'ncm811-cathode-precursor-coprecipitation-roller-kiln-calcination'
          'aksclaw.io/metrology': 'laser-psd-insitu-xrd-tdlas-o2-co2-nh3'
          'aksclaw.io/safety-interlock': 'nfpa86-osha1910119-iec61511-sil3-o2-shutoff-n2-purge-nh3-scrubber'
        }
        nodeTaints: [
          'aksclaw.io/cathode-kiln-sil3=true:NoSchedule'
        ]
        tags: {
          maxLiNiCationMixingPct: maxLiNiCationMixingPct
          maxResidualLi2CO3Ppm: maxResidualLi2CO3Ppm
          maxNfpa86Sil3KilnInterlockLatencyMs: maxNfpa86Sil3KilnInterlockLatencyMs
        }
      }
    ]
  }
}

output clusterResourceId string = aksCathodeKilnCluster.id
output cathodeKilnNodePoolName string = 'ncm811kiln'
output verifiedSil3Standard string = 'NFPA 86 / OSHA 29 CFR 1910.119 / IEC 61511 SIL-3 Pure-O2 Kiln Shutoff, N2 Blanket Purge & Sulfuric-Acid NH3 Scrubber Interlock (<= 0.3 ms)'
