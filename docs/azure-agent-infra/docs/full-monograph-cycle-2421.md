# Cycle 2421 深度专论：GreenOps 与 Agent Fleet 能效优化

## A. 目标与边界
- 场景：多区域 GPU Agent 集群需兼顾体验、成本与碳披露。
- 目标：将碳感知调度与算法降耗落地为任务级可审计体系。

## B. 核心约束
1. 交互式负载必须满足延迟 SLO，不可盲目追求最低碳。
2. 异步负载应优先低碳时段和低碳 region。
3. 所有优化动作须能映射到 `$` 与 `gCO2e` 的可追溯账本。

## C. 指标摘要
- 每 10K 任务碳减排：34.6%
- idle GPU 浪费清除：78.3%
- `$` + `gCO2e` 联合下降：22.8%

## D. 选型权衡
- 仅做功耗 cap 易牺牲响应体验且收益有限。
- 仅做调度迁移无法挖掘模型侧降耗空间。
- “调度 + 功耗 + 算法”联合优化才能稳定达成双目标。

## E. 五步落地
1. 建立任务级碳强度与能耗采集面。
2. 实施交互/异步双类调度策略。
3. 落地 TDP cap + MIG + scale-to-zero。
4. 部署 quantization + KV cache + cascade。
5. 建立 FinOps 与 CarbonOps 联合看板与审计。

## F. 证据与标签
详见 `evidence/cycle-2421-sources.json` 与 `evidence/cycle-2421-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
