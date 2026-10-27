// blueprints/wco6-btbmw-teb-gaa-fluorine-free-wcn-ald-pinn-mpc-sil3.bicep
// Blueprint #249 (Cycle #248): Autonomous Electronic-Grade Tungsten Hexacarbonyl (6N W(CO)6 >=99.9999%, Sublimation 170.0C, v.p. 0.10Torr @ 65C, Ultra-Low Mo(CO)6 <=0.20ppmw, Cr(CO)6 <=0.05ppmw, Fe(CO)5 <=0.02ppmw, Fluorine-Free 0.0pptw) & Bis(tert-butylimido)bis(dimethylamino)tungsten(VI) (6N BTBMW (tBuN)2W(NMe2)2 >=99.9999%, b.p. 90C @ 0.5Torr, Cl <=0.05ppmw) + Triethylborane / Trimethylboron (6N TEB B(C2H5)3 & 5N5 TMB >=99.9995%) 2nm GAA / A14 Fluorine-Free Tungsten Carbonitride / Tungsten Nitride (WCN / WNx) Work-Function Liner & Low-Resistivity Fluorine-Free W Nucleation ALD/CVD (Eliminating WF6-Induced HF Attack on 0.7nm HfO2/La2O3 High-k Dielectric & TiSix Source/Drain Contact Fluorine Poisoning) Multi-Zone Vacuum Fractional Sublimation, Solid-Source Carrier Saturation & NH3/B2H6/TEB Thermal/Plasma ALD PINN-MPC, Online 10kHz QCL-TDLAS/FTIR (1998cm-1 W-C=O T1u / 2004cm-1 Mo(CO)6 / 948cm-1 W=N-tBu / 2143cm-1 Free CO) + HR-ICP-MS + 4PP/XPS Metrology & SEMI S2/SEMI C3/NFPA 704/OSHA PEL/IEC 61511 SIL-3 Pyrophoric TEB/TMB Air-Ingress Auto-Ignition, Toxic CO (IDLH 1200ppmv) Decomposition & W(CO)6 Cold-Spot Desublimation Plugging Hard Interlock

targetScope = 'resourceGroup'

@description('Azure region for the Electronic-Grade 6N W(CO)6 & 6N BTBMW + 6N TEB 2nm GAA / A14 Fluorine-Free WCN / WNx Work-Function Liner & W Nucleation ALD digital twin')
param location string = resourceGroup().location

@description('Environment name (prod / staging)')
@allowed([
  'prod'
  'staging'
])
param environment string = 'prod'

@description('Number of parallel 6N W(CO)6 fractional vacuum sublimation, 6N BTBMW vacuum rectification, and 2nm GAA / A14 fluorine-free WCN/W ALD trains (2 to 32)')
@minValue(2)
@maxValue(32)
param wco6BtbmwAldTrains int = 8

var aksClusterName = 'aks-wco6-btbmw-ald-mpc-${environment}'
var iotHubName = 'iothub-wco6-tdlas-sil3-${environment}'
var adxClusterName = 'adxwco6ald${environment}'
var pinnNodesCount = max(2, (wco6BtbmwAldTrains + 1) / 2)

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  properties: {
    dnsPrefix: aksClusterName
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnwco6'
        count: pinnNodesCount
        vmSize: 'Standard_NC40ads_H100_v5'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload/type': 'wco6-btbmw-teb-gaa-fluorine-free-wcn-ald-pinn-mpc'
          'safety/standard': 'semi-s2-semi-c3-nfpa704-osha-iec61511-sil3'
        }
      }
    ]
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 16
      }
    }
  }
}

resource adxCluster 'Microsoft.Kusto/clusters@2023-08-15' = {
  name: adxClusterName
  location: location
  sku: {
    name: 'Standard_E8d_v5'
    tier: 'Standard'
    capacity: 2
  }
}

output aksClusterId string = aksCluster.id
output pinnGpuNodeCount int = pinnNodesCount
output sil3InterlockStandard string = 'SEMI-S2-SEMI-C3-NFPA704-OSHA-IEC61511-SIL3-0.14ms-Pyrophoric-TEB-Toxic-CO-And-WCO6-Desublimation-Lockout'
