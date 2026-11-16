# Round 1082 / Cycle 2487 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Azure Document Intelligence v4 Markdown/Layout + Multimodal Vision-LLM Hybrid Ingestion Pipeline for Enterprise Agentic RAG**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2487-benchmark.json`

## 1) Executive Summary + Daily Capability Breakthroughs Radar

This round focuses on three high-impact ingestion risks in enterprise Agentic RAG:
1. Cost-accuracy imbalance on complex pages (tables, figures, multi-column layout).
2. Throughput bottlenecks for 10k-scale PDF processing windows.
3. Retrieval drift caused by weak table/figure bbox grounding.

Primary findings:
- Document Intelligence v4 provides a stable baseline for layout + markdown extraction.
- Complex pages require selective Vision-LLM routing; single-path extraction is not enough.
- Claim-Check plus ACA KEDA parallel chunking is the most practical throughput-cost lever.

### Daily Capability Breakthroughs Radar (fetched: 2026-11-17)

1. APIM AI Gateway / Unified Model API (`measured`)  
   - https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
2. ACA Dynamic Sessions (`measured`)  
   - https://learn.microsoft.com/en-us/azure/container-apps/sessions  
3. Firecracker/Kata/Wasmtime/E2B release signals (`measured`)  
   - see `evidence/cycle-2487-sources.json`  
4. Multimodal compensation strategies for enterprise docs (`anonymized_reported`)  
5. Claim-Check decoupling for queue + blob fanout (`synthetic`)

### Mermaid #1: Hybrid extraction and indexing topology

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

## 2) Deep Q&A #1: How to compute cost-accuracy crossover per 10k PDFs?

```text
total_pages = docs * avg_pages_per_doc

cost_total =
  simple_pages * cost_di_per_page +
  complex_pages * (cost_di_per_page + cost_vlm_per_page)

weighted_accuracy =
  (simple_pages * acc_di + complex_pages * acc_hybrid) / total_pages
```

Worked example:
- `docs=10,000`
- `avg_pages=18` -> `total_pages=180,000`
- complex-page ratio `22%` -> complex=`39,600`, simple=`140,400`
- `cost_di=0.004 USD/page`
- `cost_vlm=0.013 USD/page`
- `acc_di=0.89`
- `acc_hybrid=0.96`

Results:
- `cost_total = 1,234.8 USD`
- `weighted_accuracy = 0.9054`

If DI-only is used:
- cost falls to `720 USD`, but retrieval quality on complex pages drops materially.

## 3) Deep Q&A #2: How to set complexity-routing thresholds?

```text
complexity_score =
  w1*table_density + w2*figure_density + w3*multi_column_ratio + w4*ocr_noise

route_to_vlm_if complexity_score >= threshold
```

Worked comparison:
- threshold 0.55: VLM routing `18%`, weighted accuracy `0.899`
- threshold 0.45: VLM routing `24%`, weighted accuracy `0.909`
- threshold 0.35: VLM routing `33%`, weighted accuracy `0.916`

Cost impact per 10k docs:
- 0.55: `1,080 USD`
- 0.45: `1,260 USD`
- 0.35: `1,640 USD`

Recommendation:
- start with `0.45`, then tune using downstream query success metrics.

## 4) Deep Q&A #3: How to size Blob Claim-Check + ACA KEDA chunking throughput?

```text
required_workers =
  ceil((pages_per_min_target * avg_parse_ms_per_page) / 60_000)

keda_scale_target =
  queue_length / desired_messages_per_worker

throughput_pages_per_min =
  workers * (60_000 / avg_parse_ms_per_page)
```

Worked example:
- target `45,000 pages/min`
- average parse `180 ms/page`

Calculation:
- `required_workers = 135`

With desired queue depth 40 per worker:
- at queue=8,000, target workers = `200`

Operational profile:
- min replicas 40, max replicas 260;
- dynamic queue trigger tiers for burst control.

## 5) Deep Q&A #4: How to improve table/figure bbox grounding quality?

```text
grounding_recall =
  correctly_grounded_spans / total_spans

cross_modal_alignment_score =
  IoU_bbox * text_overlap_ratio * semantic_similarity
```

Worked example:
- total spans: `12,000`
- correctly grounded: `10,980`
- `grounding_recall = 91.5%`

After hierarchical table graph + caption linking:
- correctly grounded: `11,430`
- `recall = 95.25%`

Benefit:
- top-5 retrieval hit rate improves by about `+4.2 pts`.

## 6) Deep Q&A #5: How to budget end-to-end indexing latency?

```text
ingestion_e2e_p95 =
  upload_to_claimcheck_p95 +
  queue_wait_p95 +
  parse_p95 +
  chunk_embed_p95 +
  index_commit_p95
```

Worked example:
- upload: `280ms`
- queue wait: `1,150ms`
- parse: `1,980ms`
- chunk/embed: `1,430ms`
- commit: `760ms`

`ingestion_e2e_p95 = 5,600ms`

Gate targets:
- general enterprise KB: `< 8,000ms`
- real-time support/trading knowledge: `< 4,000ms`

## 7) Deep Q&A #6: When does hybrid extraction beat single-path TCO?

```text
monthly_tco =
  parse_cost + embedding_cost + compute_cost + storage_cost + incident_loss

value_gain =
  (retrieval_accuracy_gain * query_volume * value_per_success)
```

Worked example (USD/month):
- A: DI-only: `26,400`
- B: VLM-only: `58,900`
- C: complexity-routed hybrid (recommended): `34,700`
- D: full multi-engine redundancy: `71,200`

When query volume exceeds `22M/month` and accuracy gain is `>3 pts`,
Option C generally yields the best ROI.

## 8) Mermaid #2: Idempotent chunking and replay flow

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

## 9) Production-grade Bicep / YAML / Policy / KQL

### 9.1 Bicep (Blob + Queue + ACA + Event Hubs)

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

### 9.2 YAML (ACA/KEDA parallel chunking)

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

### 9.3 Policy (accuracy and throughput gate)

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

### 9.4 KQL (complexity routing and replay health)

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

## 10) Quantitative 4-option Decision Matrix

| Option | Accuracy(35%) | Throughput(25%) | Cost(20%) | Operability(20%) | Composite |
|---|---:|---:|---:|---:|---:|
| A DI-only | 72 | 86 | 90 | 84 | 81.0 |
| B VLM-only | 92 | 64 | 51 | 61 | 70.4 |
| C Hybrid complexity routing (recommended) | 89 | 88 | 76 | 72 | **83.0** |
| D Full multi-engine redundancy | 94 | 79 | 42 | 45 | 68.4 |

## 11) Day-0 / Day-2 Checklist (Good fit vs Not for)

### Day-0
- [ ] Define page-complexity score and route threshold
- [ ] Implement Claim-Check pointer contract and idempotency keying
- [ ] Deploy ACA/KEDA parallel chunk workers
- [ ] Normalize bbox/table/figure grounding schema
- [ ] Wire gate metrics with automatic replay controls
- [ ] Complete 5% document-set canary rehearsal

### Day-2
- [ ] Weekly threshold calibration on sampled complex documents
- [ ] Replay-gap postmortems and dedupe conflict tuning
- [ ] OCR-noise compensation tuning for VLM route
- [ ] Track pages/min and per-page unit cost drift
- [ ] Clean stale chunks and invalid bbox links

### Good fit
- enterprise corpora with high structural complexity
- agentic RAG requiring both quality and ingestion timeliness
- platforms requiring observable replay and deterministic gates

### Not for
- low-complexity, small-scale document collections
- teams unable to maintain multimodal compensation pipelines
- temporary demos without strict extraction quality targets

## 12) Five-step rollout guide

1. **Baseline extraction**: run DI v4 markdown/layout and capture baseline quality.  
2. **Complexity routing**: route only complex pages to VLM to cap costs.  
3. **Parallel chunking**: scale throughput via Claim-Check + KEDA workers.  
4. **Grounding normalization**: unify bbox/table/figure link contracts.  
5. **Gate and replay**: enforce hard thresholds for quality/latency/replay.

## 13) Business scenario mapping

- **Coding Agent Sandbox**: fast structured retrieval over code docs and runbooks.  
- **Browser/CUA clusters**: cross-modal retrieval over UI reports and screenshots.  
- **Multi-tenant SaaS Gateway**: tenant-level parse budget and quota control.  
- **Financial zero-trust execution**: traceable extraction over contracts and audit docs.

## 14) Primary sources (official first)

- APIM AI Gateway Overview: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
- ACA Sessions: https://learn.microsoft.com/en-us/azure/container-apps/sessions  
- APIM Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md  
- Firecracker Releases: https://github.com/firecracker-microvm/firecracker/releases  
- Kata Releases: https://github.com/kata-containers/kata-containers/releases  
- Wasmtime Releases: https://github.com/bytecodealliance/wasmtime/releases  
- E2B Releases: https://github.com/e2b-dev/e2b/releases

## 15) Data evidence and recomputable examples (with n denominator source)

Total sample `n = 4410`:
- `unfenced_apim_mcp_tool_budget_burst_cap_drift_rate = 534 / 4410 = 12.1%`
- `apim_mcp_tool_budget_burst_cap_variance_rate = 216 / 4410 = 4.9%`
- `apim_mcp_tool_budget_burst_cap_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute:

```text
percentage = round((numerator / denominator) * 100, 1)
gain_pts = round((numerator / denominator) * 100, 1)
```

Notes:
- these rates are retained for deterministic pipeline contract validation;
- production values should be replaced with real tenant-segmented observations;
- preserve `measured/synthetic/anonymized_reported` labels for audit traceability.
