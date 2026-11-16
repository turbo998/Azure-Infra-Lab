# Cycle 2435 专著增补（汽车 SDV Agent 基础设施）

- Cycle 编号：2435
- 时间窗口：2026-11-16 23:00 ~ 2026-11-17 05:15
- 主题：automotive-sdv-incabin-voice-mqtt-fleet-diagnostics-agent-infra-faq-r1030

## Chapter 574 · SDV 混合语音与车队诊断控制平面

本章沉淀汽车 SDV 生产架构关键原语：
1. 车端 SLM + 云端回退的混合语音链路，保障弱网场景连续性。
2. MQTT v5 控制面治理，支撑百万车辆 mTLS 持久连接与重连风暴抑制。
3. ADX 诊断关联分析支撑 DTC 分诊与服务工位调度。
4. 对 ADAS/动力总成总线执行硬隔离，禁止 LLM/Agent 直接写路径。
5. OTA 通过审批闸门、证据回放与回滚控制闭环执行。
