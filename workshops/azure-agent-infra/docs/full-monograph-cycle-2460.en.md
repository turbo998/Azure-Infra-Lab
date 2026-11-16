# Cycle #2460 Core Engineering Monograph: Azure AI Search Hybrid RAG + ACL Trim (en)

- Round/Cycle: `1055 / 2460`
- Topic: `aisearch-hybrid-vector-bm25-l2-semantic-acl-trimming-faq-r1055`

## 1) Production sizing and latency formulas

```text
required_partitions = ceil(total_vectors / vectors_per_partition_target)
required_replicas   = ceil(target_qps / qps_per_replica_at_p95_target)
latency_budget_ms   = embed_ms + prefilter_ms + ann_ms(efSearch,m) + semantic_l2_ms + post_acl_ms
```

Threshold targets:
- `p95_total_ms <= 850`
- `p95_ann_ms <= 380`
- `acl_mismatch_count == 0`

## 2) Runnable snippets

### Bicep (search capacity)

```bicep
resource search 'Microsoft.Search/searchServices@2025-05-01' = {
  name: 'aisearch-prod-rag'
  sku: { name: 'standard' }
  properties: {
    replicaCount: 4
    partitionCount: 3
    semanticSearch: 'standard'
  }
}
```

### YAML (hybrid + HNSW)

```yaml
retrieval:
  hybrid: { vectorWeight: 0.65, bm25Weight: 0.35, topK: 20 }
  hnsw: { m: 32, efSearch: 72 }
  semantic: { ranker: L2 }
```

### Policy JSON (Entra document ACL)

```json
{
  "requiredClaims": ["tid", "oid", "groups"],
  "documentFilter": "doc.allowedGroups intersects principal.groups",
  "denyOnMissingAcl": true
}
```

### KQL (multi-tenant triage)

```kql
AgentRagLogs
| where TimeGenerated > ago(30m)
| summarize p95_total=percentile(TotalLatencyMs,95),
            p95_ann=percentile(AnnLatencyMs,95),
            acl_mismatch=countif(AclDecision=="DenyButReturned")
            by TenantId, IndexName
| where p95_total > 850 or p95_ann > 380 or acl_mismatch > 0
```

## 3) Failure modes and runbook

1. **Semantic reranker inflates P95**: lower `efSearch` first, then tune `topK`/`vectorWeight`.
2. **Shard hot-spotting**: reindex with redistributed key space before scaling only replicas.
3. **ACL leakage hit**: switch to prefilter-only and freeze cross-tenant cache immediately.
4. **Recall drop**: separate “index freshness lag” from “retrieval parameter drift”.

## 4) Decision and rollout checklist

- **Good fit**: multi-tenant enterprise knowledge, auditable compliance Q&A, agent collaboration retrieval.
- **Not for**: missing ACL metadata, undefined tenant boundaries, no index lifecycle governance.
- 5-step rollout: data model -> ACL tagging -> load test -> gradual routing -> continuous KQL audit.
