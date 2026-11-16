# Cycle #2459 Core Engineering Monograph: Service Bus + KEDA Multi-Agent Saga (en)

- Round/Cycle: `1054 / 2459`
- Topic: `servicebus-keda-async-multi-agent-saga-session-lock-dlq-replay-faq-r1054`

## 1. Core formulas and thresholds

```text
renew_interval_sec = max(5, min(lock_duration*0.4, handler_p95*0.5))
max_workers = floor(target_msg_per_sec * handler_p95_sec / utilization_target)
dlq_rate = dlq_messages / processed_messages
```

Recommended thresholds:
- `lock_lost_rate <= 1%`
- `dlq_rate <= 2%` (quarantine when >5%)
- `p95_handler_ms <= 90000`

## 2. Runnable snippets

### Service Bus queue (sessions + DLQ)

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

## 3. Failure modes and runbook

1. **Frequent lock loss**: shorten renew interval and split long-running saga steps.
2. **DLQ surge**: enter quarantine, freeze auto-replay, classify by fault bucket first.
3. **Duplicate execution**: verify idempotency-key coverage (`sagaId+stepId+attempt`) before replay.
4. **Scale oscillation**: increase cooldown to avoid replica thrash and lock contention.

## 4. Production checklist

- Queue session lock, DLQ, and maxDeliveryCount are policy-enforced.
- KEDA thresholds/cooldown are load-test-backed.
- Replay flow has “quarantine before replay” guardrails.
- Full trace links to per-saga-step execution lineage.
