# Cycle #2465 核心工程专著：流式 Guardrail 管道（zh-CN）

- Round/Cycle: `1060 / 2465`
- Topic: `azure-content-safety-prompt-shield-groundedness-apim-aca-faq-r1060`

## 1) 核心公式

```text
chunk_window_ms = network_flush_ms + guard_eval_ms + token_emit_ms
stream_p95_ms = Σ(chunk_window_ms)
risk_score = w1*prompt_shield_score + w2*groundedness_risk + w3*xpia_signal
```

阈值：
- `chunk_window_p95 <= 120ms`
- `stream_p95 <= 1800ms`
- `risk_score >= 0.8 => fail-closed`

## 2) Runnable snippets

### Bicep（APIM + ACA）

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: 'apim-agent-guard'
  sku: { name: 'Premium', capacity: 1 }
}
```

### YAML（inline pipeline）

```yaml
pipeline:
  - prompt-shield
  - groundedness-inline
  - xpia-tool-output-quarantine
```

### APIM policy（阈值拦截）

```xml
<when condition="@(context.Variables.GetValueOrDefault<double>(\"riskScore\") >= 0.8)">
  <return-response><set-status code="403" reason="BlockedByGuardrail" /></return-response>
</when>
```

### KQL（延迟与 XPIA 排障）

```kql
GuardrailStreamLogs
| where TimeGenerated > ago(30m)
| summarize stream_p95=percentile(StreamLatencyMs,95), xpia_hits=countif(GuardrailDecision=="XPIAQuarantine") by Route
| where stream_p95 > 1800 or xpia_hits > 0
```

## 3) 失效模式

1. 分块窗口过大导致实时体验下降。  
2. guard 超时率升高导致 fail-open 漂移。  
3. XPIA 隐式注入绕过工具输出过滤。  
4. groundedness 误报引发可用性抖动。

## 4) 落地清单

- Prompt Shields 与 groundedness 分级阈值。  
- APIM circuit 模式（fail-open/closed）可配置切换。  
- XPIA 隔离与人工审计队列打通。  
- KQL 看板持续监控 chunk/window 与超时率。
