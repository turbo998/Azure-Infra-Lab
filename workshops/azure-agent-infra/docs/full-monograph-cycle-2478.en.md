# Cycle #2478 Core Engineering Monograph: Realtime Voice Agent Path (ACS + Realtime) (en)

- Round/Cycle: `1073 / 2478`
- Topic: `acs-realtime-voice-agent-infra-faq-r1073`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Engineering objective

Preserve three baseline voice-agent qualities: low latency, interruption responsiveness, and failover continuity.

## 2) Core formulas

```text
mouth_to_ear_p95_ms = capture + encode + uplink + infer + tts + downlink + jitter
barge_in_race_window_ms = vad_detect + cancel_signal + playback_buffer
failover_cutover_ms = health_detect + turn_rebind + sip_reinvite
```

Thresholds:
- `m2e_p95 < 900ms`
- `barge_in_p95 < 180ms`

## 3) Runnable snippets (Bicep / YAML / KQL)

### Bicep

```bicep
resource acs 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: 'acs-voice-agent'
  location: 'global'
}
```

### YAML

```yaml
voicePath:
  primary: webrtc
  secondary: websocket
  vadBargeIn: { enabled: true, cancelTimeoutMs: 120 }
```

### KQL

```kql
VoiceAgentTelemetry
| where TimeGenerated > ago(30m)
| summarize m2e_p95=percentile(MouthToEarMs,95), barge_p95=percentile(BargeInRaceWindowMs,95) by TenantId, bin(TimeGenerated, 5m)
| where m2e_p95 > 900 or barge_p95 > 180
```

## 4) Triage flow

1. M2E breach: force WebRTC primary path and tighten jitter buffer.  
2. Barge-in race rise: reduce playback buffering and issue earlier cancel.  
3. Regional fault: execute TURN/SIP failover and throttle non-critical calls.

## 5) Conclusion

Realtime voice quality is a full-path latency and interruption/failover control problem, not only a model-inference optimization task.
