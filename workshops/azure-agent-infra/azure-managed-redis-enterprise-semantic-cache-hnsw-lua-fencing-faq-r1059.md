# Round 1059 / Cycle 2464 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure Managed Redis Enterprise 语义工具缓存 + RediSearch HNSW Episodic Memory + Lua 原子并发围栏**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2464-benchmark.json`

## 1) Executive Summary

本轮目标是面向亚 50ms 实时/语音 Agent，把语义检索缓存与并发节流放到同一原子路径。  
核心结论：**语义缓存命中策略 + HNSW 记忆索引参数 + Lua token-bucket 围栏** 三者缺一不可。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2464-sources.json`）

## 3) 核心公式（命中 / 延迟 / 并发）

### Q1: 语义缓存命中率

```text
semantic_hit_rate = semantic_cache_hits / total_requests
effective_p95_ms = (hit_rate * hit_p95_ms) + ((1-hit_rate) * miss_p95_ms)
```

实时语音建议：`effective_p95_ms <= 50`。

### Q2: HNSW 参数预算

```text
memory_overhead_bytes ~= vectors * (m * 8 + metadata_bytes)
query_latency_ms ~ O(efSearch * logN)
```

建议初值：`m=32`, `efSearch=64`，按 recall 与 p95 双目标调优。

### Q3: Lua token-bucket 围栏

```text
tokens(t) = min(capacity, tokens(t-1) + refill_rate * delta_t) - cost
```

当 `tokens < cost` 时原子拒绝，防止子 Agent 并发风暴。

## 4) Runnable snippets（Bicep / YAML / Policy / KQL）

### 4.1 Bicep（Redis Enterprise）

```bicep
resource redis 'Microsoft.Cache/redisEnterprise@2024-10-01' = {
  name: 'redis-agent-rt'
  location: resourceGroup().location
  sku: { name: 'Enterprise_E10' }
}
```

### 4.2 YAML（缓存层配置）

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

### 4.3 Policy JSON（租户隔离）

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

### 4.4 KQL（命中率与并发拒绝排障）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2464-benchmark.json -> percentage_contract`）：

- `unfenced_redis_semantic_cache_lua_fencing_guard_drift_rate = 534 / 4410 = 12.1%`
- `redis_semantic_cache_lua_fencing_guard_variance_rate = 216 / 4410 = 4.9%`
- `redis_semantic_cache_lua_fencing_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（实时语义缓存方案）

| 方案 | 延迟 | 成本 | 隔离 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 无缓存直连模型 | 低 | 高 | 中 | 低 | 小流量 |
| KV 缓存无语义检索 | 中 | 中 | 中 | 中 | 通用问答 |
| 语义缓存 + HNSW + Lua 围栏 | **高** | **中高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `p95_latency_ms > 50`：先查命中率，再查 miss path。  
2. `fence_deny` 突增：核查 refill 参数与上游重试策略。  
3. recall 下滑：提高 `efSearch` 并评估延迟回归。  
4. 跨租户命中：立即失效该分片并重建索引。  
5. 热 key 放大：拆分 tenant 分区与并发令牌池。
