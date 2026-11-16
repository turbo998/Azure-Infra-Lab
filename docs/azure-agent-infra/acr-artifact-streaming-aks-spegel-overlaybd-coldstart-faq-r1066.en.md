# Round 1066 / Cycle 2471 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **ACR Artifact Streaming + AKS Spegel P2P OCI cache for multi-GB agent/tool cold-start acceleration**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2471-benchmark.json`

## 1) Executive Summary

This round focuses on large image cold starts: pull-bandwidth bottlenecks, repeated node downloads, and geo fallback jitter.  
Key result: **Artifact Streaming first-byte startup + Spegel peer-hit optimization + OverlayBD page-fault budgeting** is the practical production combo.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2471-sources.json`)

## 3) Core formulas (pull bandwidth / peer hit / page latency)

### Q1: Cold-start pull bottleneck

```text
pull_time_sec = image_size_gb * 1024 / effective_pull_mbps
```

### Q2: Spegel peer-hit gain

```text
effective_pull_mbps = peer_hit_rate * peer_bandwidth + (1-peer_hit_rate) * remote_bandwidth
```

### Q3: OverlayBD page-fault budget

```text
page_fault_p95_ms = page_fetch_ms + decompress_ms + fs_overlay_ms
startup_p95_ms = base_init_ms + cold_page_fault_count * page_fault_p95_ms
```

## 4) Runnable snippets (Bicep / YAML / CLI / KQL)

### 4.1 Bicep (ACR replication backbone)

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acragentcache'
  location: resourceGroup().location
  sku: { name: 'Premium' }
}
```

### 4.2 YAML (Spegel + OverlayBD profile)

```yaml
imageAcceleration:
  artifactStreaming: true
  spegel:
    enabled: true
    targetPeerHitRate: 0.7
  overlaybd:
    onDemandPrefetchPages: 2048
```

### 4.3 CLI (streaming diagnostics sample)

```bash
az acr repository show -n acragentcache --repository agent/runtime
az aks show -g rg-agent -n aks-agent --query "networkProfile"
```

### 4.4 KQL (cold-start and fallback triage)

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

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2471-benchmark.json -> percentage_contract`):

- `unfenced_acr_spegel_overlaybd_coldstart_guard_drift_rate = 534 / 4410 = 12.1%`
- `acr_spegel_overlaybd_coldstart_guard_variance_rate = 216 / 4410 = 4.9%`
- `acr_spegel_overlaybd_coldstart_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (cold-start acceleration patterns)

| Pattern | Startup speed | Cost | Ops complexity | Recommendation |
|---|---:|---:|---:|---|
| Remote-only pulls | Low | Medium | Low | Not recommended |
| Streaming without P2P | Medium | Medium | Medium | Transitional |
| Streaming + Spegel + OverlayBD | **High** | **Medium-high** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. Startup p95 exceeds threshold: inspect peer hit rate before remote bandwidth.
2. `peer_hit_rate < 0.6`: rebalance peer topology and prewarm strategy.
3. Remote fallback surge: check geo-replication health and routing.
4. High page-fault jitter: tune prefetch pages and compression profile.
5. Repeated cold caches on nodes: enable image prewarm jobs.
