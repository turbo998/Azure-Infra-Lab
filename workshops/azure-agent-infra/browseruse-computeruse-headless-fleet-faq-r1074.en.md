# Round 1074 / Cycle 2479 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Headless Chromium Browser-Use/Computer-Use Agent Fleet (ACA/AKS) + NAT Gateway**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2479-benchmark.json`

## 1) Scenario objective

Typical bottlenecks in browser-agent fleets are `/dev/shm` + V8 heap OOM, SNAT port exhaustion, and token/latency trade-offs between accessibility-tree input and screenshot vision input.  
Goal: sustain high concurrency while controlling per-session cost.

## 2) Core formulas (capacity / latency)

```text
pod_memory_budget_mb = shm_mb + v8_heap_mb + chromium_overhead_mb + safety_margin_mb
max_sessions_per_node = floor(node_available_mb / pod_memory_budget_mb)
```

```text
required_snat_ports =
  concurrent_sessions * outbound_connections_per_session * burst_factor
```

```text
input_token_latency_tradeoff_ms =
  (vision_tokens - a11y_tree_tokens) * model_ms_per_1k_tokens / 1000
```

Recommended thresholds: `oom_restart_rate < 0.5%`, `snat_utilization < 0.7`.

## 3) Runtime strategy

1. Tiered `/dev/shm` + heap sizing and recycle pods on threshold breach.  
2. Pre-budget NAT ports based on peak concurrency.  
3. Prefer accessibility-tree input; fallback to downsampled screenshots only when needed.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep: NAT Gateway anchor

```bicep
resource nat 'Microsoft.Network/natGateways@2023-09-01' = {
  name: 'nat-browser-fleet'
  location: resourceGroup().location
  sku: { name: 'Standard' }
}
```

### 4.2 YAML: browser pod resource contract

```yaml
resources:
  limits:
    memory: "2Gi"
env:
  - name: CHROME_SHM_MB
    value: "384"
  - name: V8_HEAP_MB
    value: "1024"
```

### 4.3 KQL: OOM and SNAT saturation triage

```kql
BrowserFleetMetrics
| where TimeGenerated > ago(30m)
| summarize
    oom_rate=avg(OomRestartRate),
    snat_util=percentile(SnatUtilization,95),
    m2r_p95=percentile(ModelRoundtripMs,95)
    by Cluster, bin(TimeGenerated, 5m)
| where oom_rate > 0.005 or snat_util > 0.7
| order by snat_util desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2479-benchmark.json`):

- `unfenced_browser_fleet_guard_drift_rate = 534 / 4410 = 12.1%`
- `browser_fleet_guard_variance_rate = 216 / 4410 = 4.9%`
- `browser_fleet_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- High-concurrency browser/computer-use agent execution environments.  
- Need unified budgets for memory, network ports, and token costs.

**Not for**
- Low-concurrency lightweight automation without screenshot/DOM-heavy workloads.  
- Environments lacking NAT and container observability.
