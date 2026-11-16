# Round 1056 / Cycle 2461 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **AKS KAITO + vLLM GPU serving: KV-cache VRAM sizing, NVMe pre-warm, Karpenter/NAP cold-start budget, KEDA queue scaling**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2461-benchmark.json`

## 1) Executive Summary

This round targets specialized tool/router sub-model production pain points: VRAM exhaustion, model load jitter, and GPU node scale lag creating queue spikes.  
Key result: **KV-cache VRAM math + NVMe pre-warm tiers + Karpenter/NAP startup budget + KEDA queue guardrails** is the minimum reliable setup.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2461-sources.json`)

## 3) Core formulas (VRAM / startup / scaling)

### Q1: KV-cache VRAM budget

```text
kv_cache_gib = (num_layers * 2 * seq_len * hidden_size * bytes_per_elem * concurrent_requests) / (1024^3)
```

Production guardrail: `vram_headroom_gib >= max(4, 0.12 * total_vram_gib)`.

### Q2: GPU node cold-start budget

```text
cold_start_budget_sec = image_pull_sec + model_mount_sec + warmup_prefill_sec + first_token_sec
```

Recommended target: `cold_start_budget_sec <= 180`; beyond that, NVMe pre-warm is mandatory.

### Q3: KEDA queue scaling with GPU floor

```text
desired_replicas = ceil(queue_depth / msgs_per_replica_target)
gpu_node_floor   = ceil(desired_replicas / pods_per_gpu_node)
```

- If `queue_wait_p95_sec > 45` for 2 windows, raise `gpu_node_floor`.
- If `gpu_util_p95 < 45%` with low queue depth, scale down to reduce idle cost.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep (GPU node pool)

```bicep
resource gpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'aks-prod/gpu-infer'
  properties: {
    vmSize: 'Standard_NC24ads_A100_v4'
    count: 2
    mode: 'User'
    osType: 'Linux'
    nodeTaints: [ 'workload=gpu-infer:NoSchedule' ]
    enableAutoScaling: true
    minCount: 2
    maxCount: 12
  }
}
```

### 4.2 YAML (vLLM + KEDA)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-router
spec:
  template:
    spec:
      nodeSelector: { workload: gpu-infer }
      containers:
        - name: vllm
          image: myacr.azurecr.io/vllm:0.7.3
          args: ["--max-model-len=8192","--gpu-memory-utilization=0.88"]
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: vllm-router-scale
spec:
  maxReplicaCount: 48
  triggers:
    - type: azure-queue
      metadata:
        queueName: infer-jobs
        queueLength: "120"
```

### 4.3 KQL (cold-start and VRAM anomaly triage)

```kql
GpuInferLogs
| where TimeGenerated > ago(30m)
| summarize cold_start_p95=percentile(ColdStartSec,95),
            queue_wait_p95=percentile(QueueWaitSec,95),
            oom_count=countif(Event=="CudaOOM"),
            gpu_util_p95=percentile(GpuUtilPct,95)
            by ModelId, NodePool
| where cold_start_p95 > 180 or queue_wait_p95 > 45 or oom_count > 0
| order by oom_count desc, cold_start_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2461-benchmark.json -> percentage_contract`):

- `unfenced_kaito_vllm_gpu_kvcache_guard_drift_rate = 534 / 4410 = 12.1%`
- `kaito_vllm_gpu_kvcache_guard_variance_rate = 216 / 4410 = 4.9%`
- `kaito_vllm_gpu_kvcache_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (GPU serving patterns)

| Pattern | Latency stability | Startup speed | Cost control | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Fully cold online loading | Low | Low | Medium | Low | PoC only |
| Fixed warm pool without queue guardrail | Medium | Medium | Low | Medium | Small scale |
| KAITO + vLLM + NVMe pre-warm + KEDA | **High** | **High** | **Medium-high** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `oom_count > 0`: lower concurrency first, then max model length, then scale GPU SKU.
2. `cold_start_p95_sec > 180`: inspect image pull and NVMe cache hit ratio.
3. `queue_wait_p95_sec > 45`: raise KEDA max replicas and GPU node floor.
4. `gpu_util_p95 < 45%` with low queue depth: scale down idle capacity.
5. tokenizer/weights mismatch: run blue/green swap, never in-place overwrite.
