# Round 1053 / Cycle 2458 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Cosmos DB 多区域 Durable Agent Checkpoint + RU 热分区治理 + Vector/Session TTL**
>
> Date (BJT): 2026-11-16  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2458-benchmark.json`

## 1) Executive Summary

本轮聚焦核心工程问题：Agent 会话状态与 checkpoint 在 Cosmos DB 多区域下如何做到**低延迟、可恢复、可控成本**。  
核心结论：采用“多区域写 + 分区热键打散 + 分层 TTL + 向量与会话分容器”是生产可扩展基线。

## 2) Daily capability breakthroughs radar（2026-11-16）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2458-sources.json`）

## 3) 核心公式（Sizing / Latency / RU）

### Q1: RU 预算怎么估算？

`RU_total = (W_qps * RU_write + R_qps * RU_read + V_qps * RU_vector) * safety_factor`

建议 `safety_factor = 1.25~1.5`（覆盖高峰抖动）。

### Q2: checkpoint 恢复时延如何建模？

`T_restore_p95 ≈ T_query_p95 + T_deserialize + T_replay_delta + T_session_attach`

若 `T_restore_p95 > 1200ms`，需优先检查热分区与跨区读路径。

### Q3: 热键判定阈值？

`hot_partition_ratio = RU_partition_max / RU_container_total`

- `> 0.18`：黄色预警  
- `> 0.25`：红色告警，触发分区键重算与流量打散

## 4) Runnable snippets（Bicep / YAML / Policy / KQL）

### 4.1 Cosmos DB Bicep（多区域 + autoscale + TTL）

```bicep
resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: 'agent-cosmos-prod'
  location: resourceGroup().location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    locations: [
      { locationName: 'East US', failoverPriority: 0, isZoneRedundant: true }
      { locationName: 'West Europe', failoverPriority: 1, isZoneRedundant: true }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}
```

### 4.2 ACA Job YAML（checkpoint compact + TTL sweep）

```yaml
apiVersion: 2024-03-01
type: Microsoft.App/jobs
name: checkpoint-ttl-sweeper
properties:
  environmentId: /subscriptions/xxx/resourceGroups/rg/providers/Microsoft.App/managedEnvironments/aca-env
  configuration:
    triggerType: Schedule
    scheduleTriggerConfig:
      cronExpression: "*/10 * * * *"
  template:
    containers:
      - name: sweeper
        image: ghcr.io/org/agent-checkpoint-sweeper:stable
        env:
          - name: COSMOS_DB
            value: agent_state
```

### 4.3 Azure Policy（禁止无 TTL 的状态容器）

```json
{
  "if": {
    "allOf": [
      { "field": "type", "equals": "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers" },
      { "field": "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/defaultTtl", "exists": "false" }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL（热分区与恢复时延联动）

```kql
AgentCheckpointLogs
| where TimeGenerated > ago(30m)
| summarize p95_restore=percentile(RestoreMs,95), max_ru=max(RUCharge) by PartitionKeyHash, Region
| extend hot_ratio = todouble(max_ru) / 10000.0
| where p95_restore > 1200 or hot_ratio > 0.25
| order by p95_restore desc
```

## 5) Decision matrix（Checkpoint 架构）

| 方案 | 恢复速度 | 成本 | 一致性治理 | 推荐 |
|---|---:|---:|---:|---|
| 单区域单容器 | 中 | 低 | 低 | PoC |
| 多区域单容器（无分层） | 中高 | 中 | 中 | 过渡 |
| 多区域分容器 + 分层 TTL + 热键治理 | **高** | **中高但可控** | **高** | **生产推荐** |

## 6) Production failure triage checklist

1. **先看恢复**：`p95_restore_ms > 1200` 触发事件。  
2. **再看热键**：`hot_partition_ratio > 0.25` 立即打散。  
3. **看 RU 顶格**：`normalizedRUConsumption > 0.85` 且持续 5 分钟则升档 autoscale。  
4. **看 TTL 堆积**：过期文档回收延迟 > 15 分钟时启动 sweep job。  
5. **看跨区漂移**：若主备读取延迟差 > 2x，切换读优先路由并复核索引策略。  
