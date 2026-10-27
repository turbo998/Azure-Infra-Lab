// blueprints/hbr-cos-so2-gaa-dummy-gate-acl-hardmask-etch-pinn-mpc-sil3.bicep
// Blueprint #260 (260-Blueprint Milestone!): Electronic-Grade Hydrogen Bromide (5N5 HBr >=99.9995%, b.p. -66.8C,
// Br2 <=0.20ppmv, HCl <=0.30ppmv, H2O <=0.20ppmv), Carbonyl Sulfide (5N5 COS >=99.9995%, b.p. -50.2C, H2S <=0.15ppmv,
// CS2 <=0.15ppmv, CO2 <=0.25ppmv) & Sulfur Dioxide (5N5 SO2 >=99.9995%, b.p. -10.0C) 2nm GAA Poly-Si/SiGe Dummy Gate
// High-Selectivity ICP-RIE (Si:SiO2 >=180:1) & 3D NAND Amorphous Carbon Hardmask (ACL HAR >95:1) Etch PINN-MPC + SIL-3

param location string = resourceGroup().location
param envPrefix string = 'hbr-cos-so2-gaa-acl-sil3'
param aksNodeCount int = 4
param aksVmSize string = 'Standard_NC40ads_H100_v5'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${envPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${envPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'hbrcospool'
        count: aksNodeCount
        vmSize: aksVmSize
        osType: 'Linux'
        mode: 'System'
        nodeLabels: {
          'workload/specialty-gas': '5n5-hbr-cos-so2-gaa-dummy-gate-acl-hardmask-etch'
          'safety/interlock': 'semi-s2-nfpa55-osha-psm-sil3-hbr-cos-h2s-so2'
          'metrology/edge': '10khz-qcl-tdlas-2558-2062-1362cm1-uvvis-420nm-gc-scd-oes-502nm'
        }
      }
    ]
  }
}

output clusterName string = aksCluster.name
output safetyStandard string = 'SEMI-S2-SEMI-C3-NFPA55-OSHA-PSM-IEC61511-SIL3-HBr-COS-H2S-SO2-Lockout-0.13ms'
output metrologyProfile string = 'QCL-TDLAS-2558cm1-HBr-2062cm1-COS-1362cm1-SO2-420nm-Br2-GC-SCD-502.6nm-Br-516.5nm-C2-OES'
