# Cycle #2479 核心工程专著：Headless 浏览器 Agent Fleet（zh-CN）

- Round/Cycle: `1074 / 2479`
- Topic: `browseruse-computeruse-headless-fleet-faq-r1074`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 工程目标

在 ACA/AKS 运行 Browser-Use/Computer-Use agent 时，控制 OOM、SNAT 与 token 成本三类系统性风险。

## 2) 关键公式

```text
pod_memory_budget_mb = shm + heap + chromium_overhead + margin
max_sessions_per_node = floor(node_available / pod_memory_budget_mb)
required_snat_ports = concurrency * conn_per_session * burst_factor
token_latency_tradeoff_ms = (vision_tokens - a11y_tokens) * ms_per_1k_tokens / 1000
```

阈值：
- `oom_rate < 0.5%`
- `snat_utilization < 0.7`

## 3) Runnable snippets（Bicep / YAML / KQL）

### Bicep

```bicep
resource nat 'Microsoft.Network/natGateways@2023-09-01' = {
  name: 'nat-browser-fleet'
}
```

### YAML

```yaml
env:
  - name: CHROME_SHM_MB
    value: "384"
  - name: V8_HEAP_MB
    value: "1024"
```

### KQL

```kql
BrowserFleetMetrics
| where TimeGenerated > ago(30m)
| summarize oom_rate=avg(OomRestartRate), snat_util=percentile(SnatUtilization,95) by Cluster, bin(TimeGenerated, 5m)
| where oom_rate > 0.005 or snat_util > 0.7
```

## 4) 处置流程

1. OOM 上升：降低并发、回收高占用 Pod。  
2. SNAT 饱和：扩容 NAT 端口池并削峰限流。  
3. token 过高：优先 accessibility-tree，降低截图频率。

## 5) 结论

浏览器 Agent Fleet 的稳定性由内存、网络端口、输入模态三维预算共同决定，必须统一调度与观测。
