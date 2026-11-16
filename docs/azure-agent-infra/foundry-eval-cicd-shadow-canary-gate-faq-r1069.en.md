# Round 1069 / Cycle 2474 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Foundry Evaluation CI/CD Gate + ACA/APIM Shadow-to-Canary progressive rollout**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2474-benchmark.json`

## 1) Scenario and objective

Production prompt/tool releases cannot rely on offline scores only; they need online SLO protection:  
- evaluation gate to block weak candidates,  
- progressive traffic shift (5%→25%→100%),  
- instant rollback on any SLO breach.

## 2) Statistical and sample-size formulas (Wilson / Binomial / pass@k)

```text
pass_at_k = passed_cases / total_cases
```

Wilson confidence interval (95%):

```text
z = 1.96
phat = x / n
center = (phat + z^2/(2n)) / (1 + z^2/n)
half = z * sqrt((phat*(1-phat) + z^2/(4n))/n) / (1 + z^2/n)
CI = [center-half, center+half]
```

Approximate minimum sample size:

```text
n_min ≈ z^2 * p*(1-p) / e^2
```

Where `e` is tolerated error; gate recommendation: Wilson lower bound of `pass@k` ≥ 0.90.

## 3) Progressive rollout policy (5%→25%→100%)

1. **Shadow**: mirrored traffic only, no user-facing impact.  
2. **Canary 5%**: monitor error rate, p95 latency, and cost drift.  
3. **Canary 25%**: expand only if healthy; rollback on breach.  
4. **100%**: full cutover after stable consecutive windows.

Rollback breach examples:
- `error_rate > 1.5%` or  
- `latency_p95_ms > baseline * 1.2` or  
- `cost_per_req > baseline * 1.3`

## 4) Runnable snippets (Bicep / GitHub Actions / APIM Policy / KQL)

### 4.1 Bicep: APIM + ACA rollout anchor

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-rollout'
  location: resourceGroup().location
  sku: { name: 'PremiumV2', capacity: 2 }
}
```

### 4.2 GitHub Actions: Foundry eval gate + staged rollout

```yaml
name: foundry-eval-gate
on: [workflow_dispatch]
jobs:
  evaluate-and-rollout:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run foundry eval gate
        run: python scripts/foundry_eval_gate.py --min-wilson-lb 0.90 --max-p95-regression 1.2
      - name: Shift traffic to 5%
        run: az apim api release create --api-id agent-api --notes "canary-5"
```

### 4.3 APIM Policy: canary routing + fallback

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

### 4.4 KQL: stage health verdict and rollback trigger

```kql
AgentRolloutMetrics
| where TimeGenerated > ago(30m)
| summarize
    err=avg(ErrorRate),
    p95=percentile(LatencyMs,95),
    cost=avg(CostPerRequestUsd)
    by RolloutStage, bin(TimeGenerated, 5m)
| where err > 0.015 or p95 > 1.2 * toscalar(AgentBaseline | summarize avg(BaselineP95Ms)) or cost > 1.3 * toscalar(AgentBaseline | summarize avg(BaselineCostPerReq))
| order by TimeGenerated desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2474-benchmark.json`):

- `unfenced_eval_canary_gate_drift_rate = 534 / 4410 = 12.1%`
- `eval_canary_gate_variance_rate = 216 / 4410 = 4.9%`
- `eval_canary_gate_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Production agent platforms with frequent prompt/tool releases.  
- APIM-governed ingress and observable telemetry plane.  
- Need statistically grounded gate + automatic rollback.

**Not for**
- Offline-only evaluation environments with no online traffic.  
- Systems without stable baseline SLO references.
