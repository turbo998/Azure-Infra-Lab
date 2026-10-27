// =============================================================================
// Blueprint #266: Electronic-Grade Tungsten Pentachloride / Hexachloride (6N5 WCl5 / WCl6) &
// PDMAT + TBTDET Fluorine-Free (F-Free) 3D NAND Wordline / 2nm GAA MOL Tungsten & Sub-1nm TaN Barrier ALD
// PINN-MPC & IEC 61511 SIL-3 Edge-Cloud Architecture
// =============================================================================
// Focus:
//   1. Chlorination-Rectification (WOCl4 -> WCl6) + Multi-Stage Zone Sublimation & Vacuum Fractional
//      Distillation for 6N5 WCl5/WCl6 (>=99.99995%, MoCl5 <=0.05 ppmw, WOCl4 <=0.2 ppmw, U/Th <=0.001 ppbw)
//      and 6N5 PDMAT (Ta[N(CH3)2]5) + 6N5 TBTDET ((t-C4H9N)Ta[N(C2H5)2]3, TaCl5 <=0.05 ppmw, Nb <=0.02 ppmw).
//   2. High-Temperature Solid-Source Sublimator (135-165C WCl5/WCl6 Carrier-Gas Mass-Flux Feedback) &
//      PDMAT/TBTDET Liquid/Solid Ampoule Delivery with PINN-MPC for F-Free W ALD (<12 uOhm.cm, 0% TiN/SiO2
//      fluorine attack, AR >60:1 3D NAND wordline & CD <8nm 2nm GAA MOL contact) and <0.8nm TaCxNy Cu barrier.
//   3. Online 10 kHz UV-Vis / QCL-TDLAS / FTIR (382 / 1028 / 942 / 1245 / 2886 cm^-1) + GC-ICP-MS +
//      In-Situ 4PP / XRR / AR-XPS / PALS Closed-Loop Metrology.
//   4. SEMI S2 / SEMI C3 / NFPA 704 / OSHA PSM / IEC 61511 SIL-3 Heated-Line WCl6 Condensation-Clog,
//      WCl6 + 3H2O -> WO3 + 6HCl Hydrolysis & Pyrophoric Organotantalum Dual-Hazard Hard Interlock.
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 WCl5/WCl6 & 6N5 PDMAT + 6N5 TBTDET F-Free W & Sub-1nm TaN ALD digital twin.')
param location string = resourceGroup().location

@description('Environment prefix for resource naming.')
param environmentPrefix string = 'wcl6-pdmat-tbtdet-ald-sil3'

@description('Minimum purity target for 6N5 WCl5/WCl6, 6N5 PDMAT, and 6N5 TBTDET (%).')
param precursorPurityTargetPct string = '99.99995'

@description('Maximum allowed volatile oxychloride WOCl4 and molybdenum chloride MoCl5 impurity (ppmw).')
param maxWocl4AndMocl5ImpurityPpmw string = '0.05'

@description('Maximum allowed 2nm GAA MOL / 3D NAND wordline F-Free W resistivity (uOhm.cm) and TaCxNy barrier thickness (nm).')
param maxFFreeWResistivityAndTanBarrierSpec string = '11.8 uOhm.cm / 0.75 nm'

@description('IEC 61511 SIL-3 heated-line WCl6 condensation / HCl hydrolysis & organotantalum lockout latency ceiling (ms).')
param sil3LockoutLatencyTargetMs string = '0.13'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${environmentPrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${environmentPrefix}-dns'
    agentPoolProfiles: [
      {
        name: 'pinnmpcpool'
        count: 3
        vmSize: 'Standard_ND96amsr_A100_v4'
        mode: 'System'
        osType: 'Linux'
        nodeLabels: {
          'workload/role': 'wcl6-pdmat-tbtdet-ffree-w-tan-pinn-mpc'
          'safety/iec61511': 'sil3-wcl6-hcl-condensation-organotantalum-interlock'
        }
      }
    ]
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${environmentPrefix}-iothub'
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

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: '${environmentPrefix}-cosmos'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Strong'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
  }
}

output blueprintId string = 'Blueprint-266-6N5-WCl5-WCl6-PDMAT-TBTDET-FFree-W-MOL-3DNAND-TaN-Barrier-ALD-PINN-MPC-SIL3'
output targetPrecursorPurityPct string = precursorPurityTargetPct
output maxWocl4AndMocl5CeilingPpmw string = maxWocl4AndMocl5ImpurityPpmw
output targetFFreeWAndTanSpec string = maxFFreeWResistivityAndTanBarrierSpec
output sil3InterlockLatencyMs string = sil3LockoutLatencyTargetMs
