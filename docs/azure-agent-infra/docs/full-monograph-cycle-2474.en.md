# Cycle #2474 Core Engineering Monograph: Foundry Eval Gate + Shadow-to-Canary Rollout (en)

- Round/Cycle: `1069 / 2474`
- Topic: `foundry-eval-cicd-shadow-canary-gate-faq-r1069`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Control objectives

1. Candidate releases must pass statistically grounded gates before production.  
2. Rollout follows 5%→25%→100% progressive traffic shift.  
3. Any SLO breach triggers immediate automatic rollback.

## 2) Statistical and threshold formulas

```text
pass_at_k = passed / total
burn_regression = candidate_metric / baseline_metric
```

Wilson lower bound (95%):

```text
center = (phat + z^2/(2n)) / (1 + z^2/n)
half = z * sqrt((phat*(1-phat)+z^2/(4n))/n) / (1 + z^2/n)
lower_bound = center - half
```

Recommended gates:
- `lower_bound(pass@k) >= 0.90`
- `p95_latency_regression <= 1.20`
- `cost_per_req_regression <= 1.30`

## 3) Runnable snippets (Bicep / GitHub Actions / APIM Policy / KQL)

### Bicep

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-rollout'
  location: resourceGroup().location
}
```

### GitHub Actions

```yaml
name: foundry-eval-gate
on: [workflow_dispatch]
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python scripts/foundry_eval_gate.py --min-wilson-lb 0.90
```

### APIM Policy

```xml
<inbound>
  <base />
  <set-variable name="canaryPct" value="25" />
  <choose>
    <when condition="@(new System.Random().Next(0,100) < (int)context.Variables[\"canaryPct\"])">
      <set-header name="x-model-route" exists-action="override"><value>candidate</value></set-header>
    </when>
    <otherwise>
      <set-header name="x-model-route" exists-action="override"><value>stable</value></set-header>
    </otherwise>
  </choose>
</inbound>
```

### KQL

```kql
AgentRolloutMetrics
| where TimeGenerated > ago(30m)
| summarize err=avg(ErrorRate), p95=percentile(LatencyMs,95), cost=avg(CostPerRequestUsd) by RolloutStage, bin(TimeGenerated, 5m)
| where err > 0.015 or p95 > 1.2 * toscalar(AgentBaseline | summarize avg(BaselineP95Ms)) or cost > 1.3 * toscalar(AgentBaseline | summarize avg(BaselineCostPerReq))
```

## 4) Production rollback flow

1. Shadow observes only, no user-impacting cutover.  
2. Canary 5% and 25% each require consecutive healthy windows.  
3. Breach immediately routes all traffic back to stable and freezes candidate promotion.

## 5) Conclusion

Eval gates and progressive rollout are a single control system. Offline evaluation without online rollback control still introduces production quality and cost instability.
