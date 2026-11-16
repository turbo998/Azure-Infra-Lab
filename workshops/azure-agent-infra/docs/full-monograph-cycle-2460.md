# Cycle #2460 核心工程专著：Azure AI Search Hybrid RAG + ACL Trim（zh-CN）

- Round/Cycle: `1055 / 2460`
- Topic: `aisearch-hybrid-vector-bm25-l2-semantic-acl-trimming-faq-r1055`

## 1) 生产容量与延迟公式

```text
required_partitions = ceil(total_vectors / vectors_per_partition_target)
required_replicas   = ceil(target_qps / qps_per_replica_at_p95_target)
latency_budget_ms   = embed_ms + prefilter_ms + ann_ms(efSearch,m) + semantic_l2_ms + post_acl_ms
```

阈值建议：
- `p95_total_ms <= 850`
- `p95_ann_ms <= 380`
- `acl_mismatch_count == 0`

## 2) Runnable snippets

### Bicep（Search 容量）

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

### YAML（Hybrid + HNSW）

```yaml
retrieval:
  hybrid: { vectorWeight: 0.65, bm25Weight: 0.35, topK: 20 }
  hnsw: { m: 32, efSearch: 72 }
  semantic: { ranker: L2 }
```

### Policy JSON（Entra 文档 ACL）

```json
{
  "requiredClaims": ["tid", "oid", "groups"],
  "documentFilter": "doc.allowedGroups intersects principal.groups",
  "denyOnMissingAcl": true
}
```

### KQL（多租户排障）

```kql
AgentRagLogs
| where TimeGenerated > ago(30m)
| summarize p95_total=percentile(TotalLatencyMs,95),
            p95_ann=percentile(AnnLatencyMs,95),
            acl_mismatch=countif(AclDecision=="DenyButReturned")
            by TenantId, IndexName
| where p95_total > 850 or p95_ann > 380 or acl_mismatch > 0
```

## 3) 失效模式与 runbook

1. **语义重排拖慢 P95**：先降 `efSearch`，再调 `topK` 与 `vectorWeight`。  
2. **分片热点**：执行 reindex + 分桶重分布，避免单分区过载。  
3. **ACL 越权命中**：立即切换 prefilter-only，冻结跨租户缓存。  
4. **召回率下滑**：分离“索引更新滞后”与“参数漂移”两个路径排查。

## 4) 决策与落地清单

- **Good fit**：多租户企业知识库、合规审计可追溯问答、Agent 协作检索。  
- **Not for**：无 ACL 元数据、未定义租户边界、缺乏索引生命周期管理。  
- 五步落地：数据建模 → ACL 标注 → 容量压测 → 灰度路由 → 持续 KQL 审计。
