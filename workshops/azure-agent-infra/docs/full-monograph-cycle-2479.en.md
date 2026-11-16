# Cycle #2479 Core Engineering Monograph: Headless Browser Agent Fleet (en)

- Round/Cycle: `1074 / 2479`
- Topic: `browseruse-computeruse-headless-fleet-faq-r1074`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Engineering objective

For ACA/AKS Browser-Use and Computer-Use agents, control three systemic risks together: OOM, SNAT exhaustion, and token-cost inflation.

## 2) Core formulas

```text
pod_memory_budget_mb = shm + heap + chromium_overhead + margin
max_sessions_per_node = floor(node_available / pod_memory_budget_mb)
required_snat_ports = concurrency * conn_per_session * burst_factor
token_latency_tradeoff_ms = (vision_tokens - a11y_tokens) * ms_per_1k_tokens / 1000
```

Thresholds:
- `oom_rate < 0.5%`
- `snat_utilization < 0.7`

## 3) Runnable snippets (Bicep / YAML / KQL)

### Bicep

```bicep
resource nat 'Microsoft.Network/natGateways@2023-09-01' = {
  name: 'nat-browser-fleet'
}
```

### YAML

```yaml
env:
  - name: CHROME_SHM_MB
    value: "384"
  - name: V8_HEAP_MB
    value: "1024"
```

### KQL

```kql
BrowserFleetMetrics
| where TimeGenerated > ago(30m)
| summarize oom_rate=avg(OomRestartRate), snat_util=percentile(SnatUtilization,95) by Cluster, bin(TimeGenerated, 5m)
| where oom_rate > 0.005 or snat_util > 0.7
```

## 4) Triage flow

1. OOM rise: reduce concurrency and recycle heavy pods.  
2. SNAT saturation: expand NAT port pool and apply peak throttling.  
3. Token surge: prioritize accessibility-tree input and reduce screenshot cadence.

## 5) Conclusion

Browser fleet reliability is a three-dimensional budget problem across memory, network ports, and input modality; scheduling and observability must treat them jointly.
