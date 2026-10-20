// Blueprint #76: Autonomous Sustainable Aviation Fuel (SAF / e-SAF) Power-to-Liquid (PtL) RWGS & Fischer-Tropsch (FT) Catalytic Synthesis, ASF Chain-Growth PINN & ASTM D7566 / IEC 61511 SIL-3 Interlock Pool
// Models Azure Local refinery edge + AKS Kata + Standard_ND96isr_H100_v5 Anderson-Schulz-Flory (ASF alpha) & exothermic tubular FT PINN + SIL-3 thermal-runaway depressuring & N2 purge voter

param location string = resourceGroup().location
param clusterName string = 'aksclaw-saf-ptl-ft-rwgs-sil3'
param ftReactorTrains int = 8
param governanceMode string = 'rwgs_ft_asf_pinn_mpc_astm_d7566_sil3_edge'
param maxBedTempCelsius int = 255
param maxAstmd7566FreezePointCelsius int = -47

var h100NodeCount = max(2, (ftReactorTrains + 5) / 6)

resource aksSafPtlCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  tags: {
    workload: 'saf-ptl-fischer-tropsch-rwgs-astm-d7566-sil3-sandbox'
    governanceMode: governanceMode
    safetyStandard: 'ASTM-D7566-Annex-A1-API-RP-521-IEC-61511-SIL3'
    ftReactorTrains: string(ftReactorTrains)
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'syskata'
        count: 3
        vmSize: 'Standard_D16s_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        workloadRuntime: 'KataMshvVmIsolation'
        mode: 'System'
      }
      {
        name: 'ftasfpinn'
        count: h100NodeCount
        vmSize: 'Standard_ND96isr_H100_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        mode: 'User'
        nodeLabels: {
          'agent.aksclaw.io/role': 'rwgs-ft-asf-exothermic-pinn-mpc'
          'agent.aksclaw.io/isolation': 'kata-sil3-syngas-depressuring-interlock'
          'agent.aksclaw.io/max-bed-temp-c': string(maxBedTempCelsius)
          'agent.aksclaw.io/max-freeze-point-c': string(maxAstmd7566FreezePointCelsius)
        }
        nodeTaints: [
          'saf.aksclaw.io/ptl-ft-rwgs-sil3=true:NoSchedule'
        ]
      }
    ]
  }
}

output clusterId string = aksSafPtlCluster.id
output h100PoolNodes int = h100NodeCount
output safetyEnvelope string = 'ASTM-D7566-Annex-A1-IEC-61511-SIL3-FT-Thermal-Runaway-N2-Purge'
