# Cycle #2458 核心工程专著：Cosmos DB 多区域 Agent Checkpoint 深度实战（zh-CN）

- Round/Cycle: `1053 / 2458`
- 主题：`cosmosdb-multi-region-agent-checkpoint-ru-hotkey-vector-ttl-faq-r1053`
- 聚焦：`durable checkpoint`, `RU hot-key mitigation`, `vector/session TTL`, `跨区恢复`

## 1. 规模化公式与容量基线

```text
RU_total = (W_qps*RUw + R_qps*RUr + V_qps*RUv) * 1.3
T_restore_p95 = T_query_p95 + T_deserialize + T_replay_delta + T_attach
hot_partition_ratio = RU_partition_max / RU_container_total
```

建议阈值：
- `T_restore_p95 <= 1200ms`
- `hot_partition_ratio <= 0.18`（预警线），`<= 0.25`（硬红线）
- `normalizedRUConsumption <= 0.85`（5 分钟滑窗）

## 2. 多区域 durable checkpoint 设计

1. 会话状态容器与向量容器拆分。  
2. checkpoint 文档使用带盐哈希分区键，避免 tenant 热点。  
3. Session 一致性默认，关键写操作启用幂等 token。  
4. TTL 分层：session 短 TTL，checkpoint 中 TTL，向量索引长 TTL。

## 3. 可运行配置片段

### 3.1 Bicep（多区域账户）

```bicep
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: 'agent-cosmos-prod'
  location: resourceGroup().location
  properties: {
    enableAutomaticFailover: true
    consistencyPolicy: { defaultConsistencyLevel: 'Session' }
    locations: [
      { locationName: 'East US', failoverPriority: 0, isZoneRedundant: true }
      { locationName: 'West Europe', failoverPriority: 1, isZoneRedundant: true }
    ]
  }
}
```

### 3.2 KQL（triage）

```kql
AgentCheckpointLogs
| where TimeGenerated > ago(30m)
| summarize p95_restore=percentile(RestoreMs,95), max_ru=max(RUCharge) by PartitionKeyHash, Region
| extend hot_ratio=todouble(max_ru)/10000.0
| where p95_restore > 1200 or hot_ratio > 0.25
```

## 4. 失效模式与处置

- **RU 热分区**：分区键增加 `tenantId + hash(sessionId)`，并引入写散列盐。  
- **跨区恢复变慢**：优先切本区读；索引策略对向量字段独立优化。  
- **TTL 回收积压**：周期扫尾任务每 10 分钟执行，超 15 分钟积压告警。  
- **重复重放**：checkpoint 写入幂等键（`sessionId+stepId+version`）。

## 5. 生产检查清单（高强度版）

1. RU 看板含 `95p`, `99p`, `per-partition max`.  
2. 恢复链路有基准压测和回放包。  
3. failover 演练至少周级一次。  
4. policy/version 漂移有自动阻断。  
5. 申诉/审计取证可一键导出完整 trace。
