// ============================================================================
// Blueprint #151: Autonomous 4H-SiC & GaN PVT Sublimation Boule Growth &
// Hot-Wall CVD Epitaxy Wide-Bandgap Semiconductor Wafer Pool
// (PINN-MPC 2,200-2,400 °C Axial/Radial Thermal Gradient, 4H-SiC Polytype
// Stability, Basal Plane Dislocation BPD < 0.1 cm^-2 & Micropipe Suppression +
// Online Two-Color Pyrometry / Laser Light Scattering LLS / PL Metrology +
// SEMI S2 / NFPA 86 / OSHA 29 CFR 1910.119 / IEC 61511 SIL-3 Pyrophoric Silane
// SiH4, Hydrogen H2 Explosion & Induction Coil Water-Loss Interlock)
// ============================================================================

@description('Azure region for the 4H-SiC PVT Boule & Hot-Wall CVD Epitaxy edge-cloud governance pool')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param environmentName string = 'prod-sic-gan-pvt-cvd'

@description('Kubernetes version for the AKS control plane')
param kubernetesVersion string = '1.31.2'

@description('System node pool VM size (control plane &调度)')
param systemNodeVmSize string = 'Standard_D8s_v5'

@description('PINN-MPC 2,350 °C PVT Radiative-Conductive Heat Transfer & Step-Flow CVD Epitaxy GPU pool VM size')
param pinnGpuNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Deterministic SEMI S2 / NFPA 86 / IEC 61511 SIL-3 Pyrophoric SiH4 / H2 & Induction Coil Cooling Interlock pool VM size')
param sil3SafetyNodeVmSize string = 'Standard_F16s_v2'

@description('200mm 4H-SiC PVT Seed Temperature (°C)')
param pvtSeedTempC int = 2240

@description('PVT Axial Thermal Gradient dT/dz (K/cm)')
param pvtAxialGradientKPerCm int = 18

@description('Hot-Wall CVD Epitaxy Site-Competition C/Si Molar Ratio (scaled x100, e.g. 105 = 1.05)')
param cvdCSiRatioScaled int = 105

@description('Maximum allowable Basal Plane Dislocation BPD density (scaled x100 cm^-2, e.g. 10 = 0.10 cm^-2)')
param maxBpdDensityScaled int = 10

@description('SEMI S2 / SIL-3 Pyrophoric Silane SiH4 Enclosure Leak Trip Threshold (ppm)')
param sih4LeakTripThresholdPpm int = 5

@description('SEMI S2 / SIL-3 Induction Coil Cooling-Water Flow Drop Trip Threshold (%)')
param coilWaterFlowDropTripPct int = 15

var clusterName = 'aks-${environmentName}-sil3'
var logAnalyticsName = 'law-${environmentName}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    Workload: 'Autonomous-4H-SiC-GaN-PVT-Boule-Hot-Wall-CVD-Epitaxy'
    SafetyStandard: 'SEMI-S2-NFPA-86-OSHA-1910-119-IEC-61511-SIL3'
    PhysicsEngine: 'PINN-MPC-PVT-Sublimation-Step-Flow-CVD-BPD-Suppression'
    SeedTempTargetC: string(pvtSeedTempC)
    AxialGradientTargetKPerCm: string(pvtAxialGradientKPerCm)
    CSiRatioScaled: string(cvdCSiRatioScaled)
    MaxBpdDensityScaled: string(maxBpdDensityScaled)
    SiH4LeakTripPpm: string(sih4LeakTripThresholdPpm)
    CoilWaterDropTripPct: string(coilWaterFlowDropTripPct)
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      networkDataplane: 'cilium'
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
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
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        name: 'pinnsicgpu'
        count: 4
        vmSize: pinnGpuNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'OCIContainer'
        nodeLabels: {
          'agent.aksclaw.io/role': 'pinn-mpc-sic-pvt-sublimation-cvd-epitaxy'
          'physics.aksclaw.io/metrology': 'two-color-pyrometry-lls-355nm-pl-defect'
          'physics.aksclaw.io/polytype': '4h-sic-200mm-boule-and-epilayer'
        }
        nodeTaints: [
          'sku=gpu:NoSchedule'
        ]
        availabilityZones: [
          '1'
          '2'
        ]
      }
      {
        name: 'sil3semis2'
        count: 3
        vmSize: sil3SafetyNodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        kubeletConfig: {
          cpuManagerPolicy: 'static'
          topologyManagerPolicy: 'single-numa-node'
        }
        nodeLabels: {
          'agent.aksclaw.io/role': 'semis2-nfpa86-sil3-sih4-h2-induction-interlock'
          'safety.aksclaw.io/isolation': 'kata-mshv-vm-isolation'
          'safety.aksclaw.io/interlock': 'sih4-rfo-purge-n2-flood-induction-crowbar-burnbox'
        }
        nodeTaints: [
          'safety=sil3:NoSchedule'
        ]
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}

output aksClusterName string = aksCluster.name
output aksClusterFqdn string = aksCluster.properties.fqdn
output sil3SafetyStandard string = 'SEMI S2 / NFPA 86 / OSHA 29 CFR 1910.119 / IEC 61511 SIL-3'
output targetMetrologyLoopMs string = '0.3ms Two-Color Pyrometry + 355nm UV-PL / LLS Defect Edge Closed-Loop'
output targetInterlockLatencyMs string = '0.2ms Pyrophoric SiH4 RFO Isolation, Ar/N2 Flood & Induction Coil Crowbar Interlock'
