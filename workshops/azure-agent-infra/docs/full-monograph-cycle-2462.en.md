# Cycle #2462 Core Engineering Monograph: OTel GenAI + Tail Sampling Observability (en)

- Round/Cycle: `1057 / 2462`
- Topic: `otel-genai-tail-sampling-multi-agent-dag-attribution-faq-r1057`

## 1) Core formulas

```text
keep_rate = min(1.0, error_weight*error_ratio + slow_weight*slow_ratio + baseline_rate)
dag_path_latency_ms = Σ(span_latency_ms in critical_path)
node_blame_ratio = node_latency_ms / dag_path_latency_ms
token_anomaly_z = (tokens_per_req - mean_tokens) / std_tokens
```

Thresholds:
- `p95_latency_ms <= 1200`
- `error_rate <= 2%`
- `token_anomaly_z <= 3`

## 2) Runnable snippets

### Bicep (App Insights + LAW)

```bicep
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-genai-prod'
  kind: 'web'
  properties: { Application_Type: 'web' }
}
```

### YAML (collector tail sampling)

```yaml
tail_sampling:
  decision_wait: 10s
  num_traces: 50000
  policies:
    - name: error-traces
      type: status_code
    - name: slow-traces
      type: latency
```

### KQL (DAG attribution and anomalies)

```kql
GenAiTrace
| where TimeGenerated > ago(30m)
| summarize p95=percentile(DurationMs,95), tokens=sum(TotalTokens), err=countif(Status=="Error") by WorkflowId, NodeId
| where p95 > 1200 or err > 0
```

## 3) Failure modes and triage

1. **Slow paths dropped by sampling**: increase slow-trace keep rate.
2. **Incomplete error traces**: force 100% retention for error spans.
3. **DAG attribution drift**: standardize trace/span propagation and node naming.
4. **Token surge**: inspect prompt bloat and retry storms.

## 4) Rollout checklist

- Standardize GenAI span attributes.
- Bind tail sampling policies to SLOs.
- Dual-write to ADX/App Insights for auditability.
- Operate node-level DAG KQL dashboards continuously.
