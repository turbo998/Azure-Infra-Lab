# Cycle 2423 深度专论：企业联络中心实时语音 Agent 与 PCI 隔离架构

## A. 目标与边界
- 场景：10,000 并发通话规模的企业联络中心（IVR + 人工坐席）。
- 目标：在语音体验、运营效率与支付合规之间取得稳定平衡。

## B. 核心约束
1. Mouth-to-Ear 延迟与 barge-in 体验不能随并发上升失控。
2. Warm transfer 过程中上下文不得丢失关键业务状态。
3. PCI 支付段必须媒体隔离，敏感卡数据不得进入模型。

## C. 指标摘要
- Mouth-to-Ear P95 SLA 达标率：94.8%
- Barge-in 打断准确率：93.6%
- Live Whisper Assist 带来的 AHT 降幅：28.4%

## D. 选型权衡
- 原生 S2S：延迟更低，适合高并发自助通道。
- STT-LLM-TTS：可审计性更强，适合强监管问询和留痕。
- 人工 Whisper-only：控制最强但成本与时延最高，适合高敏业务。

## E. 五步落地
1. 先定义语音路径分流策略（S2S 与级联切换规则）。
2. 建立 ACS 并发与媒体通道容量基线。
3. 完成 Warm transfer 上下文协议与异常回退。
4. 对支付流程启用 DTMF 屏蔽与录音 pause/resume。
5. 联合验证延迟、Containment、AHT 与 PCI 控制指标。

## F. 证据与标签
详见 `evidence/cycle-2423-sources.json` 与 `evidence/cycle-2423-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
