# Round 1075 / Cycle 2480 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Arc-enabled K8s + Azure IoT Operations 断网边缘混合 Agent Infra**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2480-benchmark.json`

## 1) 场景目标

断网边缘 Agent 的核心挑战是：本地模型置信度不足时如何升级到云端、WAN 中断期间消息不丢失、策略在恢复后可一致收敛。  
目标：在 Arc + AIO + Flux GitOps 下实现“离线可用、在线可升级、恢复可审计”。

## 2) 核心公式（置信升级/缓冲/延迟）

```text
cloud_escalation_rate =
  count(confidence < threshold) / total_inferences
```

```text
mqtt_buffer_disk_gb =
  (msg_rate_per_sec * avg_msg_kb * outage_seconds * replication_factor) / (1024 * 1024)
```

```text
recovery_catchup_seconds =
  backlog_messages / post_reconnect_consume_rate_mps
```

建议阈值：`cloud_escalation_rate < 0.25`，`recovery_catchup_seconds p95 < 300`。

## 3) 策略设计（离线优先 + 在线升级）

1. 本地 SLM 先处理；低置信度再升级云端 Foundry。  
2. MQTT store-and-forward 在 WAN 中断时持久化到本地磁盘。  
3. WAN 恢复后按 Flux 策略同步与限速回放，避免瞬时洪峰。

## 4) 可运行片段（Bicep / YAML / KQL）

### 4.1 Bicep：Arc 连接集群

```bicep
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' = {
  name: 'arc-edge-cluster'
  location: resourceGroup().location
}
```

### 4.2 YAML：边缘推理升级策略

```yaml
inferencePolicy:
  localModel: slm-edge
  confidenceThreshold: 0.78
  escalateToCloud: true
mqttBuffer:
  storeForwardEnabled: true
  maxDiskGb: 120
```

### 4.3 KQL：断网积压与恢复观测

```kql
EdgeAgentPipeline
| where TimeGenerated > ago(30m)
| summarize
    escalation_rate=avg(CloudEscalationRate),
    catchup_p95=percentile(RecoveryCatchupSeconds,95),
    disk_p95=percentile(BufferDiskUsageGb,95)
    by EdgeSite, bin(TimeGenerated, 5m)
| where escalation_rate > 0.25 or catchup_p95 > 300
| order by catchup_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2480-benchmark.json`）：

- `unfenced_edge_escalation_guard_drift_rate = 534 / 4410 = 12.1%`
- `edge_escalation_guard_variance_rate = 216 / 4410 = 4.9%`
- `edge_escalation_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 断网频发或高时延链路的边缘站点 Agent 平台。  
- 需要本地先行推理并可控升级云端模型。

**Not for**
- 始终高质量网络连接、无需离线容错的中心化平台。  
- 无本地磁盘缓冲能力的轻节点部署。
