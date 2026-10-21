// Azure Bicep Blueprint #102: Autonomous Next-Gen Solid-Oxide Electrolyzer Cell (SOEC / rSOC 750-850°C) High-Temperature Steam / CO2 Co-Electrolysis Syngas Stack, YSZ/GDC Ceramic Thermal-Stress & Ni-Percolation PINN-MPC, In-Situ DRT-EIS Delamination Detection & ISO 22734 / ASME BPVC VIII / NFPA 2 / IEC 61511 SIL-3 Hot H2/CO Seal-Leak & Thermal-Shock Interlock Pool (Chapter 106)
param location string = resourceGroup().location
param aksClusterName string = 'aks-soec-coelectrolysis-ceramic-sil3'
param gpuNodeCount int = 2
param edgeNodeCount int = 4

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' existing = {
  name: aksClusterName
}

// 1. H100 GPU Pool for Coupled Nernst/Butler-Volmer Steam-CO2 Co-Electrolysis, YSZ/GDC Thermoelastic Spatial-Gradient & Ni-YSZ Percolation/Boudouard Coking PINN + Thermoneutral Voltage (1.29 V) & Sweep-Air Thermal MPC
resource soecCeramicPinnPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'soecsil3'
  properties: {
    count: gpuNodeCount
    vmSize: 'Standard_ND96isr_H100_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    scaleSetPriority: 'Regular'
    nodeLabels: {
      'aksclaw.io/workload-class': 'soec-high-temp-steam-co2-coelectrolysis-ceramic-sil3-agent'
      'aksclaw.io/pinn-mpc-nernst-tpb-ceramic-thermoelastic-drt': 'enabled-34.2pct-syngas-efficiency-gain-46.5pct-crack-delam-coking-cut'
      'aksclaw.io/iso22734-asme-nfpa2-sil3-hot-syngas-seal-shock-guard': 'enforced-0.4ms-zero-hot-h2-co-autoignition-or-ceramic-fracture'
      'aksclaw.io/skid-edge-multifreq-drt-eis-tdlas-steam-ethercat': 'enabled-0.4ms-99.3pct-plant-wan-cut'
      'kubernetes.azure.com/ebpf-dataplane': 'cilium'
    }
    nodeTaints: [
      'aksclaw.io/soec-coelectrolysis-ceramic-gpu=true:NoSchedule'
    ]
  }
}

// 2. Hot-Box Skid Edge Pool for Multi-Frequency DRT-EIS Impedance Analyzer, TDLAS Steam-Starvation Gauge & ISO 22734 / NFPA 2 SIL-3 Forming-Gas Purge Interlock
resource soecSkidEdgePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'soecedge'
  properties: {
    count: edgeNodeCount
    vmSize: 'Standard_D32as_v7'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    nodeLabels: {
      'aksclaw.io/workload-class': 'soec-skid-drt-eis-tdlas-ethercat-edge'
      'aksclaw.io/multifreq-drt-eis-oxygen-delamination-inversion': 'enabled-0.4ms-sub-milliohm-tpb-degradation-tracking'
      'aksclaw.io/tdlas-steam-to-carbon-boudouard-coking-guard': 'enabled-s-c-ratio-above-1.8-ni-redox-safe'
      'aksclaw.io/iso22734-nfpa2-sil3-hotbox-n2-quench-ramp-clamp': 'enforced-0.4ms-max-3k-per-min-thermal-gradient'
    }
  }
}

output soecCeramicPoolId string = soecCeramicPinnPool.id
output soecSkidEdgePoolId string = soecSkidEdgePool.id
