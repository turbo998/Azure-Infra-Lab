// ============================================================================
// Azure Container Apps (ACA) Dynamic Sessions — Hyper-V Pre-Warmed Pool Bicep
// ============================================================================
// Scenario: Short-lived, untrusted Python/shell code execution or file parsing
//           where each session runs inside a dedicated Hyper-V micro-boundary,
//           allocated from a pre-warmed pool in ~210ms and destroyed after idle.
// Source:   Agent Runtime Customer Pitch (Slides 9-10) & Azure Agent Infra Playbook
// ============================================================================

@description('Deployment region supporting ACA Dynamic Sessions')
param location string = resourceGroup().location

@description('Name of the ACA Managed Environment')
param acaEnvironmentName string = 'cae-agent-runtime-prod'

@description('Name of the Dynamic Sessions Pool')
param sessionPoolName string = 'sp-agent-code-interpreter-prod'

@description('Pool management type: Dynamic (PythonLTS built-in) or CustomContainer')
@allowed([
  'Dynamic'
  'CustomContainer'
])
param poolManagementType string = 'Dynamic'

@description('Pre-warmed ready instances kept hot for ~210ms sub-second allocation')
@minValue(5)
@maxValue(200)
param readySessionInstances int = 25

@description('Maximum concurrent Hyper-V isolated sessions in the pool')
@minValue(10)
@maxValue(5000)
param maxConcurrentSessions int = 500

@description('Idle cooldown before automatic session reclamation (seconds)')
@minValue(60)
@maxValue(3600)
param cooldownPeriodInSeconds int = 300

resource acaEnv 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: acaEnvironmentName
}

resource dynamicSessionPool 'Microsoft.App/sessionPools@2024-02-02-preview' = {
  name: sessionPoolName
  location: location
  properties: {
    environmentId: acaEnv.id
    poolManagementType: poolManagementType
    containerType: poolManagementType == 'Dynamic' ? 'PythonLTS' : 'CustomContainer'
    scaleConfiguration: {
      maxConcurrentSessions: maxConcurrentSessions
      readySessionInstances: readySessionInstances
    }
    dynamicPoolConfiguration: {
      executionType: 'Timed'
      cooldownPeriodInSeconds: cooldownPeriodInSeconds
    }
    // Hard Boundary: Disable direct outbound internet egress from untrusted code sessions
    sessionNetworkConfiguration: {
      status: 'EgressDisabled'
    }
  }
}

output sessionPoolId string = dynamicSessionPool.id
output poolManagementEndpoint string = dynamicSessionPool.properties.poolManagementEndpoint
