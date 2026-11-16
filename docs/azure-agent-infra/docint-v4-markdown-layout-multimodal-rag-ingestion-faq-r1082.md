# Round 1082 / Cycle 2487 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Azure Document Intelligence v4 Markdown/Layout + Multimodal Vision-LLM Hybrid Ingestion Pipeline for Enterprise Agentic RAG**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2487-benchmark.json`

## 1) Executive Summary + Daily Capability Breakthroughs Radar

本轮聚焦企业 Agentic RAG 的 ingestion 主链路，解决三类常见失真：  
1) 复杂页面（表格/图形/多栏）抽取精度与成本失衡；  
2) 10k 级 PDF 批处理吞吐不足导致索引延迟；  
3) 表格/图像 bbox grounding 丢失导致检索错配。

核心结论：
- Document Intelligence v4 在结构化 layout 与 markdown 抽取上具备稳定基线；  
- 对复杂页需要引入 Vision-LLM 增强路由，不能全量走同一路径；  
- Claim-Check + ACA KEDA 并行切块是吞吐与成本平衡的关键。

### Daily Capability Breakthroughs Radar（抓取：2026-11-17）

1. APIM AI Gateway / Unified Model API（`measured`）  
   - https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
2. ACA Dynamic Sessions（`measured`）  
   - https://learn.microsoft.com/en-us/azure/container-apps/sessions  
3. Firecracker/Kata/Wasmtime/E2B 最新发布（`measured`）  
   - 见 `evidence/cycle-2487-sources.json`  
4. 企业文档结构化抽取中的多模态补偿策略（`anonymized_reported`）  
5. Claim-Check 解耦高并发队列与对象存储（`synthetic`）

### Mermaid #1：混合抽取与索引拓扑

```mermaid
flowchart LR
  subgraph Ingest[Ingestion Plane]
    BLOB[Blob Raw PDFs]
    Q[Queue: Claim-Check refs]
    ACA[ACA Workers + KEDA]
  end

  subgraph Parse[Parsing Plane]
    DI[Document Intelligence v4]
    VLM[Vision-LLM Router]
    LYT[Layout/BBox Normalizer]
  end

  subgraph Index[Index Plane]
    CH[Chunk Builder]
    VEC[Vector Index]
    META[Metadata Store]
  end

  BLOB --> Q
  Q --> ACA
  ACA --> DI
  ACA --> VLM
  DI --> LYT
  VLM --> LYT
  LYT --> CH
  CH --> VEC
  CH --> META
```

## 2) Deep Q&A #1：每 10k PDF 的 page-complexity 路由成本/准确率交叉点怎么算？

```text
total_pages = docs * avg_pages_per_doc

cost_total =
  simple_pages * cost_di_per_page +
  complex_pages * (cost_di_per_page + cost_vlm_per_page)

weighted_accuracy =
  (simple_pages * acc_di + complex_pages * acc_hybrid) / total_pages
```

Worked example：
- `docs=10,000`
- `avg_pages=18` => `total_pages=180,000`
- 复杂页比例：`22%` => complex=`39,600`, simple=`140,400`
- `cost_di=0.004 USD/page`
- `cost_vlm=0.013 USD/page`
- `acc_di=0.89`
- `acc_hybrid=0.96`

计算：
- `cost_total = 140,400*0.004 + 39,600*(0.017) = 1,234.8 USD`
- `weighted_accuracy = (140,400*0.89 + 39,600*0.96)/180,000 = 0.9054`

若全量都走 DI：
- 成本 `720 USD`，但复杂页精度下降导致最终检索准确率显著下滑。

## 3) Deep Q&A #2：复杂页判定阈值如何设置才能兼顾成本与精度？

```text
complexity_score =
  w1*table_density + w2*figure_density + w3*multi_column_ratio + w4*ocr_noise

route_to_vlm_if complexity_score >= threshold
```

Worked example：
- 阈值 0.55：VLM 路由比例 `18%`，准确率 `0.899`
- 阈值 0.45：VLM 路由比例 `24%`，准确率 `0.909`
- 阈值 0.35：VLM 路由比例 `33%`，准确率 `0.916`

成本对比（10k 文档）：
- 0.55：`1,080 USD`
- 0.45：`1,260 USD`
- 0.35：`1,640 USD`

推荐：
- 通常以 `0.45` 为生产起点，再基于业务 query 成功率做微调。

## 4) Deep Q&A #3：Blob Claim-Check + ACA KEDA 并行切块吞吐如何 sizing？

```text
required_workers =
  ceil((pages_per_min_target * avg_parse_ms_per_page) / 60_000)

keda_scale_target =
  queue_length / desired_messages_per_worker

throughput_pages_per_min =
  workers * (60_000 / avg_parse_ms_per_page)
```

Worked example：
- 目标：`45,000 pages/min`
- 平均 parse：`180 ms/page`

计算：
- `required_workers = ceil((45,000*180)/60,000)=135`

若每 worker 期望队列长度 40：
- 当 queue=8,000 时，`keda_target = 200 workers`

实际建议：
- min replicas 40，max replicas 260；  
- queue 触发阈值按分层（L1/L2/L3）动态调节。

## 5) Deep Q&A #4：表格/图像 bbox grounding 如何降低检索错位？

```text
grounding_recall =
  correctly_grounded_spans / total_spans

cross_modal_alignment_score =
  IoU_bbox * text_overlap_ratio * semantic_similarity
```

Worked example：
- total spans：`12,000`
- 正确 grounding：`10,980`
- `grounding_recall = 91.5%`

优化后（层次化表格索引 + figure caption 绑定）：
- 正确 grounding：`11,430`
- `recall = 95.25%`

收益：
- retrieval top-5 hit rate 提升约 `+4.2 pts`。  

## 6) Deep Q&A #5：索引延迟预算如何拆分？

```text
ingestion_e2e_p95 =
  upload_to_claimcheck_p95 +
  queue_wait_p95 +
  parse_p95 +
  chunk_embed_p95 +
  index_commit_p95
```

Worked example：
- upload：`280ms`
- queue：`1,150ms`
- parse：`1,980ms`
- chunk/embed：`1,430ms`
- commit：`760ms`

`ingestion_e2e_p95 = 5,600ms`

门禁目标：
- 常规知识库：`< 8,000ms`
- 高频交易/客服实时知识：`< 4,000ms`

## 7) Deep Q&A #6：混合抽取管线的 TCO 何时优于单一路径？

```text
monthly_tco =
  parse_cost + embedding_cost + compute_cost + storage_cost + incident_loss

value_gain =
  (retrieval_accuracy_gain * query_volume * value_per_success)
```

Worked example（USD/月）：
- A：DI-only：`26,400`
- B：VLM-only：`58,900`
- C：复杂页混合路由（推荐）：`34,700`
- D：全量多引擎冗余：`71,200`

在 query volume > `22M/month` 且 accuracy gain > `3 pts` 时，  
方案 C 通常有最优投入产出比。

## 8) Mermaid #2：幂等切块与回放控制流

```mermaid
sequenceDiagram
  participant U as Upload API
  participant B as Blob Claim-Check
  participant Q as Queue
  participant W as ACA Worker
  participant P as DI/VLM Parser
  participant I as Index Writer
  participant R as Replay Controller

  U->>B: put pdf blob + checksum
  U->>Q: enqueue claim-check pointer
  W->>Q: pull pointer
  W->>P: parse page/layout/markdown
  P-->>W: chunks + bbox + table graph
  W->>I: upsert chunks (idempotency key)
  alt index conflict or gap
    I-->>R: emit replay request
    R->>Q: requeue pointer with cursor
  else success
    I-->>W: ack committed
  end
```

## 9) 生产级 Bicep / YAML / Policy / KQL

### 9.1 Bicep（Blob + Queue + ACA + Event Hubs）

```bicep
param location string = 'eastus2'
param storageName string = 'stagentragdoc2487'
param acaEnvName string = 'aca-env-rag-ingest'
param appName string = 'aca-doc-ingestion-workers'
param ehNsName string = 'eh-rag-replay-2487'

resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: { name: 'Standard_ZRS' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

resource acaEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: acaEnvName
  location: location
}

resource acaApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: acaEnv.id
    configuration: {
      ingress: { external: false, targetPort: 8080 }
      registries: []
    }
    template: {
      containers: [
        {
          name: 'worker'
          image: 'ghcr.io/turbo998/doc-ingest-worker:stable'
          resources: { cpu: 2, memory: '4Gi' }
        }
      ]
      scale: {
        minReplicas: 40
        maxReplicas: 260
      }
    }
  }
}

resource ehNs 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: ehNsName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 6
  }
  properties: {
    isAutoInflateEnabled: true
    maximumThroughputUnits: 12
  }
}
```

### 9.2 YAML（ACA/KEDA 并行切块配置）

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: doc-ingest-scaledobject
  namespace: rag
spec:
  scaleTargetRef:
    name: doc-ingest-workers
  minReplicaCount: 40
  maxReplicaCount: 260
  pollingInterval: 5
  cooldownPeriod: 120
  triggers:
    - type: azure-queue
      metadata:
        queueName: pdf-claimcheck-queue
        queueLength: "40"
        connectionFromEnv: STORAGE_CONNECTION
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: doc-ingest-workers
  namespace: rag
spec:
  replicas: 40
  template:
    spec:
      containers:
        - name: worker
          image: ghcr.io/turbo998/doc-ingest-worker:stable
          env:
            - name: PARSE_MODE
              value: "docint_v4_markdown_layout_hybrid"
            - name: COMPLEXITY_THRESHOLD
              value: "0.45"
            - name: MAX_PAGES_PER_BATCH
              value: "120"
```

### 9.3 Policy（抽取精度与吞吐门禁）

```yaml
policy:
  name: multimodal-ingestion-gate
  thresholds:
    weightedAccuracyMin: 0.90
    groundingRecallMin: 0.94
    ingestionE2EP95MaxMs: 8000
    replayGapMax: 200
  if:
    - any:
      - metric: weightedAccuracy
        op: "<"
        value: 0.90
      - metric: groundingRecall
        op: "<"
        value: 0.94
      - metric: ingestionE2EP95Ms
        op: ">"
        value: 8000
      - metric: replayGap
        op: ">"
        value: 200
  then:
    effect: hold_index_promotion_and_replay
  else:
    effect: continue_promotion
```

### 9.4 KQL（复杂度路由与回放监控）

```kql
RagIngestionMetrics
| where TimeGenerated > ago(30m)
| summarize
    weighted_acc = avg(WeightedAccuracy),
    grounding_recall = avg(GroundingRecall),
    e2e_p95 = percentile(IngestionE2ELatencyMs, 95),
    replay_gap_p95 = percentile(ReplayGap, 95),
    pages_per_min = avg(PagesPerMinute)
  by Region, PipelineVersion, bin(TimeGenerated, 5m)
| extend GateStatus =
    case(
      weighted_acc < 0.90 or grounding_recall < 0.94 or e2e_p95 > 8000 or replay_gap_p95 > 200,
      "BLOCK",
      "PASS")
| order by TimeGenerated desc
```

## 10) 决策矩阵（4 方案量化）

| 方案 | 精度(35%) | 吞吐(25%) | 成本(20%) | 运维复杂度(20%) | 综合分 |
|---|---:|---:|---:|---:|---:|
| A DI-only | 72 | 86 | 90 | 84 | 81.0 |
| B VLM-only | 92 | 64 | 51 | 61 | 70.4 |
| C 混合复杂度路由（推荐） | 89 | 88 | 76 | 72 | **83.0** |
| D 全量冗余多引擎 | 94 | 79 | 42 | 45 | 68.4 |

## 11) Day-0 / Day-2 Checklist（Good fit vs Not for）

### Day-0
- [ ] 定义 page complexity score 与路由阈值  
- [ ] 实现 Claim-Check 指针协议与幂等键  
- [ ] 部署 ACA/KEDA 并行切块 worker  
- [ ] 建立 bbox/table/figure grounding 归一化规范  
- [ ] 接入门禁指标与自动回放控制  
- [ ] 完成 5% 文档集 canary 演练

### Day-2
- [ ] 每周抽样校准复杂度路由阈值  
- [ ] 复盘 replay gap 与重复写入冲突  
- [ ] 优化 OCR 噪声页面的 VLM 补偿策略  
- [ ] 跟踪 pages/min 与 unit cost 漂移  
- [ ] 清理陈旧 chunk 与失效 bbox 索引

### Good fit
- 企业级多格式文档库（复杂表格/图像多）  
- 对检索准确率和时效都有约束的 Agentic RAG  
- 需要可观测、可回放、可门禁的 ingestion 平台

### Not for
- 文档结构单一且低复杂度的小规模知识库  
- 无法维护多模态补偿与回放链路的团队  
- 对抽取精度无硬要求的临时演示环境

## 12) 五步落地指南

1. **基线抽取**：先跑 DI v4 markdown/layout，建立准确率基线。  
2. **复杂度路由**：引入 VLM 仅处理复杂页，控制成本上限。  
3. **并行切块**：通过 Claim-Check + KEDA 放大吞吐。  
4. **grounding 归一**：统一 bbox/table/figure 引用关系。  
5. **门禁与回放**：把精度、吞吐、回放缺口做成发布硬门槛。

## 13) 业务场景映射

- **Coding Agent Sandbox**：代码文档与 runbook 的快速结构化检索。  
- **Browser/CUA 集群**：UI 测试报告与截图文档的跨模态检索。  
- **多租户 SaaS Agent Gateway**：租户级文档解析预算和配额治理。  
- **金融零信任执行环境**：合同/审计材料的可追溯结构化抽取。

## 14) 关键来源（官方优先）

- APIM AI Gateway Overview: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
- ACA Sessions: https://learn.microsoft.com/en-us/azure/container-apps/sessions  
- APIM Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md  
- Firecracker Releases: https://github.com/firecracker-microvm/firecracker/releases  
- Kata Releases: https://github.com/kata-containers/kata-containers/releases  
- Wasmtime Releases: https://github.com/bytecodealliance/wasmtime/releases  
- E2B Releases: https://github.com/e2b-dev/e2b/releases

## 15) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`：
- `unfenced_apim_mcp_tool_budget_burst_cap_drift_rate = 534 / 4410 = 12.1%`
- `apim_mcp_tool_budget_burst_cap_variance_rate = 216 / 4410 = 4.9%`
- `apim_mcp_tool_budget_burst_cap_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
gain_pts = round((numerator / denominator) * 100, 1)
```

说明：
- 比率用于 pipeline 合约一致性校验；  
- 生产值应替换为真实租户分层观测数据；  
- 保留 `measured/synthetic/anonymized_reported` 标签用于审计追溯。
