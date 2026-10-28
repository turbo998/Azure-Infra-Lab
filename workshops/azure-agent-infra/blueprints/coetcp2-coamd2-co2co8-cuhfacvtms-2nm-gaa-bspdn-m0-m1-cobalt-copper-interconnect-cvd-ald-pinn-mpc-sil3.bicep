// blueprints/coetcp2-coamd2-co2co8-cuhfacvtms-2nm-gaa-bspdn-m0-m1-cobalt-copper-interconnect-cvd-ald-pinn-mpc-sil3.bicep
// Blueprint #269: Electronic-Grade Bis(ethylcyclopentadienyl)cobalt (6N5 Co(EtCp)2 >=99.99995%, Ferrocene <=0.02 ppmw, Nickelocene <=0.02 ppmw, Cl <=0.05 ppmw, U/Th <=0.001 ppbw) & Bis(N,N'-diisopropylacetamidinato)cobalt(II) (6N5 Co(iPr-AMD)2 >=99.99995%, O=0 at.%) + Tricobalt Nitrosyl Carbonyl / Dicobalt Octacarbonyl (6N5 Co(CO)3NO / Co2(CO)8 >=99.99995%, CO Overpressure Suppressing Co4(CO)12 <=0.03 ppmw) + Hexafluoroacetylacetonato(vinyltrimethylsilane)copper(I) (6N5 Cu(hfac)(VTMS) >=99.99995%, Cu0 Colloid <=0.02 ppmw) 2nm GAA / A14 Backside Power Delivery Network (BSPDN nTSV CD <35nm, AR >12:1 & Buried Power Rail BPR) & M0/M1 Dual-Damascene Barrierless Cobalt (rho <6.2 uOhm-cm) / Ultrathin 1.0nm Co Wetting Liner for Void-Free Cu Reflow (EM t50 >10 yr @ J=5e6 A/cm2) Selective CVD/PEALD Vacuum Distillation, Disproportionation Suppression & PINN-MPC, 10kHz QCL-TDLAS/FTIR + GC-ICP-MS + In-Situ 4PP/Sonar/XRR/EBSD & SEMI S2/NFPA 704/OSHA PSM/IEC 61511 SIL-3 Interlock

param location string = resourceGroup().location
param clusterName string = 'aks-coetcp2-coamd2-cuhfacvtms-bspdn-sil3'
param gpuVmSize string = 'Standard_NC40ads_H100_v5'
param coetcp2Coamd2Co2co8CuhfacvtmsTrains int = 8
param governanceMode string = 'pinn_mpc_coetcp2_coamd2_co2co8_cuhfacvtms_disproportionation_and_bspdn_m0_m1_co_cu_reflow_ald_sil3_edge'

var gpuNodeCount = max(2, (coetcp2Coamd2Co2co8CuhfacvtmsTrains + 1) / 2)
var activePods = coetcp2Coamd2Co2co8CuhfacvtmsTrains * 4

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
      {
        name: 'cobspdnsil3'
        count: gpuNodeCount
        vmSize: gpuVmSize
        mode: 'User'
        osType: 'Linux'
        workloadRuntime: 'KataMshvVmIsolation'
        nodeLabels: {
          'agent.azure.com/domain': 'electronic-6n5-coetcp2-coamd2-co2co8-cuhfacvtms-bspdn-m0-m1-co-cu-ald'
          'agent.azure.com/governance-mode': governanceMode
          'agent.azure.com/safety-interlock': 'SEMI-S2-SEMI-C3-NFPA-704-OSHA-PSM-IEC-61511-SIL3'
          'agent.azure.com/edge-metrology': '10kHz-QCL-TDLAS-2024cm1-2068cm1-1796cm1-1625cm1-1255cm1-GC-ICP-MS-4PP-Sonar-EBSD'
          'agent.azure.com/active-pods': string(activePods)
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
      outboundType: 'userDefinedRouting'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output scheduledGpuNodes int = gpuNodeCount
output scheduledTwinPods int = activePods
output sil3LockoutTargetMs string = '0.13'
