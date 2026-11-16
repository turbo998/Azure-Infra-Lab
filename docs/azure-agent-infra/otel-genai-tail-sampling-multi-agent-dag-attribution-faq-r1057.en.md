# Round 1057 / Cycle 2462 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **OpenTelemetry GenAI semantic conventions + ADX/App Insights tail-based sampling for multi-agent DAG span attribution**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2462-benchmark.json`

## 1) Executive Summary

This round closes the observability gap for multi-agent DAGs where token, latency, and error paths are often lost by weak sampling or broken attribution.  
Key result: **standardized GenAI spans + tail-based fidelity sampling + node-level DAG attribution KQL** provides the shortest production triage path.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2462-sources.json`)

## 3) Core formulas (sampling / attribution / latency)

### Q1: Tail-sampling keep budget

```text
keep_rate = min(1.0, error_weight*error_ratio + slow_weight*slow_ratio + baseline_rate)
```

Guideline: critical error traces `keep_rate >= 0.8`; healthy paths `0.05~0.15`.

### Q2: Multi-agent DAG attribution latency

```text
dag_path_latency_ms = Σ(span_latency_ms for node in critical_path)
node_blame_ratio = node_latency_ms / dag_path_latency_ms
```

If `node_blame_ratio > 0.35` for 3 windows, treat as primary bottleneck node.

### Q3: Token anomaly threshold

```text
token_anomaly_z = (tokens_per_req - mean_tokens) / std_tokens
```

Trigger high-priority alert when `token_anomaly_z > 3` and `p95_latency` rises together.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep (App Insights + Log Analytics)

```bicep
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-genai-prod'
  location: resourceGroup().location
  kind: 'web'
  properties: { Application_Type: 'web' }
}
resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-genai-prod'
  location: resourceGroup().location
  properties: { sku: { name: 'PerGB2018' } }
}
```

### 4.2 YAML (OTel Collector tail sampling)

```yaml
processors:
  tail_sampling:
    decision_wait: 10s
    num_traces: 50000
    policies:
      - name: error-traces
        type: status_code
        status_code: { status_codes: [ERROR] }
      - name: slow-traces
        type: latency
        latency: { threshold_ms: 1200 }
```

### 4.3 KQL (DAG attribution + token/latency anomalies)

```kql
GenAiTrace
| where TimeGenerated > ago(30m)
| summarize p95_latency=percentile(DurationMs,95),
            total_tokens=sum(TotalTokens),
            req=count(),
            err=countif(Status=="Error")
            by WorkflowId, NodeId
| extend tokens_per_req = todouble(total_tokens) / req
| where p95_latency > 1200 or err > 0
| order by p95_latency desc, tokens_per_req desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2462-benchmark.json -> percentage_contract`):

- `unfenced_otel_genai_trace_tail_sampling_guard_drift_rate = 534 / 4410 = 12.1%`
- `otel_genai_trace_tail_sampling_guard_variance_rate = 216 / 4410 = 4.9%`
- `otel_genai_trace_tail_sampling_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (observability patterns)

| Pattern | Diagnostic fidelity | Cost control | Real-time signal | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Full sampling | High | Low | High | Low | Short-term firefight |
| Head sampling | Low | High | Medium | Low | Low-risk workloads |
| OTel GenAI + tail sampling + DAG attribution | **High** | **Medium-high** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `p95_latency_ms > 1200`: inspect critical-path `node_blame_ratio`.
2. `error_rate > 2%`: temporarily raise error-trace keep rate to 1.0.
3. `token_anomaly_z > 3`: trace prompt template drift or retry storms.
4. Repeated timeout on same `WorkflowId`: inspect fan-out imbalance.
5. Sampler drops traces: raise `num_traces` and tune `decision_wait`.
