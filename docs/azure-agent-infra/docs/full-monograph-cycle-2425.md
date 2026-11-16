# Cycle 2425 深度专论：法务/M&A 确定性 OOXML 红线 Agent 基础设施

## A. 目标与边界
- 场景：采购 MSA/DPA、并购 VDR 尽调与条款协商红线。
- 目标：在高吞吐场景下保持条款完整性、引用准确性与特权隔离。

## B. 核心约束
1. 禁止整文重写，必须按 span 级 OOXML patch 生成变更。
2. 每条引用都需回链到原段落/跨度证据。
3. Matter 级权限、索引与密钥必须严格隔离。

## C. 指标摘要
- untouched 条款完整性：100.0%
- 非标准 indemnity/LoL 召回率：92.4%
- 5,000 文档尽调时效提升：63.8%
- 引用精确率：98.6%

## D. 选型权衡
- 批处理 swarm 吞吐最高，适合并购尽调批量扫描。
- Word Add-in 交互深度最高，适合复杂谈判回合。
- CLM webhook triage 适合持续入件和优先级路由。

## E. 五步落地
1. 建立 matter 级特权域与独立检索索引。
2. 生成 clause-tree 与 cross-reference 图谱。
3. 用 playbook scorer 输出风险分层建议。
4. 仅输出 OOXML tracked-changes patch 并做 AST 校验。
5. 对低置信或高风险条款进入 GC/外部律师签核。

## F. 证据与标签
详见 `evidence/cycle-2425-sources.json` 与 `evidence/cycle-2425-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
