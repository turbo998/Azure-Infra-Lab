# Round 1060 / Cycle 2465 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure AI Content Safety Prompt Shields + Groundedness inline guardrails on APIM/ACA streaming paths**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2465-benchmark.json`

## 1) Executive Summary

This round focuses on streaming-agent safety where SSE chunk responses must satisfy injection protection, groundedness, and latency SLO simultaneously.  
Key result: **Prompt Shields + Groundedness cascade + indirect XPIA tool-output quarantine** is a deployable production pattern.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2465-sources.json`)

## 3) Core formulas (SSE latency / risk thresholds / circuit mode)

### Q1: SSE chunk-window latency

```text
chunk_window_ms = network_flush_ms + guard_eval_ms + token_emit_ms
stream_p95_ms = Σ(chunk_window_ms over response_chunks)
```

Targets: `chunk_window_p95 <= 120ms`, overall `stream_p95 <= 1800ms`.

### Q2: Risk-tier scoring

```text
risk_score = w1*prompt_shield_score + w2*groundedness_risk + w3*xpia_signal
```

- `risk_score >= 0.8`: fail-closed  
- `0.5 <= risk_score < 0.8`: quarantine + human review  
- `< 0.5`: allow streaming continuation

### Q3: fail-open / fail-closed circuit thresholds

```text
open_mode_if = guard_timeout_rate > t_timeout and availability_slo_breach
closed_mode_if = xpia_confirmed_rate > t_attack
```

## 4) Runnable snippets (Bicep / YAML / APIM policy / KQL)

### 4.1 Bicep (APIM + ACA)

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

### 4.2 YAML (stream guardrail pipeline)

```yaml
pipeline:
  - name: prompt-shield
  - name: groundedness-inline
  - name: xpia-tool-output-quarantine
sse:
  chunkMaxTokens: 32
  maxChunkWindowMs: 120
```

### 4.3 APIM policy (hard block at risk threshold)

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

### 4.4 KQL (XPIA + latency triage)

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

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2465-benchmark.json -> percentage_contract`):

- `unfenced_content_safety_groundedness_stream_guard_drift_rate = 534 / 4410 = 12.1%`
- `content_safety_groundedness_stream_guard_variance_rate = 216 / 4410 = 4.9%`
- `content_safety_groundedness_stream_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (guardrail execution modes)

| Mode | Security | Availability | Latency impact | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Always fail-open | Low | High | Low | Low | Not recommended |
| Always fail-closed | High | Low | Medium | Medium | Temporary high-risk mode |
| Tiered thresholds + quarantine + circuit | **High** | **Medium-high** | **Medium** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. `chunk_window_p95 > 120ms`: inspect guard model and network flush stages.
2. `timeout_rate > 3%`: degrade to lighter checks and scale guard replicas.
3. XPIA hits spike: switch fail-closed and route to human-review queue.
4. Groundedness false positives rise: re-evaluate retrieval context stitching.
5. Circuit flapping: add hysteresis and minimum hold intervals.
