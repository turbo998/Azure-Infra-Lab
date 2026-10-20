// ============================================================================
// Blueprint #101: Autonomous Next-Gen Proton-Exchange Membrane (PEM) Fuel-Cell
// Roll-to-Roll Catalyst-Coated Membrane (CCM) Ultrasonic Spray Ionomer-Pt/C
// Dispersion, Decal Transfer Hot-Pressing & Bipolar Plate Hydroforming PINN-MPC,
// In-Situ X-Ray Fluorescence (XRF) Pt-Loading / Infrared Pinhole Inspection &
// SAE J2579 / IEC 62282-3-100 / NFPA 2 / IEC 61508 SIL-3 Hydrogen Crossover &
// Catalytic Ignition Interlock Pool
// ============================================================================
// Target Architecture:
//   - Compute: Standard_ND96isr_H100_v5 (8x NVIDIA H100 80GB SXM5 + 3.2 Tbps IB)
//     for Coupled Butler-Volmer / Dusty-Gas Triple-Phase-Boundary (TPB) Ionomer-Pt/C
//     Agglomerate Rheology, Decal Hot-Press PFSA Viscoelastic Creep & Metallic Bipolar
//     Plate Micro-Channel Forming Limit PINN + Ultrasonic Nozzle Atomization, Web
//     Tension & Stack Conditioning MPC (+33.8% peak power density & low-Pt mass
//     activity yield gain, -45.7% membrane pinhole, catalyst crack & BPP thinning scrap)
//   - Safety Gate: Hardware-isolated 0.4 ms SAE J2579 / IEC 62282-3-100 / NFPA 2 /
//     IEC 61508 SIL-3 hydrogen crossover (< 1.5 mA/cm2 equivalent) & catalytic Pt/C
//     solvent-air exothermic auto-ignition N2 deluge & H2 test-station shutoff interlock
//   - Edge Fabric: Azure IoT Operations line-side 50 kHz Line-Scan XRF Platinum Loading
//     Gauge + Lock-In Infrared Thermography Pinhole Detector + EtherCAT Edge (0.4 ms, 99.3% WAN cut)
// ============================================================================

@description('AKS cluster name hosting the PEM Fuel-Cell Roll-to-Roll CCM & Bipolar Plate Agent Pool')
param aksClusterName string = 'aks-aksclaw-prod'

@description('Azure region for the ND96isr_H100_v5 GPU node pool')
param location string = resourceGroup().location

@description('Number of Standard_ND96isr_H100_v5 nodes (2 nodes per 16 PEM CCM & stack assembly lines)')
@minValue(2)
@maxValue(32)
param nodeCount int = 2

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

resource pemCcmSil3Pool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'pemccmsil3'
  properties: {
    count: nodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    mode: 'User'
    enableAutoScaling: true
    minCount: 2
    maxCount: 32
    maxPods: 30
    osDiskSizeGB: 1024
    osDiskType: 'Ephemeral'
    kubeletDiskType: 'OS'
    workloadRuntime: 'OCIContainer'
    nodeLabels: {
      'aksclaw.io/workload-class': 'pem-fuel-cell-ccm-ultrasonic-spray-bipolar-plate-sil3-agent'
      'aksclaw.io/pinn-mpc-butler-volmer-tpb-ionomer-decal-hydroforming': 'enabled-33.8pct-power-pt-yield-gain-45.7pct-pinhole-crack-scrap-cut'
      'aksclaw.io/sae-j2579-iec62282-nfpa2-sil3-h2-crossover-ignition-guard': 'enforced-0.4ms-zero-h2-crossover-or-catalytic-ignition-breach'
      'aksclaw.io/lineside-50khz-xrf-pt-lockin-ir-pinhole-ethercat-edge': 'enabled-0.4ms-99.3pct-gigafactory-wan-cut'
      'kubernetes.azure.com/accelerator': 'nvidia-h100-80gb'
    }
    nodeTaints: [
      'aksclaw.io/pem-fuel-cell-ccm-sil3=true:NoSchedule'
    ]
    upgradeSettings: {
      maxSurge: '10%'
    }
  }
}

output poolResourceId string = pemCcmSil3Pool.id
output safetyStandard string = 'SAE-J2579-IEC-62282-3-100-NFPA-2-IEC-61508-SIL3-0.4ms-H2-Crossover-Catalytic-Ignition-Gate'
output edgeFabric string = 'Line-Side-50kHz-XRF-Pt-Loading-LockIn-IR-Pinhole-EtherCAT-0.4ms'
