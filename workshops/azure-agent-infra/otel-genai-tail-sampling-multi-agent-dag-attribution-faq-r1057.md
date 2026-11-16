# Round 1057 / Cycle 2462 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **OpenTelemetry GenAI 语义约定 + ADX/App Insights Tail-based Sampling：多 Agent DAG Span 归因与异常排障**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2462-benchmark.json`

## 1) Executive Summary

本轮聚焦“看得见、算得准、查得快”的可观测性闭环：多 Agent DAG 链路里 token、延迟、错误常被采样丢失与归因混淆。  
核心结论：**GenAI span 语义标准化 + tail-based 保真采样 + DAG 节点级归因 KQL** 是生产级排障最短路径。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2462-sources.json`）

## 3) 核心公式（采样 / 归因 / 延迟）

### Q1: Tail-based 采样预算怎么设？

```text
keep_rate = min(1.0, error_weight*error_ratio + slow_weight*slow_ratio + baseline_rate)
```

建议：关键错误链路 `keep_rate >= 0.8`，健康链路 `0.05~0.15`。

### Q2: 多 Agent DAG 节点归因延迟

```text
dag_path_latency_ms = Σ(span_latency_ms for node in critical_path)
node_blame_ratio = node_latency_ms / dag_path_latency_ms
```

当 `node_blame_ratio > 0.35` 持续 3 窗口，视为主瓶颈节点。

### Q3: Token 成本异常阈值

```text
token_anomaly_z = (tokens_per_req - mean_tokens) / std_tokens
```

`token_anomaly_z > 3` 且 `p95_latency` 同步上升时触发高优先级告警。

## 4) Runnable snippets（Bicep / YAML / KQL）

### 4.1 Bicep（App Insights + Log Analytics）

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

### 4.2 YAML（OTel Collector tail sampling）

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

### 4.3 KQL（DAG 归因 + token/延迟异常）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2462-benchmark.json -> percentage_contract`）：

- `unfenced_otel_genai_trace_tail_sampling_guard_drift_rate = 534 / 4410 = 12.1%`
- `otel_genai_trace_tail_sampling_guard_variance_rate = 216 / 4410 = 4.9%`
- `otel_genai_trace_tail_sampling_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（可观测性策略）

| 方案 | 诊断完整性 | 成本控制 | 实时性 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 全量采样 | 高 | 低 | 高 | 低 | 短期排障 |
| 头采样 | 低 | 高 | 中 | 低 | 低风险业务 |
| OTel GenAI + Tail Sampling + DAG Attribution | **高** | **中高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `p95_latency_ms > 1200`：先看关键路径 `node_blame_ratio`。  
2. `error_rate > 2%`：临时上调错误链路 keep_rate 到 1.0。  
3. `token_anomaly_z > 3`：定位 prompt 模板或重试风暴。  
4. 同一 WorkflowId 高频超时：检查上下游 fan-out 是否失衡。  
5. 采样器丢 trace：提高 `num_traces` 并缩短 `decision_wait` 观测窗口。
