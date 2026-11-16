# Cycle #2476 核心工程专著：Event-driven Agent 唤醒与风暴去重（zh-CN）

- Round/Cycle: `1071 / 2476`
- Topic: `eventhubs-fabric-rti-agent-wakeup-faq-r1071`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 目标

将 Event Hubs + Fabric RTI + ADX 组合成可控唤醒平面：低滞后、抗风暴、可审计。

## 2) 公式与阈值

```text
partition_lag_seconds = backlog_events / consume_rate_eps
required_tu_or_pu = ceil(max(ingress/per_unit_ingress, egress/per_unit_egress))
watermark_window_ms = out_of_order_ms + clock_skew_ms + margin_ms
wake_suppression_ratio = dedup_wake / raw_wake
```

阈值建议：
- `lag_p95 < 8s`
- `suppression_ratio > 0.6`

## 3) Runnable snippets（Bicep / YAML / KQL）

### Bicep

```bicep
resource ehns 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: 'eh-agent-rti'
  sku: { name: 'Standard', tier: 'Standard', capacity: 4 }
}
```

### YAML

```yaml
wakeDedup:
  key: "${tenantId}:${resourceId}:${alertType}"
  windowMs: 120000
  actionOnDuplicate: "merge-and-skip-wake"
```

### KQL

```kql
AgentWakeupPipeline
| where TimeGenerated > ago(30m)
| summarize lag_p95=percentile(PartitionLagSeconds,95), raw_wake=sum(RawWakeEvents), dedup_wake=sum(DedupWakeEvents) by TenantId, PartitionId, bin(TimeGenerated, 5m)
| extend suppression_ratio = iif(raw_wake == 0, 0.0, dedup_wake / raw_wake)
| where lag_p95 > 8 or suppression_ratio < 0.6
```

## 4) 处置流程

1. 分区滞后超阈值：提升 TU/PU 或触发背压。  
2. 抑制率过低：扩大去重窗口并收敛重复唤醒。  
3. 恢复后渐进放开非关键 Agent。

## 5) 结论

事件驱动 Agent 可靠性关键不在“更多消费者”，而在“分区容量、乱序容忍、去重抑制”三者协同。
