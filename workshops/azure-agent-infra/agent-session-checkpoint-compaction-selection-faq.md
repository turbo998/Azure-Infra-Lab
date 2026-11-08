# Agent Session 检查点压缩策略选型 FAQ（全量快照链 vs 增量 Delta 检查点链）

## 1) 核心结论（先给负责人）
- **多租户生产默认采用“增量 Delta 检查点链 + 周期性全量锚点”**，不建议长期只用全量快照链。
- **全量快照链在长会话、频繁工具调用和跨区恢复场景下更容易放大恢复失败与尾延迟成本**。
- **检查点治理必须与租户权限、网关策略和审计回放联动**，否则恢复一致性和合规边界无法同时满足。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **全量快照链**：每次保存完整会话状态，简单但写放大与存储成本高。
- **增量 Delta 检查点链**：仅保存变化片段并按锚点回放，恢复效率和成本更可控。

### Q1：为什么全量快照链在生产里有风险？
第一性原理：会话状态体积与工具结果波动叠加时，持续全量写入会推高 I/O 与重放窗口，导致恢复路径更脆弱。

### Q2：什么时候可以接受全量快照链？
单租户、短会话、状态小且恢复频次低的场景可作为短期过渡方案。

### Q3：检查点治理的最小安全闭环是什么？
租户运行权限 -> 检查点基线策略 -> 变更采样与压缩决策 -> 峰值预算门禁 -> 恢复失败与回放审计。

## 3) Mermaid（MCP 会话检查点治理闭环）
```mermaid
flowchart LR
  A[Session State Mutation] --> B[Runtime Entitlement Gate]
  B --> C[Checkpoint Baseline Policy]
  C --> D[Delta Sampler]
  D --> E[Burst Budget Controller]
  E --> F[Checkpoint Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) 决策矩阵
| 维度 | 全量快照链 | 增量 Delta 检查点链 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 长会话恢复能力 | 低-中 | 高 |
| 恢复失败率控制 | 低-中 | 高 |
| 多租户治理能力 | 中 | 高 |
| 生产默认建议 | 短期过渡 | 多租户长期运行 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证仍为 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-435-benchmark.json` 的 `percentage_contract`。

- 指标 A（恢复失败率，全量快照链）  
  - 定义：`n_resume_fail_fixed_snapshot / n_runtime_requests_observed`  
  - 值：`312/2400 = 13.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.fixed_snapshot_resume_failure_rate`
- 指标 B（恢复失败率，增量 Delta 检查点链）  
  - 定义：`n_resume_fail_delta_checkpoint / n_runtime_requests_observed`  
  - 值：`92/2400 = 3.8%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.delta_checkpoint_resume_failure_rate`
- 指标 C（恢复成功率提升，百分点）  
  - 定义：`(n_resume_success_delta - n_resume_success_fixed) / n_runtime_requests_observed`  
  - 值：`(2186-1874)/2400 = 13.0` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.checkpoint_resume_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 检查点压缩与锚点轮换策略含版本、灰度与回滚路径  
- [ ] 租户运行权限与峰值预算门禁在网关层生效  
- [ ] 恢复失败率、恢复成功率与审计回放可追溯  
- [ ] 指标口径标注 `synthetic_assumed` 与分母/单位，生产机制认证保持 `not_measured`  
