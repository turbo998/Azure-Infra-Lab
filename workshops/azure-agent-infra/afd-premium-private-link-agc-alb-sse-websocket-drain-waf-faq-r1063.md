# Round 1063 / Cycle 2468 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure Front Door Premium + Private Link Origin + AGC ALB：SSE/WebSocket 长连接超时、跨区域 drain 与 WAF 误拦截**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2468-benchmark.json`

## 1) Executive Summary

本轮聚焦实时 Agent 流式链路稳定性：长连接超时、区域切流 drain、WAF 对 JSON-RPC/MCP 误判。  
核心结论：**idle-timeout 分层调优 + active-active drain 数学 + WAF 精准例外** 才能兼顾可用与安全。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2468-sources.json`）

## 3) 核心公式（连接 / drain / 健康探测）

### Q1: SSE/WebSocket idle-timeout 分层

```text
effective_idle_timeout = min(frontdoor_idle, agc_idle, app_idle)
heartbeat_interval_sec <= effective_idle_timeout * 0.4
```

### Q2: 区域 drain 安全窗口

```text
drain_window_sec = active_conn_p95 / graceful_close_rate_per_sec
required_buffer_sec = drain_window_sec + health_probe_settle_sec
```

### Q3: 健康探测切流阈值

`failover_trigger = probe_fail_ratio >= threshold and p95_latency_spike`

建议 `threshold=0.3`，并加最小保持窗口避免抖动。

## 4) Runnable snippets（Bicep / YAML / APIM policy / KQL）

### 4.1 Bicep（AFD + Private Link origin）

```bicep
resource afd 'Microsoft.Cdn/profiles@2024-09-01' = {
  name: 'afd-agent-premium'
  sku: { name: 'Premium_AzureFrontDoor' }
}
```

### 4.2 YAML（连接超时配置）

```yaml
stream:
  sseIdleTimeoutSec: 180
  websocketIdleTimeoutSec: 300
  heartbeatSec: 60
drain:
  maxGracefulClosePerSec: 800
```

### 4.3 APIM policy（MCP payload 误拦截旁路）

```xml
<choose>
  <when condition="@(context.Request.Headers.GetValueOrDefault(\"content-type\",\"\").Contains(\"application/json-rpc\"))">
    <set-variable name="wafInspectionMode" value="McpJsonRpcRelaxed" />
  </when>
</choose>
```

### 4.4 KQL（切流与误拦截排障）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2468-benchmark.json -> percentage_contract`）：

- `unfenced_afd_agc_stream_drain_waf_guard_drift_rate = 534 / 4410 = 12.1%`
- `afd_agc_stream_drain_waf_guard_variance_rate = 216 / 4410 = 4.9%`
- `afd_agc_stream_drain_waf_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（边缘流式策略）

| 策略 | 可用性 | 安全性 | 延迟稳定 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 单区 + 默认超时 | 低 | 中 | 低 | 低 | 不推荐 |
| 双区无 drain 算法 | 中 | 中 | 中 | 中 | 过渡 |
| AFD+PL+AGC + drain + WAF 精准例外 | **高** | **高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. 连接频繁断开：校验三层 idle-timeout 一致性。  
2. drain 失败：提高 graceful close 速率或扩充缓冲窗口。  
3. WAF 误拦截上升：收敛 JSON-RPC 例外条件。  
4. probe 抖动切流：增加最小保持时长与滞回。  
5. 区域倾斜：按路由权重逐级回流。
