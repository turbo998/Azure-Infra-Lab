# Round 1075 / Cycle 2480 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Arc-enabled Kubernetes + Azure IoT Operations disconnected-edge hybrid agent infra**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2480-benchmark.json`

## 1) Scenario objective

Key disconnected-edge challenges are cloud escalation on low-confidence local inference, lossless buffering during WAN outage, and convergent policy sync after recovery.  
Goal: with Arc + AIO + Flux GitOps, enforce offline continuity, online escalation, and auditable recovery.

## 2) Core formulas (escalation / buffering / recovery)

```text
cloud_escalation_rate =
  count(confidence < threshold) / total_inferences
```

```text
mqtt_buffer_disk_gb =
  (msg_rate_per_sec * avg_msg_kb * outage_seconds * replication_factor) / (1024 * 1024)
```

```text
recovery_catchup_seconds =
  backlog_messages / post_reconnect_consume_rate_mps
```

Recommended thresholds: `cloud_escalation_rate < 0.25`, `recovery_catchup_seconds p95 < 300`.

## 3) Policy design (offline-first + online escalation)

1. Run local SLM first; escalate to cloud Foundry only below confidence threshold.  
2. Persist MQTT store-and-forward to local disk during WAN outage.  
3. After reconnect, replay with Flux policy sync and controlled throttle to avoid surge.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep: Arc connected cluster anchor

```bicep
resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-01-01' = {
  name: 'arc-edge-cluster'
  location: resourceGroup().location
}
```

### 4.2 YAML: edge inference escalation policy

```yaml
inferencePolicy:
  localModel: slm-edge
  confidenceThreshold: 0.78
  escalateToCloud: true
mqttBuffer:
  storeForwardEnabled: true
  maxDiskGb: 120
```

### 4.3 KQL: outage backlog and recovery health

```kql
EdgeAgentPipeline
| where TimeGenerated > ago(30m)
| summarize
    escalation_rate=avg(CloudEscalationRate),
    catchup_p95=percentile(RecoveryCatchupSeconds,95),
    disk_p95=percentile(BufferDiskUsageGb,95)
    by EdgeSite, bin(TimeGenerated, 5m)
| where escalation_rate > 0.25 or catchup_p95 > 300
| order by catchup_p95 desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2480-benchmark.json`):

- `unfenced_edge_escalation_guard_drift_rate = 534 / 4410 = 12.1%`
- `edge_escalation_guard_variance_rate = 216 / 4410 = 4.9%`
- `edge_escalation_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Edge sites with frequent disconnects or high-latency links.  
- Need local-first inference with controlled cloud escalation.

**Not for**
- Always-on high-quality links with centralized-only runtime requirements.  
- Lightweight nodes without durable local buffering.
