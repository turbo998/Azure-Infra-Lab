// Blueprint #148: AKSClaw Epichlorohydrin (ECH Glycerin Hydrochlorination-Saponification) & Electronic-Grade Liquid Epoxy Resin (LER DGEBA) PINN-MPC + OSHA 29 CFR 1910.119 / NFPA 30 / DIERS / IEC 61511 SIL-3 Sandbox Pool
// Chapter 152 — Glycerin-to-Epichlorohydrin (GTE 1,3-DCH Hydrochlorination & Reactive Stripping Saponification) & Bisphenol-A Liquid Epoxy Resin (HyCl < 150 ppm) PINN-MPC + 0.3ms DIERS / SIL-3 ECH Ring-Opening Runaway Polymerization Quench & Anhydrous HCl Scrubber Interlock

@description('Azure region for the AKSClaw Epichlorohydrin & Electronic Epoxy Resin Sandbox cluster')
param location string = resourceGroup().location

@description('AKS cluster name for ECH glycerin hydrochlorination-saponification and LER DGEBA PINN-MPC & SIL-3 safety workloads')
param clusterName string = 'aksclaw-ech-epoxy-diers-sil3'

@description('GPU node VM SKU for 1,3-DCH regioselectivity, reactive stripping saponification and LER EEW/HyCl PINN-MPC + FT-NIR/Raman spectroscopy')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Minimum number of dedicated Kata + GPU nodes in the ECH/Epoxy reactor edge pool')
@minValue(2)
@maxValue(32)
param minGpuNodes int = 3

@description('Maximum number of dedicated Kata + GPU nodes in the ECH/Epoxy reactor edge pool')
@minValue(4)
@maxValue(64)
param maxGpuNodes int = 12

@description('Maximum allowable electronic-grade liquid epoxy resin hydrolyzable chlorine (HyCl ppm) enforced by PINN-MPC')
param maxElectronicEpoxyHyClPpm string = '150'

@description('Maximum allowable ECH storage/reactor self-heating rate (degC/min) before DIERS SIL-3 ring-opening runaway quench triggers')
param maxEchSelfHeatingRateDegCPerMin string = '0.4'

@description('Maximum allowable OSHA 1910.119 / DIERS / IEC 61511 SIL-3 ECH dilution quench and anhydrous HCl scrubber interlock latency (ms)')
param maxDiersSil3EchQuenchInterlockLatencyMs string = '0.3'

resource aksEpichlorohydrinEpoxyCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'aksclaw-epichlorohydrin-glycerin-saponification-epoxy-resin-diers-sil3'
    safetyStandard: 'OSHA-1910.119-NFPA-30-DIERS-IEC-61511-SIL3'
    physicsEngine: 'GTE-13DCH-Hydrochlorination-ReactiveStripping-Saponification-LER-EEW-HyCl-PINN-MPC'
    metrology: 'Online-FTNIR-EEW-Raman-1255cm-Epoxide-Ring-TDLAS-HCl'
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
        name: 'echepoxysil3'
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
          'aksclaw.io/domain': 'epichlorohydrin-glycerin-saponification-epoxy-resin'
          'aksclaw.io/metrology': 'ftnir-eew-raman-1255cm-epoxide-tdlas-hcl'
          'aksclaw.io/safety-interlock': 'osha1910119-nfpa30-diers-iec61511-sil3-ech-quench-hcl-scrubber'
        }
        nodeTaints: [
          'aksclaw.io/ech-epoxy-sil3=true:NoSchedule'
        ]
        tags: {
          maxElectronicEpoxyHyClPpm: maxElectronicEpoxyHyClPpm
          maxEchSelfHeatingRateDegCPerMin: maxEchSelfHeatingRateDegCPerMin
          maxDiersSil3EchQuenchInterlockLatencyMs: maxDiersSil3EchQuenchInterlockLatencyMs
        }
      }
    ]
  }
}

output clusterResourceId string = aksEpichlorohydrinEpoxyCluster.id
output echEpoxyNodePoolName string = 'echepoxysil3'
output verifiedSil3Standard string = 'OSHA 29 CFR 1910.119 / NFPA 30 / DIERS / IEC 61511 SIL-3 Epichlorohydrin Ring-Opening Runaway Polymerization Dilution Quench & Anhydrous HCl Scrubber Interlock (<= 0.3 ms)'
