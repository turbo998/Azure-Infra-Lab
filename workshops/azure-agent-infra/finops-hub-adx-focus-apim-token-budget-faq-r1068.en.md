# Round 1068 / Cycle 2473 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **FinOps Hub ADX FOCUS 1.0 multi-BU agent chargeback + APIM real-time token-budget control**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2473-benchmark.json`

## 1) Problem framing: why “cost attribution + real-time budget gates”?

In multi-tenant agent platforms, the first production failure is often invisible **token burn**, not throughput:  
- session-level and model-level attribution is missing across BUs,  
- PTU under-utilization and PAYGO spillover coexist,  
- tool loops / retry storms amplify spend within minutes.

Goal: combine FinOps Hub + ADX FOCUS cost observability with APIM token governance and graceful degradation.

## 2) Core formulas: PTU amortization + PAYGO spillover + session cost

```text
ptu_unit_cost_per_1k_tokens =
  (ptu_hourly_usd * active_hours) / (ptu_tokens_capacity / 1000)

spillover_unit_cost_per_1k_tokens = paygo_price_per_1k_tokens

effective_unit_cost_per_1k_tokens =
  (ptu_tokens_used_ratio * ptu_unit_cost_per_1k_tokens)
+ (spillover_ratio * spillover_unit_cost_per_1k_tokens)
```

```text
session_cost_usd =
  (input_tokens/1000 * effective_input_unit_cost)
+ (output_tokens/1000 * effective_output_unit_cost)
+ gateway_overhead_usd
```

```text
burn_rate_x =
  current_5m_cost_usd / baseline_5m_cost_usd
```

Recommended threshold: trigger degrade policy when `burn_rate_x >= 3` for `>= 3` consecutive windows.

## 3) Architecture split: FOCUS billing plane + APIM control plane

1. **Billing plane**: FinOps Hub exports FOCUS 1.0 charge records to ADX (BU/product/tenant/environment tags).  
2. **Control plane**: APIM AI Gateway enforces token budget, rate limits, and model downgrade routing.  
3. **Closed loop**: ADX KQL detects runaway loops and feeds policy tiers back (model downgrade, temperature clamp, tool concurrency cap).

## 4) Runnable snippets (Bicep / APIM Policy / KQL)

### 4.1 Bicep: gateway and cost-tag contract

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-finops'
  location: resourceGroup().location
  sku: { name: 'PremiumV2', capacity: 2 }
  tags: {
    costCenter: 'BU-AI'
    focusProfile: 'focus-1.0'
  }
}
```

### 4.2 APIM Policy: token budget and graceful downgrade

```xml
<policies>
  <inbound>
    <base />
    <set-variable name="tenantId" value="@(context.Request.Headers.GetValueOrDefault(\"x-tenant-id\",\"unknown\"))" />
    <rate-limit-by-key calls="180" renewal-period="60" counter-key="@(context.Variables[\"tenantId\"])" />
    <choose>
      <when condition="@(context.Request.Headers.GetValueOrDefault(\"x-budget-tier\",\"standard\") == \"restricted\")">
        <set-header name="x-model-route" exists-action="override">
          <value>gpt-4o-mini</value>
        </set-header>
      </when>
    </choose>
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
</policies>
```

### 4.3 KQL: runaway loop burn-rate detector

```kql
AgentCostLedger
| where TimeGenerated > ago(30m)
| summarize
    cost_5m = sum(CostUsd),
    tokens_5m = sum(TotalTokens)
    by TenantId, bin(TimeGenerated, 5m)
| join kind=leftouter (
    AgentCostBaseline
    | summarize baseline_5m = avg(CostUsd) by TenantId
) on TenantId
| extend burn_rate_x = iif(baseline_5m == 0, 0.0, cost_5m / baseline_5m)
| where burn_rate_x >= 3 and tokens_5m > 100000
| order by burn_rate_x desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2473-benchmark.json`):

- `unfenced_finops_token_budget_guard_drift_rate = 534 / 4410 = 12.1%`
- `finops_token_budget_guard_variance_rate = 216 / 4410 = 4.9%`
- `finops_token_budget_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Multi-BU / multi-tenant agent platforms requiring session-level model-cost attribution.  
- APIM-controlled ingress where budget and route policy can be enforced consistently.  
- Need minute-level detect → degrade → recover cost-control loops.

**Not for**
- Single-team fixed traffic with no chargeback requirement.  
- Systems without a unified gateway control point.
