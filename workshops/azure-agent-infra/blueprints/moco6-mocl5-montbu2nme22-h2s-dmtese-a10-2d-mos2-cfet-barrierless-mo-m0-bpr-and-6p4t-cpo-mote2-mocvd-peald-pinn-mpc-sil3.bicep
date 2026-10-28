// blueprints/moco6-mocl5-montbu2nme22-h2s-dmtese-a10-2d-mos2-cfet-barrierless-mo-m0-bpr-and-6p4t-cpo-mote2-mocvd-peald-pinn-mpc-sil3.bicep
// Blueprint #296: Electronic-Grade Ultrapure 6N5 Mo(CO)6 / MoCl5 & 6N5 Mo(NtBu)2(NMe2)2 + 6N5 H2S / DTBDS + 6N5 DMSe / DETe
// 300mm A10/A7 Sub-1nm 2D TMD Monolayer MoS2/WS2/MoTe2 CFET, Barrierless Direct-Mo M0/Wordline/BPR & 6.4T CPO Excitonic MoTe2/Si3N4 Waveguide Photodetector MOCVD/PEALD PINN-MPC + SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3

targetScope = 'resourceGroup'

@description('Azure region for the 6N5 Mo(CO)6 / MoCl5 / Mo(NtBu)2(NMe2)2 + H2S / DMSe / DETe A10 2D MoS2 CFET, Barrierless Mo M0/BPR & 6.4T CPO MoTe2 MOCVD/PEALD PINN-MPC + SIL-3 digital twin cluster')
param location string = resourceGroup().location

@description('Environment prefix for naming resources')
param envPrefix string = 'moco62dmos2cfet295'

@description('Target 6N5 Mo(CO)6 / MoCl5 / Mo(NtBu)2(NMe2)2 purity (%) and trace transition metal ceiling (ppb)')
param moPrecursorPurityTarget string = '6N5-99.99995pct-Metals-le-0.05ppb-Alpha-le-0.0001cph'

@description('Target A10 2D MoS2 monolayer subthreshold swing (mV/dec), Barrierless Mo 10nm resistivity (uOhm-cm), and 1T-prime MoTe2/Sb contact resistance (Ohm-um)')
param mos2CfetMoInterconnectTarget string = 'SS-60.8mVdec-Rc-38Ohmum-RhoMo-10.4uOhmcm'

@description('SEMI S2 / NFPA 704 / OSHA 29 CFR 1910.1000 / IEC 61511 SIL-3 toxic H2S / Mo(CO)6 / DMSe / DETe / corrosive MoCl5 emergency lockout latency target (ms)')
param sil3LockoutTargetMs string = '0.10'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${envPrefix}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
  location: location
  sku: {
    name: 'S3'
    capacity: 2
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 7
        partitionCount: 32
      }
    }
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
        name: 'systempool'
        count: 3
        vmSize: 'Standard_D8s_v5'
        mode: 'System'
        osType: 'Linux'
      }
      {
        name: 'pinnmpcpool'
        count: 4
        vmSize: 'Standard_ND96amsr_A100_v4'
        mode: 'User'
        osType: 'Linux'
        nodeLabels: {
          'workload': 'moco6-mocl5-montbu2nme22-h2s-a10-2d-mos2-cfet-mo-bpr-cpo-mote2-pinn-mpc-sil3'
          'metrology': 'qcl-crds-2003cm1-2592cm1-insitu-raman-e12g-a1g-pl-1p88ev-4pp-ellipsometry'
          'safetyStandard': 'SEMI-S2-NFPA704-OSHA-19101000-IEC61511-SIL3'
        }
      }
    ]
    omsAgent: {
      enabled: true
      logAnalyticsWorkspaceResourceID: logAnalytics.id
    }
  }
}

resource digitalTwins 'Microsoft.DigitalTwins/digitalTwinsInstances@2023-01-31' = {
  name: '${envPrefix}-adt'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {
    PrecursorPurity: moPrecursorPurityTarget
    DeviceTargets: mos2CfetMoInterconnectTarget
    SIL3LockoutLatencyMs: sil3LockoutTargetMs
    BlueprintNumber: '296'
    CycleNumber: '295'
  }
}

output aksClusterName string = aksCluster.name
output iotHubHostname string = iotHub.properties.hostName
output digitalTwinsHostName string = digitalTwins.properties.hostName
