# Cycle 1756 专题：跨区 PTU 溢出与 APIM 智能回退

## 摘要
本章聚焦主区 PTU 突增时如何通过 APIM 实现可审计的跨区溢出与回切，目标是在不牺牲关键租户 SLA 的前提下控制延迟和成本拖尾。

## 设计要点
1. 触发条件采用容量+延迟+异常率联合门控；
2. 溢出采取 canary 分级放量，避免一次性切流；
3. 回切使用 failback window，防止抖动导致来回切换。

## 证据与验证
引用 `cycle-1756` 的 latency/throughput/policy/cost 证据集，结合 validation7 校验链确认口径一致。
