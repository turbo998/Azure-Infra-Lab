# Round 1055 / Cycle 2460 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure AI Search hybrid retrieval (Vector+BM25+L2 Semantic Ranker) with Entra document-level ACL trimming**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2460-benchmark.json`

## 1) Executive Summary

This round moves multi-agent RAG from “works in staging” to “safe in production”: keep relevance, P95 latency, and zero ACL leakage at the same time.  
Key result: **partition/replica sizing math + HNSW latency budgeting + ACL trimming guardrail chain** is the minimum production baseline.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2460-sources.json`)

## 3) Core formulas (capacity / latency / security)

### Q1: Search partitions and replicas

```text
required_partitions = ceil(total_vectors / vectors_per_partition_target)
required_replicas   = ceil(target_qps / qps_per_replica_at_p95_target)
```

Starting point: `vectors_per_partition_target <= 8M`, and backfill `qps_per_replica_at_p95_target` from tests that include ACL filtering.

### Q2: HNSW params under latency budget

```text
latency_budget_ms = embed_ms + prefilter_ms + ann_ms(efSearch,m) + semantic_l2_ms + post_acl_ms
```

Practical band: `m=24~36`, `efSearch=40~96`. If `semantic_l2_ms` rises, lower `efSearch` first and observe Recall@K.

### Q3: ACL safety threshold

`acl_leak_rate = unauthorized_docs_returned / total_queries`

- Target: `acl_leak_rate = 0`
- If any window has `acl_leak_rate > 0`, immediately switch to strict prefilter + second-pass trimming.

## 4) Runnable snippets (Bicep / YAML / JSON / KQL)

### 4.1 Bicep (AI Search with replicas/partitions)

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

### 4.2 YAML (agent retrieval profile)

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

### 4.3 JSON (Entra ACL trimming policy)

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

### 4.4 KQL (P95 + ACL mismatch triage)

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

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (from `evidence/cycle-2460-benchmark.json -> percentage_contract`):

- `unfenced_aisearch_hybrid_vector_acl_guard_drift_rate = 534 / 4410 = 12.1%`
- `aisearch_hybrid_vector_acl_guard_variance_rate = 216 / 4410 = 4.9%`
- `aisearch_hybrid_vector_acl_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (multi-agent RAG patterns)

| Pattern | Relevance | Latency stability | ACL safety | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| BM25-only | Medium | High | Medium | Low | Small corpora |
| ANN-only vectors | High | Medium | Medium | Medium | Single-tenant exploration |
| Hybrid + L2 + Entra ACL trim | **High** | **High** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `p95_total_ms > 850`: inspect `p95_semantic` first, then tune `efSearch`.
2. `p95_ann_ms > 380`: scale replicas or lower `efSearch`; add partitions if needed.
3. `acl_mismatch > 0`: hard-block and fail over to strict prefilter-only.
4. topK hit-rate drop > 8%: rebalance `vectorWeight/bm25Weight`.
5. Hot shards for 3 windows: execute reindex + key-space resharding.
