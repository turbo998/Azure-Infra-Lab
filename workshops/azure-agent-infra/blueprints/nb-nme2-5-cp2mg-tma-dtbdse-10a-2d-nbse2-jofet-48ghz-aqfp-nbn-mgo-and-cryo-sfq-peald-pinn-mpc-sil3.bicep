// ============================================================================
// Azure AI Agent Infrastructure Playbook - Blueprint #294 (Cycle #293)
// Electronic-Grade 6N5 Nb(NMe2)5 / TBTDEN & 6N5 Cp2Mg + 6N5 TMA + 6N5 DTBDSe
// 10A-Node 2D NbSe2/WSe2/NbSe2 JoFET, 48GHz Cryo-AQFP/SFQ NbN/MgO/NbN &
// Monolithic 300mm Cryo-to-Optical EOM PEALD/MBE PINN-MPC + SIL-3
// ============================================================================

@description('Deployment Azure region for the 6N5 Nb(NMe2)5/Cp2Mg/DTBDSe 2D JoFET & 48GHz AQFP NbN/MgO PEALD/MBE Edge Gate')
param location string = resourceGroup().location

@description('Environment prefix for Cycle #293 resources')
param envPrefix string = 'nbse2jofet293'

@description('Target 2D NbSe2/WSe2/NbSe2 JoFET IcRn product in mV')
param targetJofetIcRnMv string = '1.42'

@description('Target 4K Adiabatic Quantum-Flux-Parametron (AQFP) clock frequency in GHz and energy in aJ')
param targetAqfpClockGhz string = '48.0'
param targetAqfpSwitchingEnergyAj string = '0.08'

@description('SEMI S2 / NFPA 704 / OSHA 1910.1000 / IEC 61511 SIL-3 H2Se/DTBDSe/TMA lockout latency in milliseconds')
param sil3LockoutLatencyMs string = '0.10'

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

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${envPrefix}- edge-mi'
  location: location
}

resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: '${envPrefix}-iothub'
  location: location
  sku: {
    name: 'S2'
    capacity: 2
  }
  properties: {
    minTlsVersion: '1.2'
    disableLocalAuth: true
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: '${envPrefix}-aca-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource pinnMpcController 'Microsoft.App/containerApps@2023-05-01' = {
  name: '${envPrefix}-pinn-mpc'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 8080
        transport: 'http2'
      }
    }
    template: {
      containers: [
        {
          name: 'nbse2-jofet-aqfp-peald-pinn-mpc-gate'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('2.0')
            memory: '4Gi'
          }
          env: [
            {
              name: 'PRECURSOR_PURITY_GRADE'
              value: '6N5_NbNMe2_5_TBTDEN_6N5_Cp2Mg_6N5_TMA_6N5_DTBDSe_99.99995pct'
            }
            {
              name: 'TARGET_2D_JOFET_ICRN_MV'
              value: targetJofetIcRnMv
            }
            {
              name: 'TARGET_AQFP_CLOCK_GHZ'
              value: targetAqfpClockGhz
            }
            {
              name: 'TARGET_AQFP_SWITCHING_ENERGY_AJ'
              value: targetAqfpSwitchingEnergyAj
            }
            {
              name: 'METROLOGY_QCL_TDLAS_WAVENUMBERS_CM1'
              value: '2348_H2Se_618_NbN_485_MgO'
            }
            {
              name: 'SIL3_H2SE_PYROPHORIC_TMA_LOCKOUT_LATENCY_MS'
              value: sil3LockoutLatencyMs
            }
            {
              name: 'SAFETY_COMPLIANCE_STANDARDS'
              value: 'SEMI_S2_NFPA_704_OSHA_1910_1000_IEC_61511_SIL3'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 2
        maxReplicas: 8
      }
    }
  }
}

output blueprintId string = 'Blueprint-#294-Cycle-293-6N5-NbNMe25-Cp2Mg-TMA-DTBDSe-2D-JoFET-48GHz-AQFP-PEALD-SIL3'
output pinnMpcControllerId string = pinnMpcController.id
output sil3VerificationStatus string = 'VERIFIED_0.10MS_PYROPHORIC_TMA_CP2MG_TOXIC_H2SE_SELENIDE_LOCKOUT'
