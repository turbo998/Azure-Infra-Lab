# Round 1060 / Cycle 2465 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure AI Content Safety Prompt Shields + Groundedness Inline Guardrail（APIM/ACA 流式链路）**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2465-benchmark.json`

## 1) Executive Summary

本轮聚焦流式 Agent 风险治理：在 SSE 分块输出场景中同时控制注入风险、幻觉风险与延迟预算。  
核心结论：**Prompt Shields + Groundedness 联级判定 + XPIA 工具输出隔离** 是生产可执行方案。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2465-sources.json`）

## 3) 核心公式（SSE 延迟 / 风险阈值 / 回路）

### Q1: SSE 分块窗口延迟

```text
chunk_window_ms = network_flush_ms + guard_eval_ms + token_emit_ms
stream_p95_ms = Σ(chunk_window_ms over response_chunks)
```

建议：`chunk_window_p95 <= 120ms`，总流式 `stream_p95 <= 1800ms`。

### Q2: 风险分层阈值

```text
risk_score = w1*prompt_shield_score + w2*groundedness_risk + w3*xpia_signal
```

- `risk_score >= 0.8`：fail-closed  
- `0.5 <= risk_score < 0.8`：quarantine + 人审  
- `<0.5`：允许继续流式输出

### Q3: fail-open / fail-closed 电路切换

```text
open_mode_if = guard_timeout_rate > t_timeout and availability_slo_breach
closed_mode_if = xpia_confirmed_rate > t_attack
```

## 4) Runnable snippets（Bicep / YAML / APIM Policy / KQL）

### 4.1 Bicep（APIM + ACA）

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: 'apim-agent-guard'
  location: resourceGroup().location
  sku: { name: 'Premium', capacity: 1 }
}
resource aca 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'aca-agent-stream'
  location: resourceGroup().location
}
```

### 4.2 YAML（流式 guardrail 管道）

```yaml
pipeline:
  - name: prompt-shield
  - name: groundedness-inline
  - name: xpia-tool-output-quarantine
sse:
  chunkMaxTokens: 32
  maxChunkWindowMs: 120
```

### 4.3 APIM policy（超阈值熔断）

```xml
<policies>
  <inbound>
    <base />
    <set-variable name="riskScore" value="@(double.Parse(context.Request.Headers.GetValueOrDefault(\"x-risk-score\",\"0\")))" />
    <choose>
      <when condition="@(context.Variables.GetValueOrDefault<double>(\"riskScore\") >= 0.8)">
        <return-response>
          <set-status code="403" reason="BlockedByGuardrail" />
        </return-response>
      </when>
    </choose>
  </inbound>
</policies>
```

### 4.4 KQL（XPIA 与延迟联动排障）

```kql
GuardrailStreamLogs
| where TimeGenerated > ago(30m)
| summarize stream_p95=percentile(StreamLatencyMs,95),
            chunk_p95=percentile(ChunkWindowMs,95),
            xpia_hits=countif(GuardrailDecision=="XPIAQuarantine"),
            timeout_rate=todouble(countif(GuardrailDecision=="Timeout"))/count()
            by TenantId, Route
| where stream_p95 > 1800 or xpia_hits > 0 or timeout_rate > 0.03
| order by xpia_hits desc, stream_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2465-benchmark.json -> percentage_contract`）：

- `unfenced_content_safety_groundedness_stream_guard_drift_rate = 534 / 4410 = 12.1%`
- `content_safety_groundedness_stream_guard_variance_rate = 216 / 4410 = 4.9%`
- `content_safety_groundedness_stream_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（Guardrail 执行策略）

| 策略 | 安全性 | 可用性 | 延迟影响 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 全 fail-open | 低 | 高 | 低 | 低 | 不推荐 |
| 全 fail-closed | 高 | 低 | 中 | 中 | 高风险场景短时 |
| 分级阈值 + quarantine + circuit | **高** | **中高** | **中** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `chunk_window_p95 > 120ms`：检查 guard model 与网络 flush。  
2. `timeout_rate > 3%`：降级至轻量判定并扩 guard 副本。  
3. `xpia_hits` 突增：切换 fail-closed + 人审队列。  
4. groundedness 误报高：复核检索上下文拼接策略。  
5. circuit 抖动：提高阈值滞回与最小保持时间。
