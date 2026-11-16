# Round 1073 / Cycle 2478 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **ACS Call Automation + Azure OpenAI Realtime Voice Agent Infra**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2478-benchmark.json`

## 1) Scenario objective

Production voice-agent reliability is driven by end-to-end mouth-to-ear latency and interruption responsiveness.  
Goal: under ACS call orchestration + Realtime WebRTC/WebSocket paths, deliver low latency, robust barge-in, and failover readiness.

## 2) Core formulas (latency / race / failover)

```text
mouth_to_ear_p95_ms =
  capture_ms + encode_ms + uplink_ms + model_infer_ms + tts_ms + downlink_ms + jitter_buffer_ms
```

```text
barge_in_race_window_ms =
  vad_detect_ms + cancel_signal_ms + playback_buffer_ms
```

```text
failover_cutover_ms =
  region_health_detect_ms + turn_rebind_ms + sip_reinvite_ms
```

Recommended thresholds: `mouth_to_ear_p95 < 900ms`, `barge_in_race_window_p95 < 180ms`.

## 3) Control policy (voice path governance)

1. Use WebRTC as primary low-jitter path; WebSocket as degraded fallback.  
2. On VAD hit, issue immediate cancel and flush buffered playback.  
3. On regional failure, trigger TURN/PSTN SIP active failover sequence.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep: ACS resource

```bicep
resource acs 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: 'acs-voice-agent'
  location: 'global'
}
```

### 4.2 YAML: voice path policy

```yaml
voicePath:
  primary: webrtc
  secondary: websocket
  vadBargeIn:
    enabled: true
    cancelTimeoutMs: 120
  failover:
    turnRegions: [eastus, westeurope]
```

### 4.3 KQL: mouth-to-ear and barge-in race monitoring

```kql
VoiceAgentTelemetry
| where TimeGenerated > ago(30m)
| summarize
    m2e_p95=percentile(MouthToEarMs,95),
    barge_p95=percentile(BargeInRaceWindowMs,95),
    failover_p95=percentile(FailoverCutoverMs,95)
    by TenantId, bin(TimeGenerated, 5m)
| where m2e_p95 > 900 or barge_p95 > 180
| order by m2e_p95 desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2478-benchmark.json`):

- `unfenced_voice_agent_guard_drift_rate = 534 / 4410 = 12.1%`
- `voice_agent_guard_variance_rate = 216 / 4410 = 4.9%`
- `voice_agent_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Customer-service agents requiring real-time voice and interruption handling.  
- Platforms requiring cross-region TURN/SIP failover readiness.

**Not for**
- Text-only interactions without real-time voice SLA.  
- Systems lacking unified call/media observability.
