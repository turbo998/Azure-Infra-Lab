# Cycle #2466 Core Engineering Monograph: ACA Dynamic Sessions Capacity & Isolation (en)

- Round/Cycle: `1061 / 2466`
- Topic: `aca-dynamic-sessions-hyperv-warm-pool-zero-egress-sas-handoff-faq-r1061`

## 1) Core formulas

```text
ready_target = ceil(burst_qps * session_hold_sec / sessions_per_instance)
replenish_rate = max(0, ready_target - readySessionInstances) / replenish_window_sec
exhaustion_risk = max(0, incoming_sessions - readySessionInstances) / incoming_sessions
sas_ttl_sec = upload_latency_p95_sec + validation_sec + retrieval_buffer_sec
```

Thresholds:
- `exhaustion_risk <= 0.2`
- `sas_ttl_sec <= 900`

## 2) Runnable snippets

### Bicep (session pool)

```bicep
resource sess 'Microsoft.App/sessionPools@2024-08-02-preview' = {
  name: 'aca-ds-agent'
  properties: {
    scaleConfiguration: {
      readySessionInstances: 120
      maxConcurrentSessions: 2000
    }
  }
}
```

### YAML (zero-egress + SAS)

```yaml
network: { egressMode: deny-all }
artifactHandoff: { mode: user-delegation-sas, maxTtlSeconds: 900 }
```

### Policy (least-privilege SAS)

```json
{
  "if": { "field": "sas.expirySeconds", "greater": 900 },
  "then": { "effect": "deny" }
}
```

### KQL (exhaustion risk triage)

```kql
DynamicSessionPoolLogs
| where TimeGenerated > ago(30m)
| summarize ready_p95=percentile(ReadyInstances,95), incoming_p95=percentile(IncomingSessions,95) by PoolName
| extend exhaustion_risk=iif(incoming_p95==0,0.0,max_of(0.0,(incoming_p95-ready_p95)/incoming_p95))
| where exhaustion_risk > 0.2
```

## 3) Failure modes

1. Warm-pool replenishment lags burst arrivals.
2. Zero-egress misconfiguration blocks artifact transfer paths.
3. Excessive SAS TTL increases credential risk exposure.
4. Cross-tenant shared pools weaken isolation boundaries.

## 4) Rollout checklist

- Closed-loop tuning for readySessionInstances.
- Joint validation of zero-egress and private endpoints.
- Templated least-privilege user-delegation SAS.
- Tenant-ring isolated pools with audit dashboards.
