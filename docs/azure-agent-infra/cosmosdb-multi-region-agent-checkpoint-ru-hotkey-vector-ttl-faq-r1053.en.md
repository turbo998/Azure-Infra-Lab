# Round 1053 / Cycle 2458 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Cosmos DB Multi-Region Durable Agent Checkpointing + RU Hot-Key Mitigation + Vector/Session TTL**
>
> Date (BJT): 2026-11-16  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2458-benchmark.json`

## 1) Executive Summary

This round focuses on a core engineering problem: how to keep agent session/checkpoint state in Cosmos DB multi-region with low recovery latency and bounded RU cost.  
Key result: multi-region writes + hot-key dispersion + layered TTL + split vector/session containers is the production baseline.

## 2) Daily capability breakthroughs radar (2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (captured in `evidence/cycle-2458-sources.json`)

## 3) Core sizing/latency formulas

### Q1: RU budget formula

`RU_total = (W_qps * RU_write + R_qps * RU_read + V_qps * RU_vector) * safety_factor`

Use `safety_factor = 1.25~1.5` for burst protection.

### Q2: Checkpoint restore p95 model

`T_restore_p95 ≈ T_query_p95 + T_deserialize + T_replay_delta + T_session_attach`

If `T_restore_p95 > 1200ms`, investigate hot partitions and cross-region read paths first.

### Q3: Hot-partition threshold

`hot_partition_ratio = RU_partition_max / RU_container_total`

- `> 0.18`: warning  
- `> 0.25`: critical (trigger repartition/hash-salt strategy)

## 4) Runnable snippets (Bicep / YAML / Policy / KQL)

### 4.1 Cosmos DB Bicep (multi-region + autoscale + TTL baseline)

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

### 4.2 ACA Job YAML (checkpoint compaction + TTL sweep)

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

### 4.3 Azure Policy (deny state containers without TTL)

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

### 4.4 KQL (hot partition + restore latency triage)

```kql
AgentCheckpointLogs
| where TimeGenerated > ago(30m)
| summarize p95_restore=percentile(RestoreMs,95), max_ru=max(RUCharge) by PartitionKeyHash, Region
| extend hot_ratio = todouble(max_ru) / 10000.0
| where p95_restore > 1200 or hot_ratio > 0.25
| order by p95_restore desc
```

## 5) Decision matrix (checkpoint architecture)

| Option | Restore speed | Cost | Consistency governance | Recommendation |
|---|---:|---:|---:|---|
| Single-region single-container | Medium | Low | Low | PoC only |
| Multi-region single-container | Mid-high | Medium | Medium | Transitional |
| Multi-region split containers + layered TTL + hot-key controls | **High** | **Medium-high but bounded** | **High** | **Production default** |

## 6) Production failure-triage checklist

1. **Restore first**: alert on `p95_restore_ms > 1200`.  
2. **Hot key next**: `hot_partition_ratio > 0.25` triggers repartition mitigation.  
3. **RU saturation**: `normalizedRUConsumption > 0.85` for 5+ minutes => autoscale step-up.  
4. **TTL backlog**: expired-item cleanup lag > 15 minutes => run sweep job.  
5. **Region skew**: read-latency spread > 2x => reroute read preference and verify index/consistency policy.  
