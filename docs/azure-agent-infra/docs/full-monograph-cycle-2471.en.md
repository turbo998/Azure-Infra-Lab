# Cycle #2471 Core Engineering Monograph: Image Streaming Cold-Start Acceleration (en)

- Round/Cycle: `1066 / 2471`
- Topic: `acr-artifact-streaming-aks-spegel-overlaybd-coldstart-faq-r1066`

## 1) Core formulas

```text
pull_time_sec = image_size_gb * 1024 / effective_pull_mbps
effective_pull_mbps = peer_hit_rate*peer_bandwidth + (1-peer_hit_rate)*remote_bandwidth
startup_p95_ms = base_init_ms + cold_page_fault_count * page_fault_p95_ms
```

Thresholds:
- `peer_hit_rate >= 0.6`
- `startup_p95_ms <= 25000`

## 2) Runnable snippets

### Bicep (ACR)

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acragentcache'
}
```

### YAML (acceleration profile)

```yaml
imageAcceleration:
  artifactStreaming: true
  spegel: { enabled: true, targetPeerHitRate: 0.7 }
  overlaybd: { onDemandPrefetchPages: 2048 }
```

### CLI (diagnostics)

```bash
az acr repository show -n acragentcache --repository agent/runtime
```

### KQL (startup/fallback triage)

```kql
ContainerColdStartLogs
| where TimeGenerated > ago(30m)
| summarize startup_p95=percentile(StartupMs,95), peer_hit_rate=avg(PeerHitRate) by Cluster
| where startup_p95 > 25000 or peer_hit_rate < 0.6
```

## 3) Failure modes

1. Excess remote fallback causes startup jitter.
2. Imbalanced Spegel topology lowers peer hit rates.
3. OverlayBD page-fault jitter inflates startup latency.
4. Frequent node churn repeatedly cold-resets caches.

## 4) Rollout checklist

- Align ACR geo-replication and route policy.
- Continuously monitor Spegel peer-hit rates.
- Tune OverlayBD prefetch by image class.
- Keep critical-image prewarm jobs always on.
