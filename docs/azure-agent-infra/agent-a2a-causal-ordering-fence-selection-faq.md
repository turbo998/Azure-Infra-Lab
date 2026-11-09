# Agent A2A 因果顺序栅栏选型 FAQ（Strict FIFO Queue 策略 vs Causal Ordering Fence + Idempotent Replay 策略）

## 1) 核心结论（先给负责人）
- **多租户 Agent Gateway 生产默认应选 Causal Ordering Fence + Idempotent Replay 策略**，不建议长期采用一刀切 Strict FIFO Queue。
- **Strict FIFO Queue 在工具 A2A 并发乱序阶段更容易把短期乱序抖动放大为用户侧失败或超时**，导致成功率和尾延迟同时恶化。
- **A2A 因果顺序栅栏必须联动租户配额、重试上限和观测告警**，否则排序链路会变成不可控成本放大器。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Strict FIFO Queue 策略**：请求严格按单队列顺序串行处理，不允许跨分区并行重排。
- **Causal Ordering Fence + Idempotent Replay 策略**：按租户与会话键做因果分区，配合幂等回放实现并发有序执行。

### Q1：为什么 Strict FIFO Queue 在高并发更容易放大失败？
第一性原理：并发系统天然会出现乱序到达；如果只靠全局 FIFO 串行化，会把慢分区阻塞扩散到全局，触发队列堆积与超时放大。

### Q2：什么时候可以短期采用 Strict FIFO Queue？
低价值请求、容错要求低、且更看重固定成本上限时可短期采用。

### Q3：最小安全闭环是什么？
请求分级 -> 因果分区与栅栏分配 -> 准入门禁 -> 幂等回放审计 -> 排序窗口再校准。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: Gateway causal ordering governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use causal ordering fence + idempotent replay]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use strict FIFO queue on low-priority lanes]
  D -- No --> F[Use adaptive ordering-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Strict FIFO queue] --> B1[Single global queue]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Causal ordering fence + idempotent replay] --> B2[Partitioned ordering window by tenant/session]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 运行时序图
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Causal Ordering Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive causal ordering step(s)
  F-->>G: causal ordering result + cost usage
  G->>L: write causal ordering chain + ordering-window consumption
  G-->>C: response or fail with policy reason
```

## 4) 选型决策矩阵
| 维度 | Strict FIFO Queue 策略 | Causal Ordering Fence + Idempotent Replay 策略 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 超时风险控制 | 中-低 | 高 |
| 成本可控性 | 高（静态） | 中-高（动态） |
| 多租户可持续性 | 中 | 高 |
| 生产默认建议 | 仅低优先级通道 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-464-benchmark.json` 的 `percentage_contract`。  

- 指标 A（Primary-only 超时率）  
  - 定义：`n_primary_only_timeout / n_runtime_requests_observed`  
  - 值：`286/2600 = 11.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.primary_only_timeout_rate`
- 指标 B（Causal ordering fence 超时率）  
  - 定义：`n_adaptive_causal-ordering_timeout / n_runtime_requests_observed`  
  - 值：`146/2600 = 5.6%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.adaptive_causal ordering_timeout_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_adaptive_causal-ordering - n_recovered_primary_only) / n_runtime_requests_observed`  
  - 值：`(2435-2314)/2600 = 4.7` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.causal-ordering_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] A2A 因果顺序栅栏策略具备版本、灰度和回滚路径
- [ ] 租户分层、预算消耗与重试上限可观测可审计
- [ ] 超时事件、排序链路与失败回放可按租户追踪
- [ ] 指标全部标注 `synthetic_assumed`、分母与单位；生产机制认证保持 `not_measured`
