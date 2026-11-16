# Round 1064 / Cycle 2469 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure PostgreSQL Flexible Server `pg_diskann` + PgBouncer transaction pooling + RLS 多租户记忆，与 Azure AI Search 成本/延迟拐点**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2469-benchmark.json`

## 1) Executive Summary

本轮关注“数据库内嵌向量记忆 vs 独立搜索服务”的工程拐点：成本、延迟、隔离三者平衡。  
核心结论：**pg_diskann 检索预算 + PgBouncer 连接稳定器 + RLS 租户边界** 是 PostgreSQL 侧可行路径。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2469-sources.json`）

## 3) 核心公式（连接 / 检索 / 成本拐点）

### Q1: PgBouncer 连接池容量

```text
pool_size = ceil(active_sessions * avg_concurrent_tx_per_session / reuse_factor)
server_conn_target = pool_size * safety_factor
```

建议 `safety_factor=1.2~1.4`，防止尖峰排队。

### Q2: pg_diskann 检索预算

```text
query_p95_ms = planner_ms + diskann_probe_ms + row_fetch_ms + rls_filter_ms
```

目标：`query_p95_ms <= 120`（含 RLS 过滤）。

### Q3: Search 成本/延迟拐点

```text
crossover = when(pg_cost_per_1k <= search_cost_per_1k) and (pg_p95 <= search_p95 + tolerance)
```

典型 `tolerance=15ms`。

## 4) Runnable snippets（Bicep / SQL / YAML / KQL）

### 4.1 Bicep（PostgreSQL FS）

```bicep
resource pg 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: 'pg-agent-memory'
  location: resourceGroup().location
  sku: { name: 'Standard_D8s_v5', tier: 'GeneralPurpose' }
}
```

### 4.2 SQL（RLS + 向量索引）

```sql
ALTER TABLE agent_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_memory
USING (tenant_id = current_setting('app.tenant_id'));
CREATE INDEX idx_memory_diskann ON agent_memory USING diskann (embedding vector_cosine_ops);
```

### 4.3 YAML（PgBouncer transaction pooling）

```yaml
pgbouncer:
  pool_mode: transaction
  default_pool_size: 120
  reserve_pool_size: 40
```

### 4.4 KQL（成本与延迟对比）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2469-benchmark.json -> percentage_contract`）：

- `unfenced_postgres_diskann_rls_crossover_guard_drift_rate = 534 / 4410 = 12.1%`
- `postgres_diskann_rls_crossover_guard_variance_rate = 216 / 4410 = 4.9%`
- `postgres_diskann_rls_crossover_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（数据库记忆选型）

| 策略 | 延迟 | 成本 | 隔离 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 全量依赖外部搜索 | 中 | 中高 | 高 | 中 | 通用方案 |
| PostgreSQL + 无 pooling/RLS | 中 | 中 | 低 | 低 | 不推荐生产 |
| PostgreSQL + pg_diskann + PgBouncer + RLS | **高** | **中高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. 连接排队上升：调大 `default_pool_size` 与 `reserve_pool_size`。  
2. `pg_p95` 超 120ms：先看 `diskann_probe_ms` 与 `rls_filter_ms`。  
3. 成本反超搜索：触发混合路由回切策略。  
4. RLS 漏洞风险：校验 `app.tenant_id` 注入路径。  
5. 统计漂移：按 tenant ring 分层基准重算拐点。
