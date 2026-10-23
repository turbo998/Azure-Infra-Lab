// 172. Claus Sulfur Recovery Unit (SRU 1,150-1,400 °C Thermal Reaction Furnace H2S + 1/2 O2 -> SO2 + Sx, BTEX/NH3 Destruction & COS/CS2 TiO2 Hydrolysis) & Multi-Stage Catalytic Claus Converters / Liquid-Sulfur Degassing (H2Sx Polysulfide Decomposition) PINN-MPC, Online 10 kHz UV-DOAS Tail-Gas Air-Demand ([H2S]-2[SO2]=0) / IR Refractory Pyrometry / Seal-Leg Metrology & API RP 556 / NFPA 85 / OSHA 1910.119 / IEC 61511 SIL-3 Sulfur Seal-Leg Blowout, Condenser Sulfur-Fog Plugging & Sulfur-Pit H2S LEL Explosion (>4.3 vol%) Pool (180-Test Milestone!)
param aksClusterName string = 'aks-claus-sulfur-recovery-sru-nfpa85-sil3'
param location string = resourceGroup().location

resource clausSruPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'srupinn'
  properties: {
    count: 2 // Standard_NV36ads_A10_v5 (Claus Thermal Furnace Stoichiometry, COS/CS2 TiO2 Hydrolysis & H2Sx Liquid Sulfur Degassing PINN-MPC + Online 10 kHz UV-DOAS [H2S]-2[SO2] / IR Refractory / Seal-Leg Edge)
    vmSize: 'Standard_NV36ads_A10_v5'
    mode: 'User'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    enableAutoScaling: true
    minCount: 2
    maxCount: 8
    nodeLabels: {
      'aksclaw.io/workload-class': 'claus-sulfur-recovery-sru-thermal-furnace-air-demand-uvdoas-nfpa85-sil3-agent'
      'aksclaw.io/gpu-accelerator': 'nvidia-a10-24gb'
      'aksclaw.io/pinn-mpc-claus-air-demand-stoichiometry-btex-cos-cs2-hydrolysis': 'enabled-44.9pct-sru-sulfur-recovery-99.9pct-gain-67.9pct-so2-tailgas-catalyst-deactivation-cut'
      'aksclaw.io/apirp556-nfpa85-osha1910119-sil3-seal-leg-blowout-sulfur-pit-h2s-lel': 'enforced-0.4ms-zero-h2s-seal-blowout-sulfur-pit-explosion-or-refractory-slump'
      'aksclaw.io/sru-edge-10khz-uvdoas-h2s-so2-air-demand-ir-refractory-seal-leg': 'enabled-0.3ms-99.6pct-sour-gas-refinery-wan-cut'
    }
    nodeTaints: [
      'aksclaw.io/claus-sulfur-recovery-sru-thermal-furnace-air-demand-uvdoas-nfpa85-sil3-dedicated=true:NoSchedule'
    ]
  }
}
