// ============================================================================
// Blueprint #263: Autonomous Electronic-Grade Hexachlorodisilane (6N5 HCDS
// Si2Cl6 >=99.99995%), Bis(diethylamino)silane (6N BDEAS / SAM.24 >=99.9999%)
// & Diisopropylaminosilane (6N DIPAS >=99.9999%) 2nm GAA Low-k SiOCN Gate
// Spacer & 300+ Layer 3D NAND Charge-Trap Si3N4 ALD PINN-MPC + SEMI S2 /
// SEMI C3 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 Sandbox
// (Cycle #262 · 270-Chapter Milestone!)
// ============================================================================

@description('Azure region for the Electronic-Grade 6N5 HCDS & 6N BDEAS / 6N DIPAS 2nm GAA Low-k SiOCN Spacer & 3D NAND Si3N4 ALD digital twin')
param location string = resourceGroup().location

@description('Environment name')
param environmentName string = 'prod-hcds-bdeas-dipas-gaa-spacer-3dnand-ald-sil3'

@description('AKS node SKU for PINN-MPC vacuum rectification, halide-free aminosilane PEALD & 10 kHz QCL-TDLAS/FTIR edge inference')
param aksNodeSku string = 'Standard_NV36ads_A10_v5'

@description('Minimum Electronic-Grade Hexachlorodisilane (6N5 HCDS Si2Cl6) purity (%)')
param minHcdsPurityPct string = '99.99995'

@description('Maximum hexachlorodisiloxane (Cl3SiOSiCl3) oxygen-incorporation impurity threshold (ppmw)')
param maxHexachlorodisiloxaneImpurityPpmw string = '0.50'

@description('Minimum foreline jacket temperature to prevent solid NH4Cl desublimation plugging (degC)')
param minForelineJacketTempC int = 175

@description('Maximum SIL-3 shock-sensitive oxychlorosilane hydrolysis & HCl/aminosilane lockout latency (ms)')
param maxSil3InterlockLatencyMs string = '0.13'

var clusterName = 'aks-${environmentName}'
var workspaceName = 'law-${environmentName}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    agentPoolProfiles: [
      {
        name: 'hcdsaldpool'
        count: 3
        vmSize: aksNodeSku
        osType: 'Linux'
        mode: 'System'
        nodeLabels: {
          'agent.infra/workload': 'pinn-mpc-hcds-bdeas-dipas-gaa-lowk-siocn-spacer-3dnand-ald'
          'agent.infra/safety-loop': 'semi-s2-nfpa704-osha-psm-sil3-hcds-hydrolysis-gel-nh4cl-guard'
          'agent.infra/metrology': 'qcl-tdlas-625cm1-1092cm1-2138cm1-gc-ms-icpms-se-xrr-10khz'
        }
      }
    ]
    addonProfiles: {
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
        }
      }
    }
  }
}

output clusterResourceId string = aksCluster.id
output targetHcdsPurityPct string = minHcdsPurityPct
output targetMaxHexachlorodisiloxanePpmw string = maxHexachlorodisiloxaneImpurityPpmw
output targetMinForelineJacketTempC int = minForelineJacketTempC
output guaranteedSil3InterlockLatencyMs string = maxSil3InterlockLatencyMs
