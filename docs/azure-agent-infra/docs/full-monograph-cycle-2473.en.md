# Cycle #2473 Core Engineering Monograph: FOCUS Chargeback + APIM Token Budget Governance (en)

- Round/Cycle: `1068 / 2473`
- Topic: `finops-hub-adx-focus-apim-token-budget-faq-r1068`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Control objectives

For multi-BU agent platforms, enforce three outcomes:
1. Session-level cost attribution under FOCUS 1.0 semantics.  
2. Real-time gateway budget limits and downgrade on threshold breach.  
3. Minute-level detection and recovery for runaway loop cost burn.

## 2) Core formulas and thresholds

```text
ptu_unit_cost_per_1k_tokens =
  (ptu_hourly_usd * active_hours) / (ptu_tokens_capacity / 1000)

effective_unit_cost_per_1k_tokens =
  ptu_tokens_used_ratio * ptu_unit_cost_per_1k_tokens
  + spillover_ratio * paygo_unit_cost_per_1k_tokens

session_cost_usd =
  (input_tokens/1000 * input_unit_cost)
  + (output_tokens/1000 * output_unit_cost)
  + gateway_overhead_usd
```

```text
burn_rate_x = cost_5m / baseline_cost_5m
```

Recommended thresholds:
- `burn_rate_x >= 3` for 3 consecutive windows: force model downgrade.  
- `burn_rate_x >= 5`: trip circuit breaker for high-cost tool paths.

## 3) Runnable snippets (Bicep / APIM Policy / KQL)

### Bicep (gateway cost tags)

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-finops'
  location: resourceGroup().location
  tags: { costCenter: 'BU-AI', focusProfile: 'focus-1.0' }
}
```

### APIM Policy (budget gate + downgrade)

```xml
<inbound>
  <base />
  <set-variable name="tenantId" value="@(context.Request.Headers.GetValueOrDefault(\"x-tenant-id\",\"unknown\"))" />
  <rate-limit-by-key calls="180" renewal-period="60" counter-key="@(context.Variables[\"tenantId\"])" />
  <choose>
    <when condition="@(context.Request.Headers.GetValueOrDefault(\"x-budget-tier\",\"standard\") == \"restricted\")">
      <set-header name="x-model-route" exists-action="override"><value>gpt-4o-mini</value></set-header>
    </when>
  </choose>
</inbound>
```

### KQL (runaway burn-rate detector)

```kql
AgentCostLedger
| where TimeGenerated > ago(30m)
| summarize cost_5m=sum(CostUsd), tokens_5m=sum(TotalTokens) by TenantId, bin(TimeGenerated, 5m)
| join kind=leftouter (AgentCostBaseline | summarize baseline_5m=avg(CostUsd) by TenantId) on TenantId
| extend burn_rate_x = iif(baseline_5m == 0, 0.0, cost_5m / baseline_5m)
| where burn_rate_x >= 3 and tokens_5m > 100000
| order by burn_rate_x desc
```

## 4) Production triage flow

1. Detect abnormal cost windows via KQL burn-rate signals.  
2. Apply APIM downgrade route and tighter per-tenant limits.  
3. Restore gradually after burn-rate normalization, preserving immutable audit lineage.

## 5) Conclusion

Cost governance needs both **billing visibility** and **gateway enforceability**. FOCUS attribution without APIM runtime controls leaves a spend gap; APIM controls without FOCUS attribution leave chargeback ambiguity. The combined loop is the shortest production-safe path.
