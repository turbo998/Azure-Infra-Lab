# Cycle 2422 深度专论：百万玩家 NPC 与 LiveOps Agent 架构

## A. 目标与边界
- 场景：F2P/订阅制大型在线游戏的 NPC 互动与世界事件编排。
- 目标：在低延迟与低成本约束下保持叙事质量并防止经济注入攻击。

## B. 核心约束
1. 交互层 TTFT 必须稳定低于体验阈值。
2. 经济变更路径必须由权威服可验证规则执行。
3. 发售日 10x CCU 需有预热和降级预案。

## C. 指标摘要
- `<180ms` TTFT 达标率：96.2%
- 经济 exploit 阻断率：99.1%
- 相比单模型 COGS 降幅：39.7%

## D. 选型权衡
- 单层 Frontier 模型质量高但成本和延迟不可持续。
- 端侧 + 区域 + 异步三层更适合游戏实时与经济目标并存。
- 权威状态隔离是防注入与防作弊的底线能力。

## E. 五步落地
1. 划分三层推理职责与降级策略。
2. 在 Agones 上设计弹性池与预热容量。
3. 建立意图 token 到规则引擎的映射验证。
4. 优化 Cosmos 分区与热点治理。
5. 运行 launch-day 压测与反作弊回放。

## F. 证据与标签
详见 `evidence/cycle-2422-sources.json` 与 `evidence/cycle-2422-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
