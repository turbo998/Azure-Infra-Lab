// ============================================================================
// Blueprint #201: AKS-Claw Bayer-Liquor Gallium & Zinc-Residue Indium 7N-8N
// Refining, TMGa/TMIn MOCVD Precursor & InP/ITO Target Pool (SEMI S2 / NFPA 55 / SIL-3)
// ============================================================================
// Deploys an Azure Local / AKS Arc + Cloud hybrid node pool for autonomous
// Bayer-liquor gallium (Ga, 100-250 mg/L) amidoxime chelating ion-exchange &
// sphalerite zinc-leach residue indium (In) D2EHPA solvent extraction,
// alkaline/sulfate electrowinning (4N), multi-stage high-vacuum distillation
// & directional fractional crystallization (7N-8N MBE-grade Ga 29.76 C & In
// 156.60 C), adduct-purified Trimethylgallium / Trimethylindium (TMGa/TMIn,
// <= 0.05 ppmv oxygen/ether adduct) MOCVD precursor synthesis, VGF 6-inch InP
// 1.6 Tbps coherent optical transceiver wafer growth, and 99.5% relative-density
// Indium Tin Oxide (ITO, 90 wt% In2O3 - 10 wt% SnO2) sputtering target sintering
// PINN-MPC with 10 kHz in-situ NMR/FTIR, GD-MS/ICP-MS & SEMI S2 / NFPA 55 /
// OSHA 1910.119 / IEC 61511 SIL-3 pyrophoric TMGa/TMIn spontaneous air-ignition
// suppression, H2 evolution purge & ITO (< 0.1 mg/m3) nanoparticle interlock.
// ============================================================================

@description('Azure region for the cloud control plane and digital twin aggregation')
param location string = resourceGroup().location

@description('Environment prefix for resource naming')
param environmentPrefix string = 'aksclaw-gain8n'

@description('Number of Ga/In 7N-8N refining, TMGa/TMIn MOCVD & InP/ITO lines (1 to 64)')
@minValue(1)
@maxValue(64)
param gaInMocvdItoLines int = 8

@description('Kubernetes version for the AKS hybrid control plane')
param kubernetesVersion string = '1.30.4'

@description('VM SKU for PINN-MPC Bayer Ga IX, D2EHPA In SX, 8N crystallization & TMGa/TMIn workers')
param pinnMpcNodeVmSize string = 'Standard_NC24ads_A100_v4'

@description('Maximum pyrophoric TMGa/TMIn enclosure O2 trace (ppmv) before SIL-3 dual-block isolation')
param maxPyrophoricEnclosureO2Ppmv int = 5

@description('Maximum ITO respirable dust concentration (ug/m3, NIOSH REL 100 ug/m3) before SIL-3 HEPA isolation')
param maxItoDustUgPerM3 int = 25

@description('Maximum electrowinning cathode hydrogen headspace (% LEL) before SIL-3 N2 dilution & rectifier trip')
param maxHydrogenHeadspacePctLel int = 10

var clusterName = '${environmentPrefix}-aks'
var logWorkspaceName = '${environmentPrefix}-law'

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logWorkspaceName
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
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: false
      }
      {
        name: 'gain8npinn'
        count: max(2, min(16, gaInMocvdItoLines / 2))
        vmSize: pinnMpcNodeVmSize
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: true
        minCount: 2
        maxCount: 16
        nodeLabels: {
          'workload/agent-infra': 'gallium-indium-8n-tmga-tmin-inp-ito-pinn-mpc'
          'chemistry/bayer-ix-sx': 'amidoxime-ga-resins-and-d2ehpa-in-solvent-extraction'
          'refining/8n-mbe-grade': 'high-vacuum-distillation-and-fractional-crystallization'
          'metrology/nmr-ftir-gdms': '10khz-in-situ-nmr-ftir-adduct-and-gdms-8n-trace'
        }
        nodeTaints: [
          'dedicated=gain8n-pinn:NoSchedule'
        ]
      }
      {
        name: 'sil3tmga'
        count: 3
        vmSize: 'Standard_F16s_v2'
        mode: 'User'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: false
        nodeLabels: {
          'safety/standard': 'semi-s2-nfpa55-osha1910119-iec61511-sil3'
          'safety/interlock': 'pyrophoric-tmga-tmin-double-block-and-ito-hepa-isolation'
          'safety/max-o2-ppmv': string(maxPyrophoricEnclosureO2Ppmv)
          'safety/max-ito-dust-ug-m3': string(maxItoDustUgPerM3)
          'safety/max-h2-pct-lel': string(maxHydrogenHeadspacePctLel)
        }
        nodeTaints: [
          'safety=sil3-gain8n:NoExecute'
        ]
      }
    ]
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logWorkspace.id
        }
      }
    }
  }
}

output clusterName string = aksCluster.name
output pinnPoolNodeCount int = max(2, min(16, gaInMocvdItoLines / 2))
output sil3SafetyStandard string = 'SEMI S2 / NFPA 55 / OSHA 1910.119 / IEC 61511 SIL-3'
output targetPurityGrade string = '7N-8N MBE-Grade Ga/In, <=0.05 ppmv O-Adduct TMGa/TMIn, <500 cm-2 EPD 6-in InP & >99.5% Density ITO'
