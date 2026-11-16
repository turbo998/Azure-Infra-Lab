# Round 1056 / Cycle 2461 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **AKS KAITO + vLLM GPU 推理：KV-cache 显存预算、NVMe 预热、Karpenter/NAP 冷启动与 KEDA 队列扩缩**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2461-benchmark.json`

## 1) Executive Summary

本轮聚焦“专用子模型（tool/router）上线难点”：显存打满、模型冷加载抖动、GPU 节点拉起慢导致队列爆涨。  
核心结论：**KV-cache 显存公式 + NVMe 分层预热 + Karpenter/NAP 冷启动预算 + KEDA 队列护栏** 组合后，才能把 P95 稳定在生产阈值内。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2461-sources.json`）

## 3) 核心公式（VRAM / 冷启动 / 扩缩）

### Q1: KV-cache 显存预算怎么估？

```text
kv_cache_gib = (num_layers * 2 * seq_len * hidden_size * bytes_per_elem * concurrent_requests) / (1024^3)
```

生产要求：`vram_headroom_gib >= max(4, 0.12 * total_vram_gib)`，避免碎片化 OOM。

### Q2: 节点冷启动预算如何定义？

```text
cold_start_budget_sec = image_pull_sec + model_mount_sec + warmup_prefill_sec + first_token_sec
```

建议：`cold_start_budget_sec <= 180`，超过则必须启用 NVMe 预热层。

### Q3: KEDA 队列扩缩与 GPU 节点联动阈值？

```text
desired_replicas = ceil(queue_depth / msgs_per_replica_target)
gpu_node_floor   = ceil(desired_replicas / pods_per_gpu_node)
```

- 若 `queue_wait_p95_sec > 45` 连续 2 个窗口：提升 `gpu_node_floor`  
- 若 `gpu_util_p95 < 45%` 且排队低：降副本防止空转成本

## 4) Runnable snippets（Bicep / YAML / KQL）

### 4.1 Bicep（GPU 节点池）

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

### 4.2 YAML（vLLM + KEDA）

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

### 4.3 KQL（冷启动与显存异常）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2461-benchmark.json -> percentage_contract`）：

- `unfenced_kaito_vllm_gpu_kvcache_guard_drift_rate = 534 / 4410 = 12.1%`
- `kaito_vllm_gpu_kvcache_guard_variance_rate = 216 / 4410 = 4.9%`
- `kaito_vllm_gpu_kvcache_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（GPU 推理方案）

| 方案 | 延迟稳定 | 启动速度 | 成本可控 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 纯在线冷加载 | 低 | 低 | 中 | 低 | PoC |
| 固定热池 + 无队列护栏 | 中 | 中 | 低 | 中 | 小规模 |
| KAITO + vLLM + NVMe 预热 + KEDA | **高** | **高** | **中高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `oom_count > 0`：先降并发，再降 `max-model-len`，最后扩 GPU 型号。  
2. `cold_start_p95_sec > 180`：检查镜像拉取与 NVMe 缓存命中。  
3. `queue_wait_p95_sec > 45`：提升 KEDA `maxReplicaCount` 与 GPU node floor。  
4. `gpu_util_p95 < 45%` 且队列低：缩容回收成本。  
5. tokenizer/weights 版本不一致：执行蓝绿切换，禁止原地覆盖。
