// ============================================================================
// Azure AI Agent Infrastructure Playbook — Blueprint 7
// Multi-Tenant Agentic FinOps Budget & Real-Time Token/Sandbox Anomaly Alert
// Enforces dual-attribution (Entra Agent ID `azp` + Sponsor `oid`) chargeback
// and triggers an automated APIM quota circuit-breaker webhook on cost spikes.
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for Azure Monitor scheduled query rules')
param location string = resourceGroup().location

@description('Log Analytics Workspace resource ID receiving APIM OTel GenAI & Sandbox metrics')
param logAnalyticsWorkspaceId string

@description('Action Group resource ID for FinOps PagerDuty/Teams/Webhook circuit-breaker')
param finopsActionGroupId string

@description('Monthly budget cap in USD for the Agent Fleet resource group')
param monthlyBudgetAmountUsd int = 25000

@description('Per-Agent-ID 15-minute token burn anomaly threshold (tokens / 15m)')
param perAgentTokenSpikeThreshold int = 450000

resource agentFleetMonthlyBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: 'bgt-azure-agent-infra-fleet-monthly'
  properties: {
    category: 'Cost'
    amount: monthlyBudgetAmountUsd
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2026-10-01T00:00:00Z'
    }
    notifications: {
      WarnAt80Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 80
        thresholdType: 'Actual'
        contactRoles: [
          'Owner'
          'Contributor'
        ]
      }
      ForecastAt100Percent: {
        enabled: true
        operator: 'GreaterThanOrEqualTo'
        threshold: 100
        thresholdType: 'Forecasted'
        contactRoles: [
          'Owner'
        ]
      }
    }
  }
}

resource agentTokenAndSandboxAnomalyRule 'Microsoft.Insights/scheduledQueryRules@2023-03-15-preview' = {
  name: 'sq-agent-finops-dual-attribution-spike'
  location: location
  properties: {
    displayName: 'Agentic FinOps: Per-Agent-ID & Sponsor Token/Sandbox Cost Spike Circuit Breaker'
    description: 'Detects runaway agent loops or zombie E2B/ACA sandboxes attributed via Entra Agent ID (azp) and human sponsor (oid) within a 15-minute window.'
    severity: 1
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      logAnalyticsWorkspaceId
    ]
    criteria: {
      allOf: [
        {
          query: '''
            AppRequests
            | where Name startswith "POST /v1/chat/completions" or Name startswith "POST /sandboxes"
            | extend AgentBlueprintId = tostring(CustomDimensions["entra.agent.azp"])
            | extend SponsorUserOid   = tostring(CustomDimensions["entra.sponsor.oid"])
            | extend TotalTokens      = toint(CustomMeasurements["gen_ai.usage.total_tokens"])
            | extend SandboxDurationS = todouble(CustomMeasurements["sandbox.lease.duration_sec"])
            | summarize
                Tokens15m = sum(TotalTokens),
                SandboxHours15m = round(sum(SandboxDurationS) / 3600.0, 2),
                EstimatedCostUsd15m = round(sum(TotalTokens) * 0.0000045 + (sum(SandboxDurationS) / 3600.0) * 0.0124, 2)
              by AgentBlueprintId, SponsorUserOid, bin(TimeGenerated, 15m)
            | where Tokens15m > ''' + string(perAgentTokenSpikeThreshold) + ''' or EstimatedCostUsd15m > 25.0
          '''
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    actions: {
      actionGroups: [
        finopsActionGroupId
      ]
      customProperties: {
        playBookStep: 'L4-Govern-FinOps-CircuitBreaker'
        autoAction: 'Throttle-Entra-Agent-ID-At-APIM'
      }
    }
  }
}
