# Round 1054 / Cycle 2459 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure Service Bus + KEDA Async Multi-Agent Saga: Session Lock Renewal, DLQ Quarantine, Replay**
>
> Date (BJT): 2026-11-16  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2459-benchmark.json`

## 1) Executive Summary

This round focuses on high-concurrency async orchestration: when multi-agent sagas run on Service Bus + KEDA, how to avoid lock loss, duplicate processing, and poison-message spread.  
Key result: **lock-renewal math + KEDA hysteresis scaling + DLQ quarantine/replay runbook** is the production baseline.

## 2) Daily capability breakthroughs radar (2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2459-sources.json`)

## 3) Core formulas (lock / throughput / scale)

### Q1: Session-lock renewal interval

`renew_interval_sec = max(5, min(lock_duration_sec * 0.4, handler_p95_sec * 0.5))`

If `handler_p95_sec > lock_duration_sec * 0.75`, increase worker parallelism or split stage granularity.

### Q2: Consumer concurrency sizing

`max_workers = floor(target_msg_per_sec * handler_p95_sec / utilization_target)`

Recommended `utilization_target = 0.65~0.75`.

### Q3: DLQ alert thresholds

`dlq_rate = dlq_messages / processed_messages`

- `dlq_rate > 0.02`: warning  
- `dlq_rate > 0.05`: quarantine mode + freeze auto-replay

## 4) Runnable snippets (Bicep / YAML / Policy / KQL)

### 4.1 Bicep (Service Bus queue with sessions)

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

### 4.2 KEDA ScaledObject (queue-backlog autoscaling)

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

### 4.3 Azure Policy (enforce DLQ enabled)

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

### 4.4 KQL (lock loss + DLQ triage)

```kql
ServiceBusWorkerLogs
| where TimeGenerated > ago(30m)
| summarize lock_lost=countif(Event=="LockLost"),
            dlq_push=countif(Event=="DLQPush"),
            p95_handler=percentile(HandlerMs,95) by Queue, SessionId
| where lock_lost > 0 or dlq_push > 20 or p95_handler > 90000
| order by lock_lost desc, dlq_push desc
```

## 5) Decision matrix (saga orchestration patterns)

| Pattern | Recoverability | Latency stability | Ops complexity | Recommendation |
|---|---:|---:|---:|---|
| Synchronous serial calls | Medium | Low | Low | Small scale only |
| Async queue without sessions | Medium | Medium | Medium | Non-order-sensitive flows |
| Service Bus sessions + KEDA + DLQ replay | **High** | **High** | Medium-high | **Production default** |

## 6) Production failure-triage checklist

1. `lock_lost_rate > 0.01` => inspect renewal interval and handler p95.
2. `p95_handler_ms > 90000` => split saga stage or parallelize task graph.
3. `dlq_rate > 0.05` => enter quarantine and stop auto-replay.
4. Backlog grows for 3 windows => raise `maxReplicaCount` or lower trigger threshold.
5. Before replay, verify idempotency key coverage is `100%` (`sagaId+stepId+attempt`).
