# Cycle #2471 核心工程专著：镜像流式冷启动加速（zh-CN）

- Round/Cycle: `1066 / 2471`
- Topic: `acr-artifact-streaming-aks-spegel-overlaybd-coldstart-faq-r1066`

## 1) 关键公式

```text
pull_time_sec = image_size_gb * 1024 / effective_pull_mbps
effective_pull_mbps = peer_hit_rate*peer_bandwidth + (1-peer_hit_rate)*remote_bandwidth
startup_p95_ms = base_init_ms + cold_page_fault_count * page_fault_p95_ms
```

阈值：
- `peer_hit_rate >= 0.6`
- `startup_p95_ms <= 25000`

## 2) Runnable snippets

### Bicep（ACR）

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acragentcache'
}
```

### YAML（加速配置）

```yaml
imageAcceleration:
  artifactStreaming: true
  spegel: { enabled: true, targetPeerHitRate: 0.7 }
  overlaybd: { onDemandPrefetchPages: 2048 }
```

### CLI（诊断）

```bash
az acr repository show -n acragentcache --repository agent/runtime
```

### KQL（启动与回源）

```kql
ContainerColdStartLogs
| where TimeGenerated > ago(30m)
| summarize startup_p95=percentile(StartupMs,95), peer_hit_rate=avg(PeerHitRate) by Cluster
| where startup_p95 > 25000 or peer_hit_rate < 0.6
```

## 3) 失效模式

1. 远端回源过多导致启动抖动。  
2. Spegel peer 拓扑失衡降低命中率。  
3. OverlayBD 页面抖动放大启动延迟。  
4. 节点频繁淘汰导致缓存复冷。

## 4) 落地清单

- ACR 区域复制与路由策略一致化。  
- Spegel peer 命中率持续观测。  
- OverlayBD prefetch 参数按镜像类别分层。  
- 关键镜像预热任务常态化。
