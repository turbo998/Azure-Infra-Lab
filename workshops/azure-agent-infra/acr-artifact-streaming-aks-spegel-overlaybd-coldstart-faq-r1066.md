# Round 1066 / Cycle 2471 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **ACR Artifact Streaming + AKS Spegel P2P OCI 缓存：多 GB 镜像冷启动加速与 OverlayBD 延迟权衡**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2471-benchmark.json`

## 1) Executive Summary

本轮聚焦大镜像 Agent/Tool 冷启动：拉取带宽瓶颈、节点重复下载、跨区回源抖动。  
核心结论：**Artifact Streaming 首屏拉起 + Spegel peer 命中率优化 + OverlayBD 页面访问预算** 是可落地组合。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2471-sources.json`）

## 3) 核心公式（拉取带宽 / 命中率 / 页面延迟）

### Q1: 冷启动拉取瓶颈

```text
pull_time_sec = image_size_gb * 1024 / effective_pull_mbps
```

### Q2: Spegel peer 命中收益

```text
effective_pull_mbps = peer_hit_rate * peer_bandwidth + (1-peer_hit_rate) * remote_bandwidth
```

### Q3: OverlayBD 页面抖动预算

```text
page_fault_p95_ms = page_fetch_ms + decompress_ms + fs_overlay_ms
startup_p95_ms = base_init_ms + cold_page_fault_count * page_fault_p95_ms
```

## 4) Runnable snippets（Bicep / YAML / CLI / KQL）

### 4.1 Bicep（ACR 复制骨架）

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acragentcache'
  location: resourceGroup().location
  sku: { name: 'Premium' }
}
```

### 4.2 YAML（Spegel + OverlayBD）

```yaml
imageAcceleration:
  artifactStreaming: true
  spegel:
    enabled: true
    targetPeerHitRate: 0.7
  overlaybd:
    onDemandPrefetchPages: 2048
```

### 4.3 CLI（镜像流式配置示例）

```bash
az acr repository show -n acragentcache --repository agent/runtime
az aks show -g rg-agent -n aks-agent --query \"networkProfile\"
```

### 4.4 KQL（冷启动与回源排障）

```kql
ContainerColdStartLogs
| where TimeGenerated > ago(30m)
| summarize startup_p95=percentile(StartupMs,95),
            peer_hit_rate=avg(PeerHitRate),
            remote_fallback=countif(PullSource=="RemoteRegistry")
            by Cluster, ImageClass
| where startup_p95 > 25000 or peer_hit_rate < 0.6
| order by startup_p95 desc, peer_hit_rate asc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2471-benchmark.json -> percentage_contract`）：

- `unfenced_acr_spegel_overlaybd_coldstart_guard_drift_rate = 534 / 4410 = 12.1%`
- `acr_spegel_overlaybd_coldstart_guard_variance_rate = 216 / 4410 = 4.9%`
- `acr_spegel_overlaybd_coldstart_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（冷启动加速策略）

| 策略 | 启动速度 | 成本 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---|
| 纯远端拉取 | 低 | 中 | 低 | 不推荐 |
| Streaming 无 P2P | 中 | 中 | 中 | 过渡 |
| Streaming + Spegel + OverlayBD | **高** | **中高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `startup_p95` 超阈：先查 peer 命中率，再查回源带宽。  
2. `peer_hit_rate < 0.6`：重平衡 peer 拓扑与预热策略。  
3. 远端回源激增：检查 geo-replication 健康与路由。  
4. 页面抖动高：调优 prefetch 页面数与压缩参数。  
5. 节点冷缓存反复：启用镜像预热作业。
