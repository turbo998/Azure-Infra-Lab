# Round 1071 / Cycle 2476 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Event Hubs + Fabric Eventstream/ADX RTI event-driven agent wake-up and alert-storm dedup**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2476-benchmark.json`

## 1) Scenario objective

Event-driven agent platforms face two recurring failures:  
1. partition backlog causing wake-up latency cascades;  
2. alert storms causing wake-storm amplification and duplicate processing cost.

Goal: build a closed loop with Event Hubs + Fabric RTI + ADX for low-latency wake-up, dedup suppression, and replayability.

## 2) Core formulas (throughput / lag / windowing)

```text
partition_lag_seconds = backlog_events / consume_rate_eps
```

```text
required_tu_or_pu =
  ceil((ingress_mbps / per_unit_ingress_mbps) ∪ (egress_mbps / per_unit_egress_mbps))
```

```text
watermark_window_ms =
  max_out_of_order_ms + clock_skew_ms + safety_margin_ms
```

```text
wake_suppression_ratio =
  deduplicated_wake_events / raw_wake_events
```

Recommended thresholds: `partition_lag_seconds p95 < 8`, `wake_suppression_ratio > 0.6`.

## 3) Policy design (wake + suppression)

1. Windowed dedup on event-key (tenant+resource+alert-type).  
2. Trigger wake only on first event in window; merge counters for duplicates.  
3. Apply backpressure on lagged partitions and degrade non-critical agents.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep: Event Hubs + ADX ingress anchor

```bicep
resource ehns 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: 'eh-agent-rti'
  location: resourceGroup().location
  sku: { name: 'Standard', tier: 'Standard', capacity: 4 }
}
```

### 4.2 YAML: wake dedup window policy

```yaml
wakeDedup:
  key: "${tenantId}:${resourceId}:${alertType}"
  windowMs: 120000
  suppressThreshold: 3
  actionOnDuplicate: "merge-and-skip-wake"
```

### 4.3 KQL: partition lag and storm suppression health

```kql
AgentWakeupPipeline
| where TimeGenerated > ago(30m)
| summarize
    lag_p95=percentile(PartitionLagSeconds,95),
    raw_wake=sum(RawWakeEvents),
    dedup_wake=sum(DedupWakeEvents)
    by TenantId, PartitionId, bin(TimeGenerated, 5m)
| extend suppression_ratio = iif(raw_wake == 0, 0.0, dedup_wake / raw_wake)
| where lag_p95 > 8 or suppression_ratio < 0.6
| order by lag_p95 desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2476-benchmark.json`):

- `unfenced_event_wakestorm_guard_drift_rate = 534 / 4410 = 12.1%`
- `event_wakestorm_guard_variance_rate = 216 / 4410 = 4.9%`
- `event_wakestorm_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- High-frequency alerts, multi-tenant, low-latency auto-wake agent platforms.  
- Systems requiring out-of-order tolerance and dedup suppression.

**Not for**
- Low-frequency offline batch systems without real-time wake requirements.  
- Streams lacking unified event keys and tenant identifiers.
