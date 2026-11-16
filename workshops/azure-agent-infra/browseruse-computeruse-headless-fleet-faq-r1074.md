# Round 1074 / Cycle 2479 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Headless Chromium Browser-Use/Computer-Use Agent Fleet（ACA/AKS）+ NAT Gateway**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2479-benchmark.json`

## 1) 场景目标

浏览器自动化 Agent 集群的典型瓶颈是：`/dev/shm` 与 V8 heap OOM、SNAT 端口耗尽、视觉截图与可访问树输入之间的 token/时延权衡。  
目标：保证高并发稳定性并控制单位会话成本。

## 2) 核心公式（容量/时延）

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

建议阈值：`oom_restart_rate < 0.5%`，`snat_utilization < 0.7`。

## 3) 运行策略

1. `/dev/shm` 与 heap 分级配置，超阈值触发 Pod 回收。  
2. NAT 网关按峰值并发预分配端口预算。  
3. 优先 accessibility-tree 输入，必要时降采样截图回退。

## 4) 可运行片段（Bicep / YAML / KQL）

### 4.1 Bicep：NAT Gateway 绑定

```bicep
resource nat 'Microsoft.Network/natGateways@2023-09-01' = {
  name: 'nat-browser-fleet'
  location: resourceGroup().location
  sku: { name: 'Standard' }
}
```

### 4.2 YAML：浏览器 Pod 资源约束

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

### 4.3 KQL：OOM 与 SNAT 饱和监控

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

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2479-benchmark.json`）：

- `unfenced_browser_fleet_guard_drift_rate = 534 / 4410 = 12.1%`
- `browser_fleet_guard_variance_rate = 216 / 4410 = 4.9%`
- `browser_fleet_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 高并发 Browser/Computer-Use agent 执行场景。  
- 需要对内存、网络端口、token 成本做统一预算控制。

**Not for**
- 低并发、短任务、无截图/DOM重负载的轻量自动化。  
- 缺少 NAT 与容器可观测指标的环境。
