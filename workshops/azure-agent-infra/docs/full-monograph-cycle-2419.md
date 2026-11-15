# Cycle 2419 深度专论：实时风控双速分诊（Hot Path + Async Investigation）

## A. 目标与边界
- 场景：支付授权、反欺诈、AML 与账户接管防护。
- 目标：在保持授权链路 P99 小于 50ms 的同时提升捕获率并降低误杀摩擦。

## B. 核心约束
1. 热路径不允许不可预测推理阻塞授权链路。
2. 灰区调查必须具备 SAR 可解释和审计追踪。
3. Step-Up 与拒付/追回经济模型需可量化调优。

## C. 指标摘要
- 授权 P99 < 50ms 达标率：96.9%
- 误杀摩擦下降：31.2%
- SAR 调查时长节省：48.7%

## D. 选型权衡
- 纯规则热路径延迟低但捕获上限明显。
- Inline ML + 微模型在延迟与效果之间提供较优平衡。
- 异步调查 swarm 增加复杂度，但可显著提升深度调查效率与合规质量。

## E. 五步落地
1. 建立热路径毫秒级预算与回退策略。
2. 接入 Event Hubs/Fabric + Redis 特征窗口。
3. 部署 ONNX/TensorRT 模型与微模型联合评分。
4. 构建异步调查 swarm（图谱分析 + SAR 草拟 + Step-Up）。
5. 以捕获率/摩擦/吞吐三目标持续优化阈值策略。

## F. 证据与标签
详见 `evidence/cycle-2419-sources.json` 与 `evidence/cycle-2419-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
