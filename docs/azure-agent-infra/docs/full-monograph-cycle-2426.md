# Cycle 2426 深度专论：科学发现 HPC Simulator-in-the-Loop Agent 基础设施

## A. 目标与边界
- 场景：材料发现、电池/冷却剂配方、小分子药物与半导体 EDA 研发环节。
- 目标：在计算成本可控前提下提升有效候选发现效率并保证物理验证可信。

## B. 核心约束
1. 候选谱系、检查点与仿真结果必须一一可追溯。
2. 物理不合理候选必须在 promotion 前被拒绝。
3. 长任务恢复能力应作为一等生产 SLO。

## C. 指标摘要
- 相比 brute-force GPU-h 降幅：96.8%
- AMLFS 检查点吞吐提升：214.0%
- 物理无效候选拒绝率：95.7%
- Slurm 长任务恢复可靠性：98.2%

## D. 选型权衡
- Kueue 适合容器化多队列并行探索。
- Slurm InfiniBand 在 MPI 重计算验证中优势显著。
- 多保真漏斗可显著降低总计算成本，但需要更严格的数据治理和状态管理。

## E. 五步落地
1. 建立候选 lineage 与实验 run-id 统一标识。
2. 先执行 surrogate 预筛，限定高价值样本进入 HPC。
3. 构建 AMLFS 检查点策略并演练抢占恢复。
4. 将物理有效性门禁前置到 promotion 之前。
5. 用主动学习回灌更新 surrogate 与采样策略。

## F. 证据与标签
详见 `evidence/cycle-2426-sources.json` 与 `evidence/cycle-2426-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
