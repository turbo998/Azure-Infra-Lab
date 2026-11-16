# Round 1071 / Cycle 2476 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Event Hubs + Fabric Eventstream/ADX RTI 事件驱动 Agent 唤醒与告警风暴去重**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2476-benchmark.json`

## 1) 场景目标

事件驱动 Agent 平台常见两类故障：  
1. 分区积压导致唤醒延迟级联；  
2. 告警风暴触发 wake-storm，放大重复处理成本。

目标是通过 Event Hubs + Fabric RTI + ADX 构建“低延迟唤醒 + 去重抑制 + 可回放”闭环。

## 2) 核心公式（吞吐/滞后/窗口）

```text
partition_lag_seconds = backlog_events / consume_rate_eps
```

```text
required_tu_or_pu =
  ceil((ingress_mbps / per_unit_ingress_mbps) ∪ (egress_mbps / per_unit_egress_mbps))
```

```text
watermark_window_ms =
  max_out_of_order_ms + clock_skew_ms + safety_margin_ms
```

```text
wake_suppression_ratio =
  deduplicated_wake_events / raw_wake_events
```

建议阈值：`partition_lag_seconds p95 < 8`，`wake_suppression_ratio > 0.6`。

## 3) 策略设计（唤醒与抑制）

1. 基于 event-key 做窗口去重（tenant+resource+alert-type）。  
2. 仅在窗口首次事件触发 Agent 唤醒；重复事件合并计数。  
3. 超阈值分区触发背压并降级非关键 Agent。

## 4) 可运行片段（Bicep / YAML / KQL）

### 4.1 Bicep：Event Hubs + ADX 入口

```bicep
resource ehns 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: 'eh-agent-rti'
  location: resourceGroup().location
  sku: { name: 'Standard', tier: 'Standard', capacity: 4 }
}
```

### 4.2 YAML：唤醒去重窗口策略

```yaml
wakeDedup:
  key: "${tenantId}:${resourceId}:${alertType}"
  windowMs: 120000
  suppressThreshold: 3
  actionOnDuplicate: "merge-and-skip-wake"
```

### 4.3 KQL：分区滞后与风暴抑制观测

```kql
AgentWakeupPipeline
| where TimeGenerated > ago(30m)
| summarize
    lag_p95=percentile(PartitionLagSeconds,95),
    raw_wake=sum(RawWakeEvents),
    dedup_wake=sum(DedupWakeEvents)
    by TenantId, PartitionId, bin(TimeGenerated, 5m)
| extend suppression_ratio = iif(raw_wake == 0, 0.0, dedup_wake / raw_wake)
| where lag_p95 > 8 or suppression_ratio < 0.6
| order by lag_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2476-benchmark.json`）：

- `unfenced_event_wakestorm_guard_drift_rate = 534 / 4410 = 12.1%`
- `event_wakestorm_guard_variance_rate = 216 / 4410 = 4.9%`
- `event_wakestorm_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 高频告警、多租户、需低延迟自动唤醒 Agent 的平台。  
- 需要事件乱序容忍与去重抑制能力。

**Not for**
- 低频批处理、无实时唤醒要求的离线系统。  
- 无统一事件键与租户标识的数据流。
