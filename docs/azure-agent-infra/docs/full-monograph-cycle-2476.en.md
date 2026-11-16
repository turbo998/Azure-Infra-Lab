# Cycle #2476 Core Engineering Monograph: Event-Driven Agent Wake-up and Storm Dedup (en)

- Round/Cycle: `1071 / 2476`
- Topic: `eventhubs-fabric-rti-agent-wakeup-faq-r1071`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Objective

Compose Event Hubs + Fabric RTI + ADX into a controllable wake plane: low lag, storm resistance, and auditable replay.

## 2) Formulas and thresholds

```text
partition_lag_seconds = backlog_events / consume_rate_eps
required_tu_or_pu = ceil(max(ingress/per_unit_ingress, egress/per_unit_egress))
watermark_window_ms = out_of_order_ms + clock_skew_ms + margin_ms
wake_suppression_ratio = dedup_wake / raw_wake
```

Recommended thresholds:
- `lag_p95 < 8s`
- `suppression_ratio > 0.6`

## 3) Runnable snippets (Bicep / YAML / KQL)

### Bicep

```bicep
resource ehns 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: 'eh-agent-rti'
  sku: { name: 'Standard', tier: 'Standard', capacity: 4 }
}
```

### YAML

```yaml
wakeDedup:
  key: "${tenantId}:${resourceId}:${alertType}"
  windowMs: 120000
  actionOnDuplicate: "merge-and-skip-wake"
```

### KQL

```kql
AgentWakeupPipeline
| where TimeGenerated > ago(30m)
| summarize lag_p95=percentile(PartitionLagSeconds,95), raw_wake=sum(RawWakeEvents), dedup_wake=sum(DedupWakeEvents) by TenantId, PartitionId, bin(TimeGenerated, 5m)
| extend suppression_ratio = iif(raw_wake == 0, 0.0, dedup_wake / raw_wake)
| where lag_p95 > 8 or suppression_ratio < 0.6
```

## 4) Triage flow

1. Lag breach: increase TU/PU or apply backpressure.  
2. Low suppression ratio: widen dedup window and suppress duplicate wakes.  
3. Re-open non-critical agents progressively after recovery.

## 5) Conclusion

Event-driven agent reliability is not solved by adding more consumers alone; it requires coordinated partition sizing, disorder tolerance, and wake-storm suppression.
