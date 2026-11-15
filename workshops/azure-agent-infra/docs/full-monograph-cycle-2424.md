# Cycle 2424 深度专论：自治 FinOps 与 IaC-First 修复 Agent

## A. 目标与边界
- 场景：多订阅企业云环境的成本回收、Rightsizing 与安全修复。
- 目标：在可审计条件下提升回收率并消除漂移事故。

## B. 核心约束
1. 成本归因必须可追溯到资源拓扑与利用率证据。
2. 变更只能通过 IaC PR，禁止资源平面直改。
3. 对有状态资源必须执行 what-if/plan 爆炸半径门禁。

## C. 指标摘要
- 月度云浪费回收率：31.6%
- what-if 破坏性变更捕获率：97.2%
- FinOps 审阅时长下降：41.8%
- IaC PR 路径漂移事故率：0

## D. 选型权衡
- 只读建议安全但回收速度慢。
- 自动停机策略回收更快但存在误伤风险。
- IaC PR Agent 综合最佳，代价是控制面验证时延上升。

## E. 五步落地
1. 统一 FOCUS 成本导出与维度规范。
2. 建立 ARG + 30 天 P99 利用率联合归因。
3. 接入 Git AST 定位器锁定 IaC 定义路径。
4. 强制 what-if/plan 拦截破坏性变更。
5. PR 审批后分阶段 rollout 并复盘回收收益。

## F. 证据与标签
详见 `evidence/cycle-2424-sources.json` 与 `evidence/cycle-2424-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
