# Cycle #2469 Core Engineering Monograph: PostgreSQL Vector Memory Crossover (en)

- Round/Cycle: `1064 / 2469`
- Topic: `postgres-pg-diskann-pgbouncer-rls-memory-search-crossover-faq-r1064`

## 1) Core formulas

```text
pool_size = ceil(active_sessions * avg_concurrent_tx_per_session / reuse_factor)
query_p95_ms = planner_ms + diskann_probe_ms + row_fetch_ms + rls_filter_ms
crossover = (pg_cost_per_1k <= search_cost_per_1k) and (pg_p95 <= search_p95 + tolerance)
```

Thresholds:
- `query_p95_ms <= 120`
- `blast_radius (RLS bypass risk) = 0` (target)

## 2) Runnable snippets

### Bicep (PostgreSQL FS)

```bicep
resource pg 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: 'pg-agent-memory'
}
```

### SQL (RLS + diskann)

```sql
ALTER TABLE agent_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_memory USING (tenant_id = current_setting('app.tenant_id'));
CREATE INDEX idx_memory_diskann ON agent_memory USING diskann (embedding vector_cosine_ops);
```

### YAML (PgBouncer)

```yaml
pgbouncer: { pool_mode: transaction, default_pool_size: 120, reserve_pool_size: 40 }
```

### KQL (cost/latency crossover)

```kql
MemoryQueryBench
| where TimeGenerated > ago(30m)
| summarize pg_p95=percentile(PgLatencyMs,95), pg_cost=sum(PgCostUsd)/sum(Requests)*1000 by TenantRing
| where pg_p95 > 120
```

## 3) Failure modes

1. Pool saturation causes transaction queue buildup.
2. Poor diskann tuning creates p95 jitter.
3. Missing RLS conditions expose cross-tenant visibility.
4. Crossover drift misguides architecture choices.

## 4) Rollout checklist

- Tier PgBouncer pools by tenant classes.
- Baseline diskann parameters with load tests.
- Enforce RLS with strict `app.tenant_id` validation.
- Recompute PostgreSQL vs AI Search crossover weekly.
