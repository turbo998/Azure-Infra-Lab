# Cycle #2461 核心工程专著：AKS KAITO + vLLM GPU 服务化（zh-CN）

- Round/Cycle: `1056 / 2461`
- Topic: `aks-kaito-vllm-gpu-kvcache-nvme-prewarm-karpenter-keda-faq-r1056`

## 1) 关键容量与预算公式

```text
kv_cache_gib = (num_layers * 2 * seq_len * hidden_size * bytes_per_elem * concurrent_requests) / (1024^3)
cold_start_budget_sec = image_pull_sec + model_mount_sec + warmup_prefill_sec + first_token_sec
desired_replicas = ceil(queue_depth / msgs_per_replica_target)
gpu_node_floor   = ceil(desired_replicas / pods_per_gpu_node)
```

建议阈值：
- `vram_headroom_gib >= max(4, 12% total_vram)`
- `cold_start_budget_sec <= 180`
- `queue_wait_p95_sec <= 45`

## 2) Runnable snippets

### Bicep（AKS GPU 节点池）

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

### YAML（vLLM 参数 + KEDA 扩缩）

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

### KQL（冷启动/显存/排队联合排障）

```kql
GpuInferLogs
| where TimeGenerated > ago(30m)
| summarize cold_start_p95=percentile(ColdStartSec,95),
            queue_wait_p95=percentile(QueueWaitSec,95),
            oom=countif(Event=="CudaOOM")
            by ModelId, NodePool
| where cold_start_p95 > 180 or queue_wait_p95 > 45 or oom > 0
```

## 3) 失效模式与 runbook

1. **CUDA OOM**：降低并发/上下文长度，必要时切换更大显存 GPU。  
2. **冷启动超预算**：检查镜像层、权重挂载路径、NVMe 预热命中率。  
3. **排队飙升**：提高 KEDA 上限与 GPU node floor，并启用限流回压。  
4. **版本漂移**：权重与 tokenizer 不一致时必须蓝绿切换。

## 4) 生产落地清单

- KAITO 控制面与业务命名空间隔离。  
- vLLM VRAM 预算与请求并发联动。  
- NVMe 预热和模型分层缓存策略启用。  
- KEDA + 节点自动扩缩有统一预算阈值。  
- 通过 KQL 持续审计冷启动、OOM、队列等待。
