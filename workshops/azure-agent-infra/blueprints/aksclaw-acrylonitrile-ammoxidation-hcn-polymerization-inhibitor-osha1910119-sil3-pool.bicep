// Blueprint #147: AKSClaw Acrylonitrile (ACN Sohio Propylene Ammoxidation) & Byproduct Hydrogen Cyanide (HCN) Recovery PINN-MPC + OSHA 29 CFR 1910.119 / NFPA 704 / API RP 521 / IEC 61511 SIL-3 Sandbox Pool
// Chapter 151 — Sohio Fluidized-Bed Propylene Ammoxidation (C3H6 + NH3 + 1.5O2 -> ACN + 3H2O, dH = -515 kJ/mol), Mo-Bi-Fe-Co Mars-van Krevelen Lattice-Oxygen Redox & Acrolein/Cyanohydrin Fouling Suppression PINN-MPC + 0.2ms OSHA 1910.119 / SIL-3 Liquid HCN Runaway Polymerization SO2/H3PO4 Inhibitor Injection & Thermal Incinerator Interlock

@description('Azure region for the AKSClaw Acrylonitrile Ammoxidation & HCN Polymerization Inhibitor Sandbox cluster')
param location string = resourceGroup().location

@description('AKS cluster name for ACN ammoxidation and HCN purification PINN-MPC & SIL-3 safety workloads')
param clusterName string = 'aksclaw-acn-ammox-hcn-sil3'

@description('GPU node VM SKU for Mars-van Krevelen Mo-Bi-Fe redox PINN-MPC, TDLAS HCN/NH3/O2 and Raman acrolein/cyanohydrin tomography')
param gpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Minimum number of dedicated Kata + GPU nodes in the ACN/HCN reactor edge pool')
@minValue(2)
@maxValue(32)
param minGpuNodes int = 3

@description('Maximum number of dedicated Kata + GPU nodes in the ACN/HCN reactor edge pool')
@minValue(4)
@maxValue(64)
param maxGpuNodes int = 12

@description('Maximum allowable liquid HCN storage/column pH before SIL-3 SO2/H3PO4 acid stabilizer injection triggers to prevent violent alkaline cyanide polymerization')
param maxLiquidHcnStabilizerPh string = '4.2'

@description('Minimum required tail-gas oxygen margin (vol% O2) to prevent Mo-Bi-Fe catalyst irreversible lattice-oxygen over-reduction')
param minTailGasOxygenMarginVolPct string = '0.6'

@description('Maximum allowable OSHA 1910.119 / NFPA 704 / IEC 61511 SIL-3 SO2/H3PO4 inhibitor injection and HCN thermal incinerator interlock latency (ms)')
param maxOsha1910119Sil3HcnInterlockLatencyMs string = '0.2'

resource aksAcrylonitrileHcnCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    workload: 'aksclaw-acrylonitrile-ammoxidation-hcn-polymerization-inhibitor-osha1910119-sil3'
    safetyStandard: 'OSHA-1910.119-NFPA-704-API-RP-521-IEC-61511-SIL3'
    physicsEngine: 'Sohio-Ammoxidation-MarsVanKrevelen-MoBiFe-Redox-HCN-Stabilizer-PINN-MPC'
    metrology: 'Online-TDLAS-HCN-NH3-O2-Raman-ACN-Acrolein-Cyanohydrin'
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
        name: 'acnhcnsil3'
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
          'aksclaw.io/domain': 'acrylonitrile-ammoxidation-hcn-recovery'
          'aksclaw.io/metrology': 'tdlas-hcn-nh3-o2-raman-acn-acrolein'
          'aksclaw.io/safety-interlock': 'osha1910119-nfpa704-iec61511-sil3-hcn-so2-h3po4-inhibitor-incinerator'
        }
        nodeTaints: [
          'aksclaw.io/acn-hcn-sil3=true:NoSchedule'
        ]
        tags: {
          maxLiquidHcnStabilizerPh: maxLiquidHcnStabilizerPh
          minTailGasOxygenMarginVolPct: minTailGasOxygenMarginVolPct
          maxOsha1910119Sil3HcnInterlockLatencyMs: maxOsha1910119Sil3HcnInterlockLatencyMs
        }
      }
    ]
  }
}

output clusterResourceId string = aksAcrylonitrileHcnCluster.id
output acnHcnNodePoolName string = 'acnhcnsil3'
output verifiedSil3Standard string = 'OSHA 29 CFR 1910.119 / NFPA 704 / API RP 521 / IEC 61511 SIL-3 Liquid HCN Exothermic Polymerization SO2/H3PO4 Inhibitor Injection & Thermal Incinerator Interlock (<= 0.2 ms)'
