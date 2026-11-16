# Cycle #2464 Core Engineering Monograph: Redis Semantic Cache + Concurrency Fence (en)

- Round/Cycle: `1059 / 2464`
- Topic: `azure-managed-redis-enterprise-semantic-cache-hnsw-lua-fencing-faq-r1059`

## 1) Core formulas

```text
semantic_hit_rate = semantic_cache_hits / total_requests
effective_p95_ms = hit_rate*hit_p95_ms + (1-hit_rate)*miss_p95_ms
tokens(t) = min(capacity, tokens(t-1)+refill_rate*delta_t)-cost
```

Thresholds:
- `effective_p95_ms <= 50`
- `fence_deny_rate <= 3%` (peak windows)

## 2) Runnable snippets

### Bicep (Redis Enterprise)

```bicep
resource redis 'Microsoft.Cache/redisEnterprise@2024-10-01' = {
  name: 'redis-agent-rt'
  sku: { name: 'Enterprise_E10' }
}
```

### YAML (HNSW + Lua fence)

```yaml
vectorIndex: { algorithm: HNSW, m: 32, efSearch: 64 }
concurrencyFence: { type: lua-token-bucket, capacity: 400, refillPerSec: 120 }
```

### Policy (tenant isolation)

```json
{
  "if": { "field": "request.tenantId", "notEquals": "cache.tenantId" },
  "then": { "effect": "deny" }
}
```

### KQL (latency/deny triage)

```kql
RealtimeAgentLogs
| where TimeGenerated > ago(30m)
| summarize p95=percentile(LatencyMs,95), deny=countif(FenceDecision=="Deny") by TenantId
| where p95 > 50 or deny > 100
```

## 3) Failure modes

1. Hit-rate drop drives latency surge.
2. Over-strict Lua fence causes broad denial.
3. Conservative HNSW tuning regresses recall.
4. Hot keys and tenant skew amplify shard pressure.

## 4) Rollout checklist

- Decouple semantic cache path from base model path.
- Tune Lua fence per tenant tier.
- Baseline HNSW params per workload class.
- Operate KQL dashboards by tenant/model-class dimensions.
