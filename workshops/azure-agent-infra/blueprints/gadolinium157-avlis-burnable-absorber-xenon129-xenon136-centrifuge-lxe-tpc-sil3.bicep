// =============================================================================
// Blueprint #219: Autonomous Gadolinium-157 (157Gd2O3 >=85%, Highest Thermal-
// Neutron Capture Cross-Section of Any Stable Nuclide sigma_th = 254,000 barns,
// 5.2x Natural Gd 49,000 barns, Reducing Gd2O3 Loading by 70% in High-Burnup
// 24-Month PWR/BWR UO2-157Gd2O3 Integral Burnable Absorber Fuel Pins to Preserve
// UO2 Thermal Conductivity & Pellet Melting Margin, Plus 157Gd Neutron Capture
// Therapy Gd-NCT) & Enriched Xenon-129 / Xenon-136 (129Xe >=86% Spin-1/2
// Nuclear Magnetic Resonance Gyroscope NMRG Navigation & Hyperpolarized MRI +
// 136Xe >=90% Neutrinoless Double-Beta Decay 0vbb nEXO / KamLAND-Zen Tonne-Scale
// Cryogenic Liquid-Xenon Time-Projection Chamber LXe-TPC) — Atomic Vapor Laser
// Isotope Separation (AVLIS 2,100 K Water-Cooled Copper-Hearth Electron-Beam Gd
// Vaporization, 3-Step Narrowband Dye/Ti:Sapphire Laser Odd-Isotope Hyperfine
// Selective Photoionization & Cross-Field Plasma Ion-Extractor Collector) &
// High-Speed Noble-Gas Centrifuge Cascade (with Hot Zirconium Getter <0.1 ppb
// O2/H2O/N2 Electronegative Impurity Scrubbing for >5 ms LXe-TPC Electron Drift
// Lifetime & <1 uBq/kg 85Kr/222Rn Cryo-Chromatographic Stripping) PINN-MPC,
// Online 10 kHz High-Resolution Fabry-Perot Laser Absorption Hyperfine
// Spectroscopy, VUV 175nm LXe Purity Monitor & Prompt-Gamma Neutron Activation
// Analysis (PGNAA) Metrology & 10 CFR 50.46 / ASME NQA-1 / ANSI Z136.1 / CGA P-12 /
// IEC 61511 SIL-3 AVLIS e-Beam Crucible Water-Jacket Breach Steam-Explosion
// Cutoff, UO2-157Gd2O3 Pellet Axial/Radial Reactivity-Worth Lot Quarantine &
// Tonne-Scale Cryogenic 136LXe Overpressure Closed-Loop Emergency Recovery Interlock
// =============================================================================

@description('Azure region for the Gadolinium-157 AVLIS & Xenon-129/136 Centrifuge/LXe-TPC AKS cluster')
param location string = resourceGroup().location

@description('Environment prefix')
param environmentName string = 'prod'

@description('GPU node count for 2,100 K e-Beam Gd Vapor Plume Optical-Bloch 3-Step Photoionization, UO2-157Gd2O3 Burnable-Absorber Sintering & 129Xe/136Xe Centrifuge / LXe-TPC Electron-Drift PINN-MPC')
@minValue(2)
@maxValue(64)
param gpuNodeCount int = 4

@description('Real-time deterministic CPU node count for 0.16ms 10 CFR 50.46 / ASME NQA-1 / ANSI Z136.1 / SIL-3 e-Beam water-leak steam-explosion cutoff, UO2-157Gd2O3 reactivity quarantine & 136LXe emergency recovery interlock')
@minValue(2)
@maxValue(32)
param rtNodeCount int = 3

var clusterName = 'aks-gd157-avlis-xe129-xe136-${environmentName}'

resource aksGd157Xe129Xe136 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
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
    kubernetesVersion: '1.29'
    dnsPrefix: clusterName
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
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
          enabled: true
        }
      }
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
      }
      {
        // GPU Pool: Gd-157 AVLIS 3-Step Optical-Bloch Photoionization, UO2-157Gd2O3 Sintering & Xe-129/136 Centrifuge / LXe-TPC Drift PINN-MPC
        name: 'gd157xe218s3'
        count: gpuNodeCount
        vmSize: 'Standard_NC24ads_A100_v4'
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': 'gd157-avlis-burnable-absorber-xe129-xe136-centrifuge-lxe-tpc-pinn-mpc'
          'agent.azure.com/isotopes': '157gd-254000b-uo2-absorber-129xe-nmrg-and-136xe-0vbb-lxe-tpc'
          'agent.azure.com/metrology': '10khz-fabry-perot-hyperfine-vuv-175nm-lxe-purity-and-pgnaa'
        }
        nodeTaints: [
          'isotopeAvlisXenonGpu=true:NoSchedule'
        ]
      }
      {
        // Real-Time Pool: 0.16ms 10 CFR 50.46 / ASME NQA-1 / ANSI Z136.1 / SIL-3 e-Beam Steam-Explosion Cutoff, UO2-157Gd2O3 Quarantine & 136LXe Recovery
        name: 'gd157xe218rt'
        count: rtNodeCount
        vmSize: 'Standard_F16s_v2'
        osType: 'Linux'
        mode: 'User'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/workload': '10cfr5046-asmenqa1-ansiz136-sil3-ebeam-crucible-and-136lxe-interlock'
          'agent.azure.com/interlock-budget-ms': '0.16'
          'agent.azure.com/lxe-impurity-limit-ppb': '0.1'
        }
        nodeTaints: [
          'sil3IsotopeAvlisXenonRt=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterResourceId string = aksGd157Xe129Xe136.id
output gpuPoolName string = 'gd157xe218s3'
output rtPoolName string = 'gd157xe218rt'
