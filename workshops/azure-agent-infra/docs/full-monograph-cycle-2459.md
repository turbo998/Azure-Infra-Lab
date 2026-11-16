# Cycle #2459 核心工程专著：Service Bus + KEDA 多 Agent Saga（zh-CN）

- Round/Cycle: `1054 / 2459`
- 主题：`servicebus-keda-async-multi-agent-saga-session-lock-dlq-replay-faq-r1054`

## 1. 关键公式与阈值

```text
renew_interval_sec = max(5, min(lock_duration*0.4, handler_p95*0.5))
max_workers = floor(target_msg_per_sec * handler_p95_sec / utilization_target)
dlq_rate = dlq_messages / processed_messages
```

阈值建议：
- `lock_lost_rate <= 1%`
- `dlq_rate <= 2%`（>5% 启动隔离）
- `p95_handler_ms <= 90000`

## 2. Runnable 片段

### Service Bus queue (session + DLQ)

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

### KEDA autoscale

```yaml
triggers:
  - type: azure-servicebus
    metadata:
      queueName: saga-events
      messageCount: "200"
```

### KQL triage

```kql
ServiceBusWorkerLogs
| where TimeGenerated > ago(30m)
| summarize lock_lost=countif(Event=="LockLost"),
            dlq_push=countif(Event=="DLQPush"),
            p95_handler=percentile(HandlerMs,95) by Queue, SessionId
| where lock_lost > 0 or dlq_push > 20 or p95_handler > 90000
```

## 3. 失效模式与 runbook

1. **锁丢失频发**：缩短续约周期并拆分长事务步骤。  
2. **DLQ 突增**：进入 quarantine，冻结自动回放，先按错误类型分桶。  
3. **重复执行**：验证幂等键覆盖（`sagaId+stepId+attempt`）后再放开回放。  
4. **扩缩抖动**：提高 cooldown，避免 replica 抖动引发锁争抢。

## 4. 生产清单

- 队列会话锁、DLQ、maxDeliveryCount 配置已策略化。  
- KEDA 阈值与 cooldown 有压测依据。  
- 回放流程具备“先隔离后重放”护栏。  
- 全链路 trace 可关联到 saga step 级别。
