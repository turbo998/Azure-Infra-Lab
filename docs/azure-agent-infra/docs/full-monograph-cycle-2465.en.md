# Cycle #2465 Core Engineering Monograph: Streaming Guardrail Pipeline (en)

- Round/Cycle: `1060 / 2465`
- Topic: `azure-content-safety-prompt-shield-groundedness-apim-aca-faq-r1060`

## 1) Core formulas

```text
chunk_window_ms = network_flush_ms + guard_eval_ms + token_emit_ms
stream_p95_ms = Σ(chunk_window_ms)
risk_score = w1*prompt_shield_score + w2*groundedness_risk + w3*xpia_signal
```

Thresholds:
- `chunk_window_p95 <= 120ms`
- `stream_p95 <= 1800ms`
- `risk_score >= 0.8 => fail-closed`

## 2) Runnable snippets

### Bicep (APIM + ACA)

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: 'apim-agent-guard'
  sku: { name: 'Premium', capacity: 1 }
}
```

### YAML (inline pipeline)

```yaml
pipeline:
  - prompt-shield
  - groundedness-inline
  - xpia-tool-output-quarantine
```

### APIM policy (threshold blocking)

```xml
<when condition="@(context.Variables.GetValueOrDefault<double>(\"riskScore\") >= 0.8)">
  <return-response><set-status code="403" reason="BlockedByGuardrail" /></return-response>
</when>
```

### KQL (latency and XPIA triage)

```kql
GuardrailStreamLogs
| where TimeGenerated > ago(30m)
| summarize stream_p95=percentile(StreamLatencyMs,95), xpia_hits=countif(GuardrailDecision=="XPIAQuarantine") by Route
| where stream_p95 > 1800 or xpia_hits > 0
```

## 3) Failure modes

1. Oversized chunk windows degrade realtime UX.
2. Guard timeout rise causes fail-open drift.
3. Indirect XPIA bypasses tool-output filtering.
4. Groundedness false positives cause availability instability.

## 4) Rollout checklist

- Tiered Prompt Shields + groundedness thresholds.
- Configurable APIM circuit modes (fail-open/fail-closed).
- XPIA quarantine connected to human review queue.
- Continuous KQL monitoring for chunk windows and timeout rate.
