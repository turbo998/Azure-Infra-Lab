# Cycle #2478 核心工程专著：实时语音 Agent 链路（ACS + Realtime）（zh-CN）

- Round/Cycle: `1073 / 2478`
- Topic: `acs-realtime-voice-agent-infra-faq-r1073`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 工程目标

保障语音 Agent 的低延迟、可打断、可切换三项体验基线。

## 2) 关键公式

```text
mouth_to_ear_p95_ms = capture + encode + uplink + infer + tts + downlink + jitter
barge_in_race_window_ms = vad_detect + cancel_signal + playback_buffer
failover_cutover_ms = health_detect + turn_rebind + sip_reinvite
```

阈值：
- `m2e_p95 < 900ms`
- `barge_in_p95 < 180ms`

## 3) Runnable snippets（Bicep / YAML / KQL）

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

## 4) 处置流程

1. m2e 超阈值：优先切回 WebRTC 主路径并收紧 jitter buffer。  
2. 打断竞态升高：降低播放缓存并提前 cancel。  
3. 区域故障：执行 TURN/SIP 切换并限制非关键呼叫。

## 5) 结论

实时语音质量取决于整链路预算管理与打断/容灾联动，而非单点模型推理优化。
