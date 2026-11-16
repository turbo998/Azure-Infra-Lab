# Cycle #2462 核心工程专著：OTel GenAI + Tail Sampling 可观测性（zh-CN）

- Round/Cycle: `1057 / 2462`
- Topic: `otel-genai-tail-sampling-multi-agent-dag-attribution-faq-r1057`

## 1) 关键公式

```text
keep_rate = min(1.0, error_weight*error_ratio + slow_weight*slow_ratio + baseline_rate)
dag_path_latency_ms = Σ(span_latency_ms in critical_path)
node_blame_ratio = node_latency_ms / dag_path_latency_ms
token_anomaly_z = (tokens_per_req - mean_tokens) / std_tokens
```

阈值：
- `p95_latency_ms <= 1200`
- `error_rate <= 2%`
- `token_anomaly_z <= 3`

## 2) Runnable snippets

### Bicep（App Insights + LAW）

```bicep
resource ai 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-genai-prod'
  kind: 'web'
  properties: { Application_Type: 'web' }
}
```

### YAML（Collector tail sampling）

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

### KQL（DAG 归因与异常）

```kql
GenAiTrace
| where TimeGenerated > ago(30m)
| summarize p95=percentile(DurationMs,95), tokens=sum(TotalTokens), err=countif(Status=="Error") by WorkflowId, NodeId
| where p95 > 1200 or err > 0
```

## 3) 失效模式与排障

1. **慢链路被采样丢失**：上调 slow-trace keep rate。  
2. **错误链路不完整**：错误 span 强制保留到 100%。  
3. **DAG 归因错位**：统一 trace/span 传播与节点命名。  
4. **token 飙升**：排查 prompt 膨胀与重试风暴。

## 4) 落地清单

- 统一 GenAI span 属性命名。  
- tail sampling 策略与 SLO 绑定。  
- ADX/App Insights 双写以支撑审计。  
- DAG 节点级 KQL 看板持续巡检。
