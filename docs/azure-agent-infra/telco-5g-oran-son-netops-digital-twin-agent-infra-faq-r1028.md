# 电信 5G 核心网、O-RAN SON 与运营级 NetOps Agent 基础设施 FAQ（Cycle 2433）

## 1) 执行摘要
本轮聚焦运营商级 5G SA 与 Open RAN 运维自动化：通过 Operator Nexus 承载 CNF 与网元运行时，ADX 汇聚 PM/FM/CM 与 gNMI 流式遥测，NetOps Agent 在数字孪生沙箱内先做 YANG + Batfish 可达性验证，再进入环级金丝雀发布与自动回滚，目标是在不牺牲五个九 SLA 的前提下缩短故障定位与配置变更时延。

## 2) Q1 / Q2 / Q3
Q1：为什么必须区分 non-RT RIC 与 near-RT RIC，再与 LLM 推理链解耦？  
A1：RIC 控制回路存在严格时延边界（near-RT 10ms–1s），LLM 推理只能作为离线/近线建议，不可直接进入毫秒级闭环。  
Q2：如何避免 BGP/ACL 配置幻觉导致黑洞？  
A2：所有候选变更必须先通过 YANG 语义校验与 Batfish 可达性验证，未通过不得进入 commit-confirm。  
Q3：如何在 50,000+ 基站告警风暴中快速收敛根因？  
A3：以拓扑相关引擎聚合告警簇，先压缩噪声再定位共同故障域并驱动分层处置。

## 3) 运营商闭环流程（告警聚合→数字孪生验证→金丝雀发布→回滚）
```mermaid
flowchart LR
    A[3GPP and gNMI Alarm Storm] --> B[ADX Topology Correlator]
    B --> C[NetOps Agent Planner]
    C --> D[YANG and Batfish Digital Twin Verifier]
    D --> E[Canary Ring Commit-Confirm]
    E --> F[Sub-Minute KPI Auto-Rollback]
    F --> G[SLA and Audit Replay]
```

## 4) 决策矩阵：Nexus 混合 CNF+Agent vs 云端 OSS Agent vs 传统规则 SON
| 方案 | 时延控制 | 可靠性 | 自动化深度 | 运维复杂度 | 适配场景 |
|---|---:|---:|---:|---:|---|
| Nexus 混合 CNF+Agent | 最高 | 最高 | 高 | 高 | 运营商级生产核心网 |
| 云端 OSS Agent | 中 | 中高 | 中高 | 中 | 区域级/二级网优化 |
| 传统规则 SON | 中 | 中 | 低 | 低 | 保守增量改造 |

## 5) 电信 NetOps Agent 上线清单（含当日热点）
- near-RT 控制回路与 LLM 推理路径必须严格隔离。  
- 所有配置变更必须先过 YANG/Batfish 验证再进入发布。  
- 金丝雀发布必须绑定 KPI 自动回滚阈值。  
- 全链路审计需保留：候选配置、验证结果、发布轨迹、回滚证据。  
- 当日热点（抓取日：2026-11-16，官方/Release 优先）：  
  - Operator Nexus 在运营商级混合云与网络工作负载承载能力（`measured`）。  
  - ADX 对高吞吐遥测与拓扑相关分析的可行路径（`anonymized_reported`）。  
  - Batfish/YANG 预校验对配置事故阻断效果（`synthetic`）。

## 6) Good fit vs Not for 与百分比合约绑定
Good fit：  
1. 追求五个九 SLA、且必须在变更前可验证网络可达性的运营商。  
2. 需要在告警风暴中进行自动压缩、根因定位与可控发布回滚的 NOC 团队。

Not for：  
1. 无数字孪生预验证就直接下发网络配置的流程。  
2. 将 LLM 推理直接耦合到 near-RT 闭环的架构。

百分比合约绑定：
- `percentage_contract.invalid_config_block_rate_via_yang_batfish`
- `percentage_contract.alarm_storm_root_cause_mttr_improvement_rate`
- `percentage_contract.ran_offpeak_energy_savings_rate`
- `percentage_contract.network_slice_sla_compliance_rate`

以上键绑定 `cycle-2433-benchmark.json`，并标注 `production_validation=not_measured`。
