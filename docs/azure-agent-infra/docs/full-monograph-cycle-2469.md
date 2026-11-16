# Cycle #2469 核心工程专著：PostgreSQL 向量记忆拐点（zh-CN）

- Round/Cycle: `1064 / 2469`
- Topic: `postgres-pg-diskann-pgbouncer-rls-memory-search-crossover-faq-r1064`

## 1) 关键公式

```text
pool_size = ceil(active_sessions * avg_concurrent_tx_per_session / reuse_factor)
query_p95_ms = planner_ms + diskann_probe_ms + row_fetch_ms + rls_filter_ms
crossover = (pg_cost_per_1k <= search_cost_per_1k) and (pg_p95 <= search_p95 + tolerance)
```

阈值：
- `query_p95_ms <= 120`
- `blast_radius (RLS bypass risk) = 0`（目标）

## 2) Runnable snippets

### Bicep（PostgreSQL FS）

```bicep
resource pg 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: 'pg-agent-memory'
}
```

### SQL（RLS + diskann）

```sql
ALTER TABLE agent_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_memory USING (tenant_id = current_setting('app.tenant_id'));
CREATE INDEX idx_memory_diskann ON agent_memory USING diskann (embedding vector_cosine_ops);
```

### YAML（PgBouncer）

```yaml
pgbouncer: { pool_mode: transaction, default_pool_size: 120, reserve_pool_size: 40 }
```

### KQL（成本延迟拐点）

```kql
MemoryQueryBench
| where TimeGenerated > ago(30m)
| summarize pg_p95=percentile(PgLatencyMs,95), pg_cost=sum(PgCostUsd)/sum(Requests)*1000 by TenantRing
| where pg_p95 > 120
```

## 3) 失效模式

1. 连接池饱和导致事务排队。  
2. diskann 探测参数不当导致 p95 抖动。  
3. RLS 条件缺失引发跨租户可见性风险。  
4. 成本拐点漂移导致选型失真。

## 4) 落地清单

- PgBouncer 池配置按租户分层。  
- diskann 参数压测基线化。  
- RLS 策略与 `app.tenant_id` 强校验。  
- PostgreSQL vs AI Search 拐点按周复算。
