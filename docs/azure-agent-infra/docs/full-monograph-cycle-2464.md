# Cycle #2464 核心工程专著：Redis 语义缓存与并发围栏（zh-CN）

- Round/Cycle: `1059 / 2464`
- Topic: `azure-managed-redis-enterprise-semantic-cache-hnsw-lua-fencing-faq-r1059`

## 1) 关键公式

```text
semantic_hit_rate = semantic_cache_hits / total_requests
effective_p95_ms = hit_rate*hit_p95_ms + (1-hit_rate)*miss_p95_ms
tokens(t) = min(capacity, tokens(t-1)+refill_rate*delta_t)-cost
```

阈值：
- `effective_p95_ms <= 50`
- `fence_deny_rate <= 3%`（峰值窗口）

## 2) Runnable snippets

### Bicep（Redis Enterprise）

```bicep
resource redis 'Microsoft.Cache/redisEnterprise@2024-10-01' = {
  name: 'redis-agent-rt'
  sku: { name: 'Enterprise_E10' }
}
```

### YAML（HNSW + Lua 围栏）

```yaml
vectorIndex: { algorithm: HNSW, m: 32, efSearch: 64 }
concurrencyFence: { type: lua-token-bucket, capacity: 400, refillPerSec: 120 }
```

### Policy（租户隔离）

```json
{
  "if": { "field": "request.tenantId", "notEquals": "cache.tenantId" },
  "then": { "effect": "deny" }
}
```

### KQL（延迟与拒绝排障）

```kql
RealtimeAgentLogs
| where TimeGenerated > ago(30m)
| summarize p95=percentile(LatencyMs,95), deny=countif(FenceDecision=="Deny") by TenantId
| where p95 > 50 or deny > 100
```

## 3) 失效模式

1. 命中率下滑导致延迟突增。  
2. Lua 围栏配置过严触发大面积拒绝。  
3. HNSW 参数偏保守导致 recall 回退。  
4. 热 key 与租户偏斜造成分片放大。

## 4) 落地清单

- 语义缓存与主模型请求链路解耦。  
- Lua 围栏参数按租户分级。  
- HNSW 参数按业务类目基线化。  
- KQL 看板按 tenant/modelclass 双维度巡检。
