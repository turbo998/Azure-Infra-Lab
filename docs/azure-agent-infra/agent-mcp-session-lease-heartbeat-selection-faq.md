# Agent MCP 会话租约心跳治理选型 FAQ（静态租约TTL vs 自适应心跳续租）

## 1) 核心结论（先给负责人）
- **多租户生产默认采用“自适应心跳续租 + 租约扩展预算”**，不建议长期固定静态租约TTL。
- **静态租约TTL在网络抖动或工具慢响应场景下更易触发会话误过期**，会放大重建开销与尾延迟。
- **租约心跳治理必须与租户权限、网关策略和审计回放联动**，否则稳定性与合规边界无法同时满足。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **静态租约TTL**：会话生命周期固定，到期即回收，实现简单但弹性不足。
- **自适应心跳续租**：根据会话活跃度和风险等级动态续租，减少误回收。

### Q1：为什么静态租约TTL在生产里有风险？
第一性原理：工具调用和网络延迟存在抖动，固定到期阈值会把瞬时波动误判为无活跃，导致会话提前失效。

### Q2：什么时候可以接受静态租约TTL？
单租户、任务时长短、网络稳定、且允许偶发重建会话时，可作为短期过渡方案。

### Q3：租约心跳治理的最小安全闭环是什么？
租户租约权限 -> TTL基线策略 -> 心跳采样与续租决策 -> 扩展预算门禁 -> 会话回收审计回放。

## 3) Mermaid（MCP 会话租约心跳治理闭环）
```mermaid
flowchart LR
  A[Session Request] --> B[Lease Entitlement Gate]
  B --> C[Base TTL Policy]
  C --> D[Heartbeat Sampler]
  D --> E[Lease Extension Budget Controller]
  E --> F[Session Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) 决策矩阵
| 维度 | 静态租约TTL | 自适应心跳续租 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 抗抖动能力 | 低 | 高 |
| 误过期控制能力 | 低-中 | 高 |
| 多租户治理能力 | 中 | 高 |
| 生产默认建议 | 短期过渡 | 多租户长期运行 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证仍为 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-432-benchmark.json` 的 `percentage_contract`。

- 指标 A（会话过期率，静态租约TTL）  
  - 定义：`n_expiry_static_ttl / n_sessions_observed`  
  - 值：`288/2400 = 12.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.static_lease_expiry_rate`
- 指标 B（会话过期率，自适应心跳续租）  
  - 定义：`n_expiry_adaptive_heartbeat / n_sessions_observed`  
  - 值：`86/2400 = 3.6%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.adaptive_heartbeat_expiry_rate`
- 指标 C（会话恢复成功率提升，百分点）  
  - 定义：`(n_recovery_success_adaptive - n_recovery_success_static) / n_sessions_observed`  
  - 值：`(2140-1938)/2400 = 8.4` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.lease_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] TTL基线与心跳续租策略含版本、灰度与回滚路径  
- [ ] 租户租约权限与扩展预算门禁在网关层生效  
- [ ] 会话过期、续租成功率与审计回放可追溯  
- [ ] 指标口径标注 `synthetic_assumed` 与分母/单位，生产机制认证保持 `not_measured`  
