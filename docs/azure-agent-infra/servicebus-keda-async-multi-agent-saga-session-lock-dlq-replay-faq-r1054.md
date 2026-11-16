# Round 1054 / Cycle 2459 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure Service Bus + KEDA 异步多 Agent Saga 编排：Session Lock 续约、DLQ 隔离与回放**
>
> Date (BJT): 2026-11-16  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2459-benchmark.json`

## 1) Executive Summary

本轮聚焦高并发异步编排：多 Agent 通过 Service Bus + KEDA 执行 saga 时，如何避免锁丢失、重复消费与毒消息扩散。  
核心结论：**会话锁续约公式 + KEDA 滞回扩缩 + DLQ 隔离回放 runbook** 是生产必需三件套。

## 2) Daily capability breakthroughs radar（2026-11-16）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2459-sources.json`）

## 3) 核心公式（Lock / Throughput / Scale）

### Q1: 会话锁续约周期如何算？

`renew_interval_sec = max(5, min(lock_duration_sec * 0.4, handler_p95_sec * 0.5))`

当 `handler_p95_sec > lock_duration_sec * 0.75` 时，必须提升并发或拆分任务粒度。

### Q2: 消费并发上限估算？

`max_workers = floor(target_msg_per_sec * handler_p95_sec / utilization_target)`

推荐 `utilization_target = 0.65~0.75`，避免峰值抖动。

### Q3: DLQ 告警阈值？

`dlq_rate = dlq_messages / processed_messages`

- `dlq_rate > 0.02`：预警  
- `dlq_rate > 0.05`：触发隔离模式 + 自动回放冻结

## 4) Runnable snippets（Bicep / YAML / Policy / KQL）

### 4.1 Bicep（Service Bus Queue + Session）

```bicep
resource queue 'Microsoft.ServiceBus/namespaces/queues@2023-01-01-preview' = {
  name: 'sbns-prod/saga-events'
  properties: {
    requiresSession: true
    lockDuration: 'PT2M'
    maxDeliveryCount: 8
    deadLetteringOnMessageExpiration: true
  }
}
```

### 4.2 KEDA ScaledObject（按队列积压扩缩）

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: saga-workers
spec:
  scaleTargetRef:
    name: saga-worker
  minReplicaCount: 3
  maxReplicaCount: 60
  cooldownPeriod: 120
  triggers:
    - type: azure-servicebus
      metadata:
        queueName: saga-events
        namespace: sbns-prod
        messageCount: "200"
```

### 4.3 Azure Policy（强制启用 DLQ）

```json
{
  "if": {
    "allOf": [
      { "field": "type", "equals": "Microsoft.ServiceBus/namespaces/queues" },
      { "field": "Microsoft.ServiceBus/namespaces/queues/deadLetteringOnMessageExpiration", "notEquals": true }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL（锁丢失与 DLQ 关联排障）

```kql
ServiceBusWorkerLogs
| where TimeGenerated > ago(30m)
| summarize lock_lost=countif(Event=="LockLost"),
            dlq_push=countif(Event=="DLQPush"),
            p95_handler=percentile(HandlerMs,95) by Queue, SessionId
| where lock_lost > 0 or dlq_push > 20 or p95_handler > 90000
| order by lock_lost desc, dlq_push desc
```

## 5) Decision matrix（Saga 编排方案）

| 方案 | 可恢复性 | 延迟稳定性 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---|
| 同步串行调用 | 中 | 低 | 低 | 小规模 |
| 异步队列无 Session | 中 | 中 | 中 | 非顺序业务 |
| Service Bus Session + KEDA + DLQ Replay | **高** | **高** | 中高 | **生产推荐** |

## 6) Production failure-triage checklist

1. `lock_lost_rate > 0.01`：检查续约周期与 handler p95。  
2. `p95_handler_ms > 90000`：拆分 saga stage 或并行化子任务。  
3. `dlq_rate > 0.05`：进入 quarantine，暂停自动回放。  
4. 连续 3 个窗口队列积压增长：提升 `maxReplicaCount` 或下调触发阈值。  
5. 回放前验证幂等键覆盖率 = `100%`（`sagaId+stepId+attempt`）。  
