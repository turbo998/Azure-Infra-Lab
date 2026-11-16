# Round 1055 / Cycle 2460 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure AI Search 混合检索（Vector+BM25+L2 Semantic Ranker）与 Entra 文档级 ACL 安全裁剪**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2460-benchmark.json`

## 1) Executive Summary

本轮目标是把多 Agent RAG 从“可用”推进到“可上线”：在 Azure AI Search 里同时保证检索相关性、P95 延迟和 ACL 零越权。  
核心结论：**分区/副本容量公式 + HNSW 参数预算 + ACL 安全裁剪三段式网关** 是生产最低配置。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2460-sources.json`）

## 3) 核心公式（容量 / 延迟 / 安全）

### Q1: AI Search 分区与副本怎么估算？

```text
required_partitions = ceil(total_vectors / vectors_per_partition_target)
required_replicas   = ceil(target_qps / qps_per_replica_at_p95_target)
```

建议起点：`vectors_per_partition_target <= 8M`，`qps_per_replica_at_p95_target` 以压测结果（含 ACL 过滤）回填。

### Q2: HNSW 参数与延迟预算如何耦合？

```text
latency_budget_ms = embed_ms + prefilter_ms + ann_ms(efSearch,m) + semantic_l2_ms + post_acl_ms
```

实操建议：`m=24~36`，`efSearch=40~96`。当 `semantic_l2_ms` 抬升时优先降 `efSearch` 再观察 Recall@K。

### Q3: ACL 裁剪的安全阈值？

`acl_leak_rate = unauthorized_docs_returned / total_queries`

- 目标：`acl_leak_rate = 0`
- 若任意窗口 `acl_leak_rate > 0`：立即降级到“严格 prefilter + 结果集二次裁剪”模式

## 4) Runnable snippets（Bicep / YAML / JSON / KQL）

### 4.1 Bicep（AI Search + 副本分区）

```bicep
resource search 'Microsoft.Search/searchServices@2025-05-01' = {
  name: 'aisearch-prod-rag'
  location: resourceGroup().location
  sku: { name: 'standard' }
  properties: {
    replicaCount: 4
    partitionCount: 3
    semanticSearch: 'standard'
    publicNetworkAccess: 'enabled'
  }
}
```

### 4.2 YAML（Agent 检索参数）

```yaml
retrieval:
  hybrid:
    topK: 20
    vectorWeight: 0.65
    bm25Weight: 0.35
  hnsw:
    m: 32
    efSearch: 72
  semantic:
    ranker: "L2"
  security:
    aclMode: "entra_doc_filter+post_filter"
```

### 4.3 JSON（Entra 文档 ACL 裁剪策略）

```json
{
  "version": "2026-11-17",
  "policy": {
    "requireTenantMatch": true,
    "requiredClaims": ["tid", "oid", "groups"],
    "documentFilter": "doc.allowedGroups intersects principal.groups",
    "denyOnMissingAcl": true
  }
}
```

### 4.4 KQL（P95 + ACL 失配排障）

```kql
AgentRagLogs
| where TimeGenerated > ago(30m)
| summarize p95_total=percentile(TotalLatencyMs,95),
            p95_ann=percentile(AnnLatencyMs,95),
            p95_semantic=percentile(SemanticLatencyMs,95),
            acl_mismatch=countif(AclDecision=="DenyButReturned")
            by IndexName, TenantId
| where p95_total > 850 or acl_mismatch > 0
| order by acl_mismatch desc, p95_total desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（见 `evidence/cycle-2460-benchmark.json -> percentage_contract`）：

- `unfenced_aisearch_hybrid_vector_acl_guard_drift_rate = 534 / 4410 = 12.1%`
- `aisearch_hybrid_vector_acl_guard_variance_rate = 216 / 4410 = 4.9%`
- `aisearch_hybrid_vector_acl_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算公式：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（多 Agent RAG 选型）

| 方案 | 相关性 | 延迟稳定性 | ACL 安全性 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 纯 BM25 | 中 | 高 | 中 | 低 | 小知识库 |
| 纯向量 ANN | 高 | 中 | 中 | 中 | 单租户探索 |
| Hybrid + L2 + Entra ACL Trim | **高** | **高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `p95_total_ms > 850`：先看 `p95_semantic`，再调 `efSearch`。  
2. `p95_ann_ms > 380`：扩 replica 或降 `efSearch`；必要时增 partition。  
3. `acl_mismatch > 0`：立即阻断并回退到严格 prefilter-only。  
4. topK 命中率下降 > 8%：重新平衡 `vectorWeight/bm25Weight`。  
5. 三个窗口连续热点分片：执行 reindex + key space 重新散列。
