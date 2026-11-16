# Round 1073 / Cycle 2478 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**ACS Call Automation + Azure OpenAI Realtime Voice Agent Infra**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2478-benchmark.json`

## 1) 场景目标

语音 Agent 生产可用性的关键是端到端 mouth-to-ear 延迟和打断响应。  
目标：在 ACS 呼叫编排 + Realtime WebRTC/WebSocket 链路下，实现低延迟、可打断、可故障切换。

## 2) 核心公式（时延/竞态/切换）

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

建议阈值：`mouth_to_ear_p95 < 900ms`，`barge_in_race_window_p95 < 180ms`。

## 3) 策略设计（语音链路治理）

1. 首选 WebRTC 低抖动路径，WebSocket 作为退化通道。  
2. VAD 命中后立即下发 cancel，清空未播报缓存。  
3. 区域故障时按 TURN/PSTN SIP 预案做主动切换。

## 4) 可运行片段（Bicep / YAML / KQL）

### 4.1 Bicep：ACS 资源

```bicep
resource acs 'Microsoft.Communication/communicationServices@2023-04-01' = {
  name: 'acs-voice-agent'
  location: 'global'
}
```

### 4.2 YAML：语音链路配置

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

### 4.3 KQL：口到耳与打断窗口监控

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

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2478-benchmark.json`）：

- `unfenced_voice_agent_guard_drift_rate = 534 / 4410 = 12.1%`
- `voice_agent_guard_variance_rate = 216 / 4410 = 4.9%`
- `voice_agent_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 需要语音实时交互与可打断体验的客户服务 Agent。  
- 需要跨区域 TURN/SIP 容灾切换能力。

**Not for**
- 仅文本交互、无实时语音 SLA 的场景。  
- 无统一呼叫/媒体观测链路的系统。
