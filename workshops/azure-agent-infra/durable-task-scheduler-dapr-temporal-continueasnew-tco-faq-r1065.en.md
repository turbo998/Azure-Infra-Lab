# Round 1065 / Cycle 2470 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure Durable Task Scheduler (DTS) vs Dapr Workflow vs Temporal on AKS for multi-day HITL orchestration**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2470-benchmark.json`

## 1) Executive Summary

This round targets multi-day human-in-the-loop orchestration where history growth, replay slowdown, and long-run cost drift become dominant risks.  
Key result: **event-history compaction + `ContinueAsNew` thresholds + engine-tiered placement** is the stable production pattern.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2470-sources.json`)

## 3) Core formulas (replay / compaction / cost)

### Q1: Replay-time budget

```text
replay_ms = event_count * avg_deserialize_ms + state_rehydrate_ms
```

Target: `replay_p95_ms <= 800`; above this, compact history immediately.

### Q2: ContinueAsNew threshold

```text
continue_as_new_when = event_count >= event_threshold or replay_ms >= replay_threshold
```

Recommended: `event_threshold=20k`, `replay_threshold=600ms`.

### Q3: TCO crossover

```text
tco_per_1k = compute_cost + storage_history_cost + ops_cost
crossover = min(tco_dts, tco_dapr, tco_temporal) under p95 and durability SLO
```

## 4) Runnable snippets (Bicep / YAML / Python / KQL)

### 4.1 Bicep (scheduler storage backbone)

```bicep
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stworkflowhist'
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
}
```

### 4.2 YAML (worker replay controls)

```yaml
workflow:
  maxReplayEvents: 20000
  continueAsNewReplayMs: 600
  checkpointInterval: 300
```

### 4.3 Python (Durable continue-as-new pseudo code)

```python
def orchestrator(ctx):
    state = ctx.get_input() or {"events": 0}
    state["events"] += 1
    if state["events"] >= 20000 or ctx.current_replay_ms() >= 600:
        ctx.continue_as_new({"events": 0})
    return state
```

### 4.4 KQL (replay and cost triage)

```kql
WorkflowOrchestrationLogs
| where TimeGenerated > ago(30m)
| summarize replay_p95=percentile(ReplayMs,95),
            hist_p95=percentile(EventHistoryCount,95),
            tco_per_1k=avg(TcoPer1kUsd)
            by Engine, WorkflowClass
| where replay_p95 > 800 or hist_p95 > 20000
| order by replay_p95 desc, hist_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2470-benchmark.json -> percentage_contract`):

- `unfenced_workflow_replay_compaction_tco_guard_drift_rate = 534 / 4410 = 12.1%`
- `workflow_replay_compaction_tco_guard_variance_rate = 216 / 4410 = 4.9%`
- `workflow_replay_compaction_tco_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (multi-day orchestration engines)

| Engine | Replay efficiency | Ops complexity | Ecosystem fit | Cost control | Recommendation |
|---|---:|---:|---:|---:|---|
| DTS | High | Medium | High (Azure-native) | Medium-high | Azure-native default |
| Dapr Workflow | Medium-high | Medium | High (cloud-native) | Medium | Lightweight multi-env |
| Temporal on AKS | High | High | High (complex orchestration) | Medium-high | Large-scale complex flows |

## 7) Production failure-triage checklist

1. `replay_p95_ms > 800`: apply history compaction/sharding first.
2. `hist_p95 > 20k`: force `ContinueAsNew`.
3. Cost spike: split workflow classes by SLA and engine tier.
4. HITL wait timeout: externalize long waits and shorten hot-state retention.
5. Replay jitter: verify serializer version and schema evolution compatibility.
