# Agent Runtime Wasm 组件缓存预热治理选型 FAQ（固定预热池 vs 自适应预热池）

## 1) 核心结论（先给负责人）
- **多租户生产默认采用“自适应预热池 + 峰值预算门禁”**，不建议长期使用固定预热池。
- **固定预热池在突发冷启动或慢工具初始化场景下更易触发预热未命中**，会放大冷启动回补与尾延迟。
- **预热治理必须与租户权限、网关策略和审计回放联动**，否则稳定性与合规边界无法同时满足。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **固定预热池**：预热实例固定且不随压力变化，简单但弹性不足。
- **自适应预热池**：按实时压力动态调节窗口和节流强度，降低预热未命中。

### Q1：为什么固定预热池在生产里有风险？
第一性原理：组件请求速率和初始化时延持续波动，固定预热容量在突发时更容易出现未命中，触发额外冷启动与排队放大。

### Q2：什么时候可以接受固定预热池？
单租户、低并发、负载平稳且可接受偶发丢弃重试时，可作为短期过渡方案。

### Q3：预热治理的最小安全闭环是什么？
租户运行权限 -> 预热池基线策略 -> 冷启动采样与容量调节 -> 峰值预算门禁 -> 未命中与回放审计。

## 3) Mermaid（MCP Wasm 组件缓存预热治理闭环）
```mermaid
flowchart LR
  A[Wasm Component Request] --> B[Runtime Entitlement Gate]
  B --> C[Base Prewarm-Pool Policy]
  C --> D[Cold-Start Sampler]
  D --> E[Burst Budget Controller]
  E --> F[Runtime Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) 决策矩阵
| 维度 | 固定预热池 | 自适应预热池 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 突发吸收能力 | 低 | 高 |
| 预热未命中控制能力 | 低-中 | 高 |
| 多租户治理能力 | 中 | 高 |
| 生产默认建议 | 短期过渡 | 多租户长期运行 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证仍为 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-434-benchmark.json` 的 `percentage_contract`。

- 指标 A（预热未命中率，固定预热池）  
  - 定义：`n_miss_fixed_prewarm / n_runtime_requests_observed`  
  - 值：`312/2400 = 13.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.fixed_prewarm_miss_rate`
- 指标 B（预热未命中率，自适应预热池）  
  - 定义：`n_miss_adaptive_prewarm / n_runtime_requests_observed`  
  - 值：`92/2400 = 3.8%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.adaptive_prewarm_miss_rate`
- 指标 C（恢复成功率提升，百分点）  
  - 定义：`(n_recovery_success_adaptive - n_recovery_success_fixed) / n_runtime_requests_observed`  
  - 值：`(2186-1874)/2400 = 13.0` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.prewarm_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 预热池容量与调节策略含版本、灰度与回滚路径  
- [ ] 租户运行权限与峰值预算门禁在网关层生效  
- [ ] 预热未命中率、恢复成功率与审计回放可追溯  
- [ ] 指标口径标注 `synthetic_assumed` 与分母/单位，生产机制认证保持 `not_measured`  
