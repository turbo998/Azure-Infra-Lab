# Round 1063 / Cycle 2468 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure Front Door Premium + Private Link Origin + AGC ALB: SSE/WebSocket idle-timeout tuning, regional drain math, WAF false-positive handling**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2468-benchmark.json`

## 1) Executive Summary

This round targets realtime streaming reliability: long-lived timeout mismatches, active-active drain cutover, and WAF false positives on JSON-RPC/MCP payloads.  
Key result: **layered idle-timeout tuning + drain-window math + precise WAF exceptions** is the production baseline.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2468-sources.json`)

## 3) Core formulas (connection / drain / probes)

### Q1: SSE/WebSocket idle-timeout layering

```text
effective_idle_timeout = min(frontdoor_idle, agc_idle, app_idle)
heartbeat_interval_sec <= effective_idle_timeout * 0.4
```

### Q2: Regional drain-safe window

```text
drain_window_sec = active_conn_p95 / graceful_close_rate_per_sec
required_buffer_sec = drain_window_sec + health_probe_settle_sec
```

### Q3: Probe-based failover trigger

`failover_trigger = probe_fail_ratio >= threshold and p95_latency_spike`

Recommended `threshold=0.3` with hysteresis hold windows.

## 4) Runnable snippets (Bicep / YAML / APIM policy / KQL)

### 4.1 Bicep (AFD + Private Link origin)

```bicep
resource afd 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: 'afd-agent-premium'
  sku: { name: 'Premium_AzureFrontDoor' }
}
```

### 4.2 YAML (stream timeout profile)

```yaml
stream:
  sseIdleTimeoutSec: 180
  websocketIdleTimeoutSec: 300
  heartbeatSec: 60
drain:
  maxGracefulClosePerSec: 800
```

### 4.3 APIM policy (JSON-RPC/MCP false-positive bypass)

```xml
<choose>
  <when condition="@(context.Request.Headers.GetValueOrDefault(\"content-type\",\"\").Contains(\"application/json-rpc\"))">
    <set-variable name="wafInspectionMode" value="McpJsonRpcRelaxed" />
  </when>
</choose>
```

### 4.4 KQL (drain and false-positive triage)

```kql
EdgeStreamLogs
| where TimeGenerated > ago(30m)
| summarize conn_p95=percentile(ActiveConnections,95),
            drain_fail=countif(Event=="DrainTimeout"),
            waf_fp=countif(Event=="WafFalsePositive"),
            probe_fail_ratio=avg(ProbeFailRatio)
            by Region, Route
| where drain_fail > 0 or waf_fp > 0 or probe_fail_ratio > 0.3
| order by drain_fail desc, waf_fp desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2468-benchmark.json -> percentage_contract`):

- `unfenced_afd_agc_stream_drain_waf_guard_drift_rate = 534 / 4410 = 12.1%`
- `afd_agc_stream_drain_waf_guard_variance_rate = 216 / 4410 = 4.9%`
- `afd_agc_stream_drain_waf_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (edge-streaming patterns)

| Pattern | Availability | Security | Latency stability | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Single-region default timeout | Low | Medium | Low | Low | Not recommended |
| Dual-region without drain math | Medium | Medium | Medium | Medium | Transitional |
| AFD+PL+AGC + drain + precise WAF exception | **High** | **High** | **High** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. Frequent disconnects: validate idle-timeout consistency across all layers.
2. Drain failures: increase graceful close rate or buffer window.
3. WAF false positives rise: narrow JSON-RPC exception scope.
4. Probe-flap failover: increase hysteresis and minimum hold duration.
5. Regional skew: gradually rebalance route weights.
