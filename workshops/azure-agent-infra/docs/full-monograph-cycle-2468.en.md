# Cycle #2468 Core Engineering Monograph: Edge Streaming Stability (en)

- Round/Cycle: `1063 / 2468`
- Topic: `afd-premium-private-link-agc-alb-sse-websocket-drain-waf-faq-r1063`

## 1) Core formulas

```text
effective_idle_timeout = min(frontdoor_idle, agc_idle, app_idle)
drain_window_sec = active_conn_p95 / graceful_close_rate_per_sec
required_buffer_sec = drain_window_sec + health_probe_settle_sec
```

Thresholds:
- `probe_fail_ratio <= 0.3`
- `stream disconnect burst = 0` (target)

## 2) Runnable snippets

### Bicep (AFD Premium)

```bicep
resource afd 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: 'afd-agent-premium'
  sku: { name: 'Premium_AzureFrontDoor' }
}
```

### YAML (timeout + drain)

```yaml
stream: { sseIdleTimeoutSec: 180, websocketIdleTimeoutSec: 300, heartbeatSec: 60 }
drain: { maxGracefulClosePerSec: 800 }
```

### APIM policy (JSON-RPC exception)

```xml
<when condition="@(context.Request.Headers.GetValueOrDefault(\"content-type\",\"\").Contains(\"application/json-rpc\"))">
  <set-variable name="wafInspectionMode" value="McpJsonRpcRelaxed" />
</when>
```

### KQL (drain and false positives)

```kql
EdgeStreamLogs
| where TimeGenerated > ago(30m)
| summarize drain_fail=countif(Event=="DrainTimeout"), waf_fp=countif(Event=="WafFalsePositive") by Region
| where drain_fail > 0 or waf_fp > 0
```

## 3) Failure modes

1. Timeout mismatch disconnects sessions prematurely.
2. Drain throughput below active-connection close demand.
3. Rising WAF false positives on MCP JSON-RPC payloads.
4. Probe jitter triggers frequent cross-region failover.

## 4) Rollout checklist

- Align idle-timeouts and heartbeats across all layers.
- Rehearse active-active drain thresholds regularly.
- Validate JSON-RPC exceptions with regression tests.
- Continuously monitor regional probe/failover dashboards.
