# Agent Runtime Memory Pressure Shedding 选型 FAQ（Fixed Hard-Memory Cap 策略 vs Adaptive Memory-Pressure Shedding + Quota Fence 策略）

## 1) 核心结论（先给负责人）
- **多租户 Agent Runtime 生产默认应选 Adaptive Memory-Pressure Shedding + Quota Fence 策略**，不建议长期采用一刀切 Fixed Hard-Memory Cap。
- **Fixed Hard-Memory Cap 在突发高并发阶段更容易把缓存抖动放大为用户侧失败或超时**，导致成功率和尾延迟同时恶化。
- **运行时内存压力削峰控制必须联动租户配额、重试上限和观测告警**，否则运行时路径会变成不可控成本放大器。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Fixed Hard-Memory Cap 策略**：使用固定缓存保留时长与固定压力窗口，逻辑简单但面对不均匀热度更脆弱。
- **Adaptive Memory-Pressure Shedding + Quota Fence 策略**：按租户/会话动态分配削峰预算，保证治理边界可审计。

### Q1：为什么 Fixed Hard-Memory Cap 在高并发更容易放大失败？
第一性原理：缓存热度天然不均匀；固定 TTL 窗口会让冷键滞留、热点键回收过慢，进而放大全局尾延迟。

### Q2：什么时候可以短期采用 Fixed Hard-Memory Cap？
低价值请求、容错要求低、且更看重固定成本上限时可短期采用。

### Q3：最小安全闭环是什么？
请求分级 -> 削峰预算分配 -> 准入门禁 -> 回放审计 -> 压力窗口再校准。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: Runtime sandbox runtime memory-pressure shedding governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive runtime memory pressure shedding + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed hard-memory cap on low-priority lanes]
  D -- No --> F[Use adaptive pressure-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Fixed hard-memory cap] --> B1[Fixed cache TTL + fixed pressure window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive runtime memory pressure shedding + quota fence] --> B2[Adaptive pressure window by tenant/session]
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
  G->>F: execute adaptive batch runtime memory-pressure shedding step(s)
  F-->>G: batch runtime memory-pressure shedding result + cost usage
  G->>L: write batch runtime memory-pressure shedding chain + pressure-window consumption
  G-->>C: response or fail with policy reason
```

## 4) 选型决策矩阵
| 维度 | Fixed Hard-Memory Cap 策略 | Adaptive Memory-Pressure Shedding + Quota Fence 策略 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 超时风险控制 | 中-低 | 高 |
| 成本可控性 | 高（静态） | 中-高（动态） |
| 多租户可持续性 | 中 | 高 |
| 生产默认建议 | 仅低优先级通道 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-477-benchmark.json` 的 `percentage_contract`。  

- 指标 A（Fixed hard-memory cap 超时率）  
  - 定义：`n_fixed_hard_cap_timeout / n_gateway_requests_observed`  
  - 值：`294/2800 = 10.5%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.fixed_hard_cap_timeout_rate`
- 指标 B（Adaptive runtime memory pressure shedding 超时率）  
  - 定义：`n_adaptive_shedding_timeout / n_gateway_requests_observed`  
  - 值：`151/2800 = 5.4%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.adaptive_shedding_timeout_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_adaptive_shedding - n_recovered_fixed_hard_cap) / n_gateway_requests_observed`  
  - 值：`(2649-2506)/2800 = 5.1` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.adaptive_shedding_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] Runtime 沙箱运行时内存压力削峰策略具备版本、灰度和回滚路径
- [ ] 租户分层、预算消耗与重试上限可观测可审计
- [ ] 超时事件、恢复链路与失败回放可按租户追踪
- [ ] 指标全部标注 `synthetic_assumed`、分母与单位；生产机制认证保持 `not_measured`
