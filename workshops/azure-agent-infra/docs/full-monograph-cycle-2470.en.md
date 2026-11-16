# Cycle #2470 Core Engineering Monograph: Multi-day HITL Orchestration Replay & TCO (en)

- Round/Cycle: `1065 / 2470`
- Topic: `durable-task-scheduler-dapr-temporal-continueasnew-tco-faq-r1065`

## 1) Core formulas

```text
replay_ms = event_count * avg_deserialize_ms + state_rehydrate_ms
continue_as_new_when = event_count >= 20000 or replay_ms >= 600
tco_per_1k = compute_cost + storage_history_cost + ops_cost
```

Thresholds:
- `replay_p95_ms <= 800`
- `event_history_p95 <= 20000`

## 2) Runnable snippets

### Bicep (history storage backbone)

```bicep
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stworkflowhist'
}
```

### YAML (replay thresholds)

```yaml
workflow:
  maxReplayEvents: 20000
  continueAsNewReplayMs: 600
```

### Python (ContinueAsNew logic)

```python
if events >= 20000 or replay_ms >= 600:
    ctx.continue_as_new({"events": 0})
```

### KQL (replay triage)

```kql
WorkflowOrchestrationLogs
| where TimeGenerated > ago(30m)
| summarize replay_p95=percentile(ReplayMs,95), hist_p95=percentile(EventHistoryCount,95) by Engine
| where replay_p95 > 800 or hist_p95 > 20000
```

## 3) Failure modes

1. History growth linearly degrades replay time.
2. Over-high ContinueAsNew thresholds bloat instances.
3. Multi-day waits keep hot state and inflate cost.
4. Mixed engines without tiering increase operational overhead.

## 4) Rollout checklist

- Put replay/history thresholds into SLO controls.
- Map workflow classes to orchestration engines explicitly.
- Externalize long waits from hot orchestration state.
- Recompute DTS/Dapr/Temporal TCO crossover periodically.
