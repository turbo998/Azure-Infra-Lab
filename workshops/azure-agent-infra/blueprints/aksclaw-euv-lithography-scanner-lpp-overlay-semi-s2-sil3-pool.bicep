// Blueprint #75: AKSClaw Semiconductor EUV (13.5 nm / High-NA 0.55) Photolithography Scanner,
// 50 kHz Sn Droplet LPP Plasma / Sub-nm Overlay PINN & SEMI S2 / S22 / IEC 61508 SIL-3 UHV Hydrogen Interlock Pool (Chapter 79)
param clusterName string = 'aksclaw-euv-litho-scanner-sil3'
param location string = resourceGroup().location
param euvScanners int = 12

var gpuNodeCount = max(2, (euvScanners + 5) / 6)

resource aksEuvLithographyCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
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
        osSKU: 'AzureLinux'
      }
      {
        // 50 kHz CO2 LPP Sn Droplet Plasma Dose PINN, ILT & MagLev Wafer/Reticle Sub-nm Overlay (<1.1 nm) MPC Pool
        name: 'euvpinnpool'
        count: gpuNodeCount
        vmSize: 'Standard_ND96isr_H100_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        nodeLabels: {
          'agent.aksclaw.io/role': 'euv-lpp-plasma-maglev-overlay-pinn-mpc'
          'agent.aksclaw.io/wavelength': 'euv-13.5nm-high-na-0.55-mo-si-mirror'
          'agent.aksclaw.io/source': '50khz-sn-droplet-co2-pre-main-pulse-lpp'
        }
        nodeTaints: [
          'sku=gpu-h100-euv-litho:NoSchedule'
        ]
      }
      {
        // SEMI S2 / S22 / IEC 61508 SIL-3 UHV Hydrogen Scavenging (LEL < 25%) & MagLev Stage Interlock Pool
        name: 'semigovpool'
        count: 3
        vmSize: 'Standard_D16s_v5'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.aksclaw.io/isolation': 'aksclaw-kata-cc'
          'agent.aksclaw.io/compliance': 'semi-s2-s8-s22-iec61508-sil3-secs-gem-eda'
          'agent.aksclaw.io/interlock': 'uhv-h2-purge-lel-30kw-co2-laser-shutter-maglev'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataplane: 'cilium'
    }
  }
}

output clusterResourceId string = aksEuvLithographyCluster.id
output recommendedEdgeRuntime string = 'Azure Local Cleanroom Edge + 50 kHz L2D Droplet Tracking FPGA + SEMI S2/S22 SIL-3 UHV Hydrogen & CO2 Laser Interlock (0.7 ms)'
