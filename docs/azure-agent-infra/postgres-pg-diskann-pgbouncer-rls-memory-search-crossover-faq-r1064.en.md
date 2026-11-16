# Round 1064 / Cycle 2469 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure PostgreSQL Flexible Server `pg_diskann` + PgBouncer transaction pooling + RLS tenant memory vs Azure AI Search crossover**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2469-benchmark.json`

## 1) Executive Summary

This round evaluates the crossover point between in-database vector memory and external search services across latency, cost, and tenant isolation.  
Key result: **pg_diskann retrieval budget + PgBouncer stabilization + strict RLS boundaries** forms the viable PostgreSQL path.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2469-sources.json`)

## 3) Core formulas (pooling / retrieval / cost crossover)

### Q1: PgBouncer pool sizing

```text
pool_size = ceil(active_sessions * avg_concurrent_tx_per_session / reuse_factor)
server_conn_target = pool_size * safety_factor
```

Recommended `safety_factor=1.2~1.4`.

### Q2: pg_diskann retrieval budget

```text
query_p95_ms = planner_ms + diskann_probe_ms + row_fetch_ms + rls_filter_ms
```

Target: `query_p95_ms <= 120` including RLS filtering.

### Q3: Search cost/latency crossover

```text
crossover = when(pg_cost_per_1k <= search_cost_per_1k) and (pg_p95 <= search_p95 + tolerance)
```

Typical `tolerance=15ms`.

## 4) Runnable snippets (Bicep / SQL / YAML / KQL)

### 4.1 Bicep (PostgreSQL FS)

```bicep
resource pg 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: 'pg-agent-memory'
  location: resourceGroup().location
  sku: { name: 'Standard_D8s_v5', tier: 'GeneralPurpose' }
}
```

### 4.2 SQL (RLS + vector index)

```sql
ALTER TABLE agent_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_memory
USING (tenant_id = current_setting('app.tenant_id'));
CREATE INDEX idx_memory_diskann ON agent_memory USING diskann (embedding vector_cosine_ops);
```

### 4.3 YAML (PgBouncer transaction pooling)

```yaml
pgbouncer:
  pool_mode: transaction
  default_pool_size: 120
  reserve_pool_size: 40
```

### 4.4 KQL (cost/latency crossover triage)

```kql
MemoryQueryBench
| where TimeGenerated > ago(30m)
| summarize pg_p95=percentile(PgLatencyMs,95),
            search_p95=percentile(SearchLatencyMs,95),
            pg_cost=sum(PgCostUsd)/sum(Requests)*1000,
            search_cost=sum(SearchCostUsd)/sum(Requests)*1000
            by TenantRing
| where pg_p95 > 120 or pg_cost > search_cost
| order by pg_cost desc, pg_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2469-benchmark.json -> percentage_contract`):

- `unfenced_postgres_diskann_rls_crossover_guard_drift_rate = 534 / 4410 = 12.1%`
- `postgres_diskann_rls_crossover_guard_variance_rate = 216 / 4410 = 4.9%`
- `postgres_diskann_rls_crossover_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (database-memory patterns)

| Pattern | Latency | Cost | Isolation | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| External search only | Medium | Medium-high | High | Medium | General default |
| PostgreSQL without pooling/RLS | Medium | Medium | Low | Low | Not for production |
| PostgreSQL + pg_diskann + PgBouncer + RLS | **High** | **Medium-high** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. Rising connection queue: tune `default_pool_size` and `reserve_pool_size`.
2. `pg_p95` exceeds 120ms: inspect `diskann_probe_ms` and `rls_filter_ms`.
3. Cost above search baseline: trigger hybrid-routing fallback.
4. RLS leakage risk: verify `app.tenant_id` propagation.
5. Metric drift: recompute crossover by tenant ring.
