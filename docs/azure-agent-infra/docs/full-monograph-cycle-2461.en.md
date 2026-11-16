# Cycle #2461 Core Engineering Monograph: AKS KAITO + vLLM GPU Serving (en)

- Round/Cycle: `1056 / 2461`
- Topic: `aks-kaito-vllm-gpu-kvcache-nvme-prewarm-karpenter-keda-faq-r1056`

## 1) Critical sizing and budget formulas

```text
kv_cache_gib = (num_layers * 2 * seq_len * hidden_size * bytes_per_elem * concurrent_requests) / (1024^3)
cold_start_budget_sec = image_pull_sec + model_mount_sec + warmup_prefill_sec + first_token_sec
desired_replicas = ceil(queue_depth / msgs_per_replica_target)
gpu_node_floor   = ceil(desired_replicas / pods_per_gpu_node)
```

Recommended thresholds:
- `vram_headroom_gib >= max(4, 12% total_vram)`
- `cold_start_budget_sec <= 180`
- `queue_wait_p95_sec <= 45`

## 2) Runnable snippets

### Bicep (AKS GPU pool)

```bicep
resource gpuPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  name: 'aks-prod/gpu-infer'
  properties: {
    vmSize: 'Standard_NC24ads_A100_v4'
    enableAutoScaling: true
    minCount: 2
    maxCount: 12
  }
}
```

### YAML (vLLM params + KEDA scaling)

```yaml
args:
  - --max-model-len=8192
  - --gpu-memory-utilization=0.88
triggers:
  - type: azure-queue
    metadata:
      queueName: infer-jobs
      queueLength: "120"
```

### KQL (cold start / VRAM / queue triage)

```kql
GpuInferLogs
| where TimeGenerated > ago(30m)
| summarize cold_start_p95=percentile(ColdStartSec,95),
            queue_wait_p95=percentile(QueueWaitSec,95),
            oom=countif(Event=="CudaOOM")
            by ModelId, NodePool
| where cold_start_p95 > 180 or queue_wait_p95 > 45 or oom > 0
```

## 3) Failure modes and runbook

1. **CUDA OOM**: lower concurrency/context length, then move to larger-VRAM GPU if needed.
2. **Startup over budget**: inspect image layers, weight mount path, NVMe pre-warm hit ratio.
3. **Queue surge**: raise KEDA ceiling and GPU node floor with backpressure limits.
4. **Version drift**: tokenizer/weights mismatch requires blue-green cutover.

## 4) Production rollout checklist

- KAITO control plane isolated from business namespaces.
- vLLM VRAM budget coupled to request concurrency.
- NVMe pre-warm and tiered model cache enabled.
- KEDA + node autoscaling share explicit budget thresholds.
- Continuous KQL auditing for startup, OOM, and queue wait.
