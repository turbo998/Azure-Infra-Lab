# Round 1059 / Cycle 2464 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure Managed Redis Enterprise semantic tool-cache + RediSearch HNSW episodic memory + atomic Lua token-bucket fencing**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2464-benchmark.json`

## 1) Executive Summary

This round targets sub-50ms realtime/voice agents by combining semantic cache retrieval and concurrency fencing in one atomic fast path.  
Key result: **semantic cache hit strategy + HNSW memory index tuning + Lua token-bucket fencing** is the practical production baseline.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2464-sources.json`)

## 3) Core formulas (hit / latency / concurrency)

### Q1: Semantic cache hit impact

```text
semantic_hit_rate = semantic_cache_hits / total_requests
effective_p95_ms = (hit_rate * hit_p95_ms) + ((1-hit_rate) * miss_p95_ms)
```

Realtime voice target: `effective_p95_ms <= 50`.

### Q2: HNSW sizing budget

```text
memory_overhead_bytes ~= vectors * (m * 8 + metadata_bytes)
query_latency_ms ~ O(efSearch * logN)
```

Starting point: `m=32`, `efSearch=64`; tune for recall and p95 together.

### Q3: Lua token-bucket fence

```text
tokens(t) = min(capacity, tokens(t-1) + refill_rate * delta_t) - cost
```

If `tokens < cost`, atomically deny to prevent sub-agent concurrency storms.

## 4) Runnable snippets (Bicep / YAML / Policy / KQL)

### 4.1 Bicep (Redis Enterprise)

```bicep
resource redis 'Microsoft.Cache/redisEnterprise@2024-10-01' = {
  name: 'redis-agent-rt'
  location: resourceGroup().location
  sku: { name: 'Enterprise_E10' }
}
```

### 4.2 YAML (semantic cache profile)

```yaml
semanticCache:
  topK: 8
  ttlSeconds: 180
  vectorIndex:
    algorithm: HNSW
    m: 32
    efSearch: 64
concurrencyFence:
  type: lua-token-bucket
  capacity: 400
  refillPerSec: 120
```

### 4.3 Policy JSON (tenant isolation)

```json
{
  "if": {
    "allOf": [
      { "field": "request.tenantId", "notEquals": "cache.tenantId" },
      { "field": "request.scope", "equals": "shared" }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL (hit-rate and fencing-deny triage)

```kql
RealtimeAgentLogs
| where TimeGenerated > ago(30m)
| summarize hit_rate = todouble(sum(CacheHit)) / count(),
            p95_latency = percentile(LatencyMs,95),
            fence_deny = countif(FenceDecision=="Deny")
            by TenantId, ModelClass
| where p95_latency > 50 or fence_deny > 100
| order by p95_latency desc, fence_deny desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2464-benchmark.json -> percentage_contract`):

- `unfenced_redis_semantic_cache_lua_fencing_guard_drift_rate = 534 / 4410 = 12.1%`
- `redis_semantic_cache_lua_fencing_guard_variance_rate = 216 / 4410 = 4.9%`
- `redis_semantic_cache_lua_fencing_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (realtime semantic-cache patterns)

| Pattern | Latency | Cost | Isolation | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| No cache direct-to-model | Low | High | Medium | Low | Low traffic |
| KV cache without semantic retrieval | Medium | Medium | Medium | Medium | Generic chat |
| Semantic cache + HNSW + Lua fence | **High** | **Medium-high** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `p95_latency_ms > 50`: inspect hit rate first, then miss path.
2. Fence deny spikes: verify refill settings and upstream retry storms.
3. Recall regression: raise `efSearch` and measure latency regression.
4. Cross-tenant hit: invalidate shard and rebuild index immediately.
5. Hot-key amplification: split tenant partitions and token buckets.
