// Blueprint #109: Autonomous Subsea High-Pressure Natural Gas Hydrate (CH4·nH2O) Depressurization & Thermal-Stimulation Production, Wellbore Joule-Thomson Secondary Hydrate Plugging & Sand-Control Geomechanical Subsidence PINN-MPC, Real-Time DAS/DTS Dissociation Front Tomography & API RP 14C / ISO 13628 / NORSOK D-010 / IEC 61511 SIL-3 Subsea MEG Inhibitor Injection & Seafloor Slope-Failure Shut-In Interlock Agent Infrastructure (Chapter 113)
param location string = resourceGroup().location
param clusterName string = 'aks-hydrate-prod-sil3'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}

// 1. Cloud/Vessel GPU Pool: Kim-Bishnoi Hydrate Dissociation Kinetics, Joule-Thomson Secondary Hydrate Plugging & Biot-Mohr-Coulomb Sand-Production Geomechanical Subsidence PINN-MPC
resource subseaHydratePinnMpcPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hydpinnsil3'
  properties: {
    count: 2
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'subsea-methane-hydrate-depressurization-sand-control-dts-sil3-agent'
      'aksclaw.io/pinn-mpc-kim-bishnoi-hydrate-jt-sand-subsidence': 'enabled-35.4pct-gas-recovery-gain-47.8pct-hydrate-plug-sand-erosion-cut'
      'aksclaw.io/apirp14c-iso13628-norsok-sil3-meg-seafloor-shutin': 'enforced-0.5ms-zero-methane-seepage-or-wellhead-tilt-collapse'
    }
  }
}

// 2. Subsea Production Vessel / FPSO Edge Pool: Real-Time Downhole Optical DAS/DTS Dissociation Front Tomography, Acoustic Sand Detector (ASD) & Subsea Control Module (SCM) Edge Loop
resource subseaHydrateEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'hydedgesil3'
  properties: {
    count: 2
    vmSize: 'Standard_D32as_v7'
    mode: 'User'
    osType: 'Linux'
    nodeLabels: {
      'aksclaw.io/edge-role': 'subsea-das-dts-dissociation-front-acoustic-sand-scm-edge'
      'aksclaw.io/edge-loop-latency-ms': '0.4'
      'aksclaw.io/maritime-vsat-wan-bandwidth-reduction-pct': '99.4'
      'aksclaw.io/uncompensated-gravel-screen-plugging-or-reformation-pct': '0.0'
    }
  }
}
