# Cycle #2468 核心工程专著：边缘流式链路稳态（zh-CN）

- Round/Cycle: `1063 / 2468`
- Topic: `afd-premium-private-link-agc-alb-sse-websocket-drain-waf-faq-r1063`

## 1) 关键公式

```text
effective_idle_timeout = min(frontdoor_idle, agc_idle, app_idle)
drain_window_sec = active_conn_p95 / graceful_close_rate_per_sec
required_buffer_sec = drain_window_sec + health_probe_settle_sec
```

阈值：
- `probe_fail_ratio <= 0.3`
- `stream disconnect burst = 0`（目标）

## 2) Runnable snippets

### Bicep（AFD Premium）

```bicep
resource afd 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: 'afd-agent-premium'
  sku: { name: 'Premium_AzureFrontDoor' }
}
```

### YAML（timeout + drain）

```yaml
stream: { sseIdleTimeoutSec: 180, websocketIdleTimeoutSec: 300, heartbeatSec: 60 }
drain: { maxGracefulClosePerSec: 800 }
```

### APIM policy（JSON-RPC 例外）

```xml
<when condition="@(context.Request.Headers.GetValueOrDefault(\"content-type\",\"\").Contains(\"application/json-rpc\"))">
  <set-variable name="wafInspectionMode" value="McpJsonRpcRelaxed" />
</when>
```

### KQL（drain 与误拦截）

```kql
EdgeStreamLogs
| where TimeGenerated > ago(30m)
| summarize drain_fail=countif(Event=="DrainTimeout"), waf_fp=countif(Event=="WafFalsePositive") by Region
| where drain_fail > 0 or waf_fp > 0
```

## 3) 失效模式

1. timeout 层级不一致导致连接被提前断开。  
2. drain 速率低于活跃连接清退速率。  
3. WAF 对 MCP JSON-RPC 误判率上升。  
4. probe 抖动触发频繁跨区切流。

## 4) 落地清单

- 统一三层 idle-timeout 与 heartbeat。  
- active-active drain 预演和阈值固化。  
- JSON-RPC 精准例外与回归测试。  
- 区域级探测与切流看板持续监控。
