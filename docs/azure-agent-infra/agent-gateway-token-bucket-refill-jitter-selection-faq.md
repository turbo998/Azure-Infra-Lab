# Agent Gateway Token Bucket Refill 抖动选型 FAQ（Static Token Bucket Refill 策略 vs Jitter-Aware Token Bucket Refill + Burst Fence 策略）

## 1) 核心结论（先给负责人）
- **多租户 Agent Gateway 生产默认应选 Jitter-Aware Token Bucket Refill + Burst Fence 策略**，不建议长期采用一刀切 Static Token Bucket Refill。
- **Static Token Bucket Refill 在突发高并发阶段更容易把短期流量抖动放大为用户侧失败或超时**，导致成功率和尾延迟同时恶化。
- **令牌桶补充抖动控制必须联动租户配额、重试上限和观测告警**，否则网关路径会变成不可控成本放大器。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Static Token Bucket Refill 策略**：使用固定补充速率与固定突发窗口，逻辑简单但面对不均匀流量更脆弱。
- **Jitter-Aware Token Bucket Refill + Burst Fence 策略**：按租户/会话动态调整补充速率与突发栅栏，保证治理边界可审计。

### Q1：为什么 Static Token Bucket Refill 在高并发更容易放大失败？
第一性原理：请求突发天然不均匀；固定补充窗口会让热点租户过载、冷租户饿死，进而放大全局尾延迟。

### Q2：什么时候可以短期采用 Static Token Bucket Refill？
低价值请求、容错要求低、且更看重固定成本上限时可短期采用。

### Q3：最小安全闭环是什么？
请求分级 -> 补充预算分配 -> 准入门禁 -> 回放审计 -> 补充窗口再校准。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: Runtime sandbox token bucket refill jitter governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use jitter-aware token bucket refill + burst fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use static token bucket refill on low-priority lanes]
  D -- No --> F[Use adaptive refill-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Static token bucket refill] --> B1[Fixed refill quota + fixed burst window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Jitter-aware token bucket refill + burst fence] --> B2[Adaptive refill window by tenant/session]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 运行时序图
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Runtime Session Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive batch token bucket refill jitter step(s)
  F-->>G: batch token bucket refill jitter result + cost usage
  G->>L: write batch token bucket refill jitter chain + refill-window consumption
  G-->>C: response or fail with policy reason
```

## 4) 选型决策矩阵
| 维度 | Static Token Bucket Refill 策略 | Jitter-Aware Token Bucket Refill + Burst Fence 策略 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 超时风险控制 | 中-低 | 高 |
| 成本可控性 | 高（静态） | 中-高（动态） |
| 多租户可持续性 | 中 | 高 |
| 生产默认建议 | 仅低优先级通道 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-469-benchmark.json` 的 `percentage_contract`。  

- 指标 A（Static refill 超时率）  
  - 定义：`n_static_refill_timeout / n_runtime_requests_observed`  
  - 值：`286/2600 = 11.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.static_refill_timeout_rate`
- 指标 B（Jitter-aware refill 超时率）  
  - 定义：`n_jitter_aware_refill_timeout / n_runtime_requests_observed`  
  - 值：`146/2600 = 5.6%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.jitter_aware_refill_timeout_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_jitter_aware_refill - n_recovered_static_refill) / n_runtime_requests_observed`  
  - 值：`(2435-2314)/2600 = 4.7` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.refill_jitter_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] Runtime 沙箱令牌桶补充抖动策略具备版本、灰度和回滚路径
- [ ] 租户分层、预算消耗与重试上限可观测可审计
- [ ] 超时事件、恢复链路与失败回放可按租户追踪
- [ ] 指标全部标注 `synthetic_assumed`、分母与单位；生产机制认证保持 `not_measured`
