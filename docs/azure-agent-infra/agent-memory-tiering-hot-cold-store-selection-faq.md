# Agent Memory 分层存储选型 FAQ（仅热存储 vs 热冷分层）

## 1) 核心结论（先给负责人）
- **多租户生产默认采用“热冷分层记忆 + 检索预算门禁”**，不建议长期仅用热存储。
- **仅热存储在长会话与高并发工具调用下更容易触发记忆召回缺失**，放大重试和尾延迟成本。
- **记忆分层治理必须联动租户权限、网关策略和审计回放**，否则可用性与合规边界无法同时满足。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **仅热存储**：全部会话记忆保留在高性能层，响应快但容量与成本压力高。
- **热冷分层**：近期关键记忆在热层，长尾记忆下沉冷层按需回补，兼顾成本与召回。

### Q1：为什么仅热存储在生产有风险？
第一性原理：记忆访问的时间局部性和语义价值密度不均匀，全部堆在热层会导致淘汰抖动与召回缺口。

### Q2：什么时候可以接受仅热存储？
短会话、低并发、强模板化流程且可接受偶发人工回补时，可作为短期过渡策略。

### Q3：记忆分层治理的最小安全闭环是什么？
租户运行权限 -> 记忆基线策略 -> 价值采样与分层决策 -> 检索预算门禁 -> 召回失败回放与审计。

## 3) Mermaid（MCP 记忆分层治理闭环）
```mermaid
flowchart LR
  A[Session Memory Stream] --> B[Runtime Entitlement Gate]
  B --> C[Memory Baseline Policy]
  C --> D[Semantic Value Sampler]
  D --> E[Retrieval Budget Controller]
  E --> F[Memory Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) 决策矩阵
| 维度 | 仅热存储 | 热冷分层 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 长会话召回稳定性 | 低-中 | 高 |
| 召回缺失控制 | 低-中 | 高 |
| 多租户治理能力 | 中 | 高 |
| 生产默认建议 | 短期过渡 | 多租户长期运行 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证仍为 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-437-benchmark.json` 的 `percentage_contract`。

- 指标 A（召回缺失率，仅热存储）  
  - 定义：`n_recall_loss_hot_only / n_runtime_requests_observed`  
  - 值：`312/2400 = 13.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.fixed_hot_only_recall_loss_rate`
- 指标 B（召回缺失率，热冷分层）  
  - 定义：`n_recall_loss_tiered_hot_cold / n_runtime_requests_observed`  
  - 值：`92/2400 = 3.8%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.tiered_hot_cold_recall_loss_rate`
- 指标 C（恢复成功率提升，百分点）  
  - 定义：`(n_recovery_success_tiered - n_recovery_success_hot_only) / n_runtime_requests_observed`  
  - 值：`(2186-1874)/2400 = 13.0` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.memory_recall_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 记忆分层与检索预算策略含版本、灰度与回滚路径  
- [ ] 租户运行权限与检索预算门禁在网关层生效  
- [ ] 召回缺失率、恢复成功率与审计回放可追溯  
- [ ] 指标口径标注 `synthetic_assumed` 与分母/单位，生产机制认证保持 `not_measured`
