# Cycle #2480 核心工程专著：断网边缘 Agent 混合架构（Arc + AIO）（zh-CN）

- Round/Cycle: `1075 / 2480`
- Topic: `arc-aio-disconnected-edge-agent-faq-r1075`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 工程目标

断网场景下保证本地可运行，恢复后可追赶，且策略可一致收敛。

## 2) 关键公式

```text
cloud_escalation_rate = count(conf<threshold) / total
mqtt_buffer_disk_gb = (msg_rate * avg_msg_kb * outage_sec * replica) / (1024*1024)
recovery_catchup_seconds = backlog / post_reconnect_consume_rate
```

阈值：
- `escalation_rate < 0.25`
- `catchup_p95 < 300s`

## 3) Runnable snippets（Bicep / YAML / KQL）

### Bicep

```bicep
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' = {
  name: 'arc-edge-cluster'
}
```

### YAML

```yaml
inferencePolicy:
  confidenceThreshold: 0.78
  escalateToCloud: true
mqttBuffer:
  storeForwardEnabled: true
  maxDiskGb: 120
```

### KQL

```kql
EdgeAgentPipeline
| where TimeGenerated > ago(30m)
| summarize escalation_rate=avg(CloudEscalationRate), catchup_p95=percentile(RecoveryCatchupSeconds,95) by EdgeSite, bin(TimeGenerated, 5m)
| where escalation_rate > 0.25 or catchup_p95 > 300
```

## 4) 处置流程

1. WAN 中断：启用本地推理 + 缓冲写盘。  
2. WAN 恢复：限速回放并监控追赶时延。  
3. 策略漂移：Flux 同步后逐步恢复云端升级比例。

## 5) 结论

断网边缘可靠性由“本地推理阈值 + 消息缓冲容量 + 恢复追赶速率”共同决定，单点优化无法替代体系化预算。
