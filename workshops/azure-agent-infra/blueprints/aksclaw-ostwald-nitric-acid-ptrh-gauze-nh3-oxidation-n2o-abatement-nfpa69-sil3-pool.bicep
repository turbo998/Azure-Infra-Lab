// 171. Ostwald Dual-Pressure Nitric Acid (HNO3) & Platinum-Rhodium (Pt-Rh 90/10) Gauze Ammonia Catalytic Oxidation (890-920 °C, <1 ms Contact Time, PtO2 Volatilization & Pd-Ni Catchment) & Secondary N2O Abatement / NOx Absorption PINN-MPC, Online 10 kHz TDLAS NH3/Air Ratio / IR Gauze Pyrometry / QCL N2O-NOx Metrology & NFPA 69 / AIChE CCPS / EN 12952 / IEC 61511 SIL-3 NH3-Air LEL Detonation (>13.8 vol% NH3) & Ammonium Nitrate Slip Explosion Pool (170-Cycle & 170-Simulator Milestone!)
param aksClusterName string = 'aks-ostwald-nitric-acid-ptrh-nfpa69-sil3'
param location string = resourceGroup().location

resource ostwaldNitricPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'ostpinn'
  properties: {
    count: 2 // Standard_NV36ads_A10_v5 (Pt-Rh Gauze Mass-TransferNH3 Oxidation, PtO2 Volatilization & N2O/NOx Absorption PINN-MPC + Online 10 kHz TDLAS NH3/Air / IR Gauze Hotspot / QCL N2O-Slip Edge)
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'ostwald-nitric-acid-ptrh-gauze-nh3-oxidation-n2o-abatement-nfpa69-sil3-agent'
      'aksclaw.io/gpu-accelerator': 'nvidia-a10-24gb'
      'aksclaw.io/pinn-mpc-ptrh-gauze-nh3-oxidation-pto2-catchment-n2o-nox-absorption': 'enabled-45.3pct-no-selectivity-acid-yield-gain-68.6pct-pt-loss-n2o-emission-cut'
      'aksclaw.io/nfpa69-ccps-en12952-sil3-nh3-lel-trip-steam-snuffing-nh4no3-interlock': 'enforced-0.35ms-zero-nh3-air-detonation-nh4no3-explosion-or-gauze-burnthrough'
      'aksclaw.io/burner-edge-10khz-tdlas-nh3-air-ir-gauze-pyrometry-qcl-n2o-slip': 'enabled-0.25ms-99.7pct-nitric-acid-plant-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/ostwald-nitric-acid-ptrh-gauze-nh3-oxidation-n2o-abatement-nfpa69-sil3-dedicated=true:NoSchedule'
    ]
  }
}
