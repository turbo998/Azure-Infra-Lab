# Round 1061 / Cycle 2466 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **ACA Dynamic Sessions Hyper-V pool capacity: `readySessionInstances` replenishment vs burst exhaustion, zero-egress isolation, SAS handoff**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2466-benchmark.json`

## 1) Executive Summary

This round focuses on ACA Dynamic Sessions under bursty production load, where pool replenishment speed competes directly with burst depletion speed.  
Key result: **dynamic readySessionInstances math + burst guardrails + user-delegation SAS handoff controls** is the practical baseline.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2466-sources.json`)

## 3) Core formulas (replenishment / burst / handoff)

### Q1: Warm-pool replenishment balance

```text
ready_target = ceil(burst_qps * session_hold_sec / sessions_per_instance)
replenish_rate = max(0, ready_target - readySessionInstances) / replenish_window_sec
```

Requirement: time ratio with `readySessionInstances >= ready_target` should exceed 95%.

### Q2: Burst exhaustion threshold

```text
exhaustion_risk = max(0, incoming_sessions - readySessionInstances) / incoming_sessions
```

If `exhaustion_risk > 0.2` for 2 windows, trigger scaling/degrade mode.

### Q3: SAS secure handoff window

```text
sas_ttl_sec = upload_latency_p95_sec + validation_sec + retrieval_buffer_sec
```

Recommended `sas_ttl_sec <= 900`, least-privilege + single-purpose.

## 4) Runnable snippets (Bicep / YAML / policy / KQL)

### 4.1 Bicep (session pool)

```bicep
resource sess 'Microsoft.App/sessionPools@2024-08-02-preview' = {
  name: 'aca-ds-agent'
  location: resourceGroup().location
  properties: {
    poolManagementType: 'Dynamic'
    scaleConfiguration: {
      maxConcurrentSessions: 2000
      readySessionInstances: 120
    }
  }
}
```

### 4.2 YAML (zero-egress + SAS handoff)

```yaml
network:
  egressMode: deny-all
  allowedPrivateEndpoints:
    - blob-private-endpoint
artifactHandoff:
  mode: user-delegation-sas
  maxTtlSeconds: 900
```

### 4.3 Policy JSON (least-privilege SAS)

```json
{
  "if": {
    "anyOf": [
      { "field": "sas.permissions", "contains": "d" },
      { "field": "sas.expirySeconds", "greater": 900 }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL (replenishment and exhaustion triage)

```kql
DynamicSessionPoolLogs
| where TimeGenerated > ago(30m)
| summarize ready_p95=percentile(ReadyInstances,95),
            incoming_p95=percentile(IncomingSessions,95),
            exhaust_events=countif(Event=="PoolExhausted"),
            sas_deny=countif(Event=="SasPolicyDeny")
            by PoolName, TenantRing
| extend exhaustion_risk = iif(incoming_p95==0, 0.0, max_of(0.0, (incoming_p95-ready_p95)/incoming_p95))
| where exhaustion_risk > 0.2 or exhaust_events > 0
| order by exhaustion_risk desc, exhaust_events desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2466-benchmark.json -> percentage_contract`):

- `unfenced_aca_dynamic_sessions_warm_pool_guard_drift_rate = 534 / 4410 = 12.1%`
- `aca_dynamic_sessions_warm_pool_guard_variance_rate = 216 / 4410 = 4.9%`
- `aca_dynamic_sessions_warm_pool_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (session-pool patterns)

| Pattern | Availability | Cost | Security | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| No warm pool | Low | High | Medium | Low | Not recommended |
| Fixed warm pool | Medium | Medium | Medium | Medium | Mid-volume |
| Dynamic warm pool + zero-egress + SAS policy | **High** | **Medium-high** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `exhaustion_risk > 0.2`: raise ready target and shorten replenish window.
2. Exhaust events spike: enable burst degradation and queue backpressure.
3. SAS deny anomaly: inspect permission template and TTL drift.
4. Zero-egress false blocks: verify private endpoints and DNS routes.
5. Cross-tenant leakage risk: split pools by tenant ring and isolate key domains.
