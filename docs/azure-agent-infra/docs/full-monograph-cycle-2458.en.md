# Cycle #2458 Core Engineering Monograph: Cosmos DB Multi-Region Agent Checkpointing (en)

- Round/Cycle: `1053 / 2458`
- Topic: `cosmosdb-multi-region-agent-checkpoint-ru-hotkey-vector-ttl-faq-r1053`
- Focus: durable checkpoints, RU hot-key mitigation, vector/session TTL, cross-region restore

## 1. Sizing formulas and baseline thresholds

```text
RU_total = (W_qps*RUw + R_qps*RUr + V_qps*RUv) * 1.3
T_restore_p95 = T_query_p95 + T_deserialize + T_replay_delta + T_attach
hot_partition_ratio = RU_partition_max / RU_container_total
```

Recommended thresholds:
- `T_restore_p95 <= 1200ms`
- `hot_partition_ratio <= 0.18` warning, `<= 0.25` hard limit
- `normalizedRUConsumption <= 0.85` over 5-minute window

## 2. Multi-region durable checkpoint design

1. Split session-state and vector-state containers.
2. Use salted hash partition keys for checkpoint documents.
3. Keep Session consistency default; enforce idempotency token on critical writes.
4. Layered TTL: short for sessions, medium for checkpoints, long for vectors.

## 3. Runnable configuration snippets

### 3.1 Bicep (multi-region account)

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

### 3.2 KQL (triage query)

```kql
AgentCheckpointLogs
| where TimeGenerated > ago(30m)
| summarize p95_restore=percentile(RestoreMs,95), max_ru=max(RUCharge) by PartitionKeyHash, Region
| extend hot_ratio=todouble(max_ru)/10000.0
| where p95_restore > 1200 or hot_ratio > 0.25
```

## 4. Failure modes and mitigations

- **RU hot partitions**: partition on `tenantId + hash(sessionId)` with write-salt strategy.
- **Cross-region restore drift**: prioritize local reads; isolate vector index policy tuning.
- **TTL cleanup backlog**: run sweeper every 10 minutes; alert when backlog > 15 minutes.
- **Duplicate replay**: idempotency key `sessionId+stepId+version`.

## 5. Production checklist (high-rigor)

1. RU dashboard includes `95p`, `99p`, and per-partition maxima.
2. Restore path has baseline load tests and replay packs.
3. Failover drill runs at least weekly.
4. Policy/version drift has automatic hard blocks.
5. Appeal/audit exports provide full end-to-end trace.
