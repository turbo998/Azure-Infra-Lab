# Cycle #2480 Core Engineering Monograph: Disconnected-Edge Hybrid Agent Infra (Arc + AIO) (en)

- Round/Cycle: `1075 / 2480`
- Topic: `arc-aio-disconnected-edge-agent-faq-r1075`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Engineering objective

Maintain local continuity during outages, bounded catch-up after reconnect, and convergent policy state.

## 2) Core formulas

```text
cloud_escalation_rate = count(conf<threshold) / total
mqtt_buffer_disk_gb = (msg_rate * avg_msg_kb * outage_sec * replica) / (1024*1024)
recovery_catchup_seconds = backlog / post_reconnect_consume_rate
```

Thresholds:
- `escalation_rate < 0.25`
- `catchup_p95 < 300s`

## 3) Runnable snippets (Bicep / YAML / KQL)

### Bicep

```bicep
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' = {
  name: 'arc-edge-cluster'
}
```

### YAML

```yaml
inferencePolicy:
  confidenceThreshold: 0.78
  escalateToCloud: true
mqttBuffer:
  storeForwardEnabled: true
  maxDiskGb: 120
```

### KQL

```kql
EdgeAgentPipeline
| where TimeGenerated > ago(30m)
| summarize escalation_rate=avg(CloudEscalationRate), catchup_p95=percentile(RecoveryCatchupSeconds,95) by EdgeSite, bin(TimeGenerated, 5m)
| where escalation_rate > 0.25 or catchup_p95 > 300
```

## 4) Triage flow

1. WAN outage: local inference + durable buffering on disk.  
2. Reconnect: throttled replay with catch-up latency watch.  
3. Policy drift: Flux sync first, then gradual cloud escalation restore.

## 5) Conclusion

Disconnected-edge reliability is jointly determined by local inference thresholds, durable buffer sizing, and catch-up throughput; isolated tuning is insufficient.
