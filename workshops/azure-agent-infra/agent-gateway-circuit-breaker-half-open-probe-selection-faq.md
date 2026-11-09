# Agent Gateway 熔断器 Half-Open 探测选型 FAQ（Static Open-Loop Retry 策略 vs Circuit Breaker Half-Open Probe + Failure Fence 策略）

## 1) 核心结论（先给负责人）
- **多租户 Agent Gateway 生产默认应选 Circuit Breaker Half-Open Probe + Failure Fence 策略**，不建议长期采用一刀切 Static Open-Loop Retry。
- **Static Open-Loop Retry 在突发高并发阶段更容易把短期流量抖动放大为用户侧失败或超时**，导致成功率和尾延迟同时恶化。
- **熔断器 Half-Open 探测控制必须联动租户配额、重试上限和观测告警**，否则网关路径会变成不可控成本放大器。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Static Open-Loop Retry 策略**：使用固定重试节奏与固定突发窗口，逻辑简单但面对不均匀流量更脆弱。
- **Circuit Breaker Half-Open Probe + Failure Fence 策略**：按租户/会话动态探测并恢复流量，保证治理边界可审计。

### Q1：为什么 Static Open-Loop Retry 在高并发更容易放大失败？
第一性原理：请求突发天然不均匀；固定补充窗口会让热点租户过载、冷租户饿死，进而放大全局尾延迟。

### Q2：什么时候可以短期采用 Static Open-Loop Retry？
低价值请求、容错要求低、且更看重固定成本上限时可短期采用。

### Q3：最小安全闭环是什么？
请求分级 -> 探测预算分配 -> 准入门禁 -> 回放审计 -> Half-Open 窗口再校准。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: Runtime sandbox circuit breaker half-open probe governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use circuit breaker half-open probe + failure fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use static open-loop retry on low-priority lanes]
  D -- No --> F[Use adaptive half-open-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Static open-loop retry] --> B1[Fixed retry quota + fixed burst window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Circuit breaker half-open probe + failure fence] --> B2[Adaptive half-open window by tenant/session]
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
  G->>F: execute adaptive batch circuit breaker half-open probe step(s)
  F-->>G: batch circuit breaker half-open probe result + cost usage
  G->>L: write batch circuit breaker half-open probe chain + half-open-window consumption
  G-->>C: response or fail with policy reason
```

## 4) 选型决策矩阵
| 维度 | Static Open-Loop Retry 策略 | Circuit Breaker Half-Open Probe + Failure Fence 策略 |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 超时风险控制 | 中-低 | 高 |
| 成本可控性 | 高（静态） | 中-高（动态） |
| 多租户可持续性 | 中 | 高 |
| 生产默认建议 | 仅低优先级通道 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-470-benchmark.json` 的 `percentage_contract`。  

- 指标 A（Static open-loop 超时率）  
  - 定义：`n_static_open_loop_timeout / n_runtime_requests_observed`  
  - 值：`286/2600 = 11.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.static_open_loop_timeout_rate`
- 指标 B（Half-open probe 超时率）  
  - 定义：`n_half_open_probe_timeout / n_runtime_requests_observed`  
  - 值：`146/2600 = 5.6%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.half_open_probe_timeout_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_half_open_probe - n_recovered_static_open_loop) / n_runtime_requests_observed`  
  - 值：`(2435-2314)/2600 = 4.7` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.half_open_probe_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] Runtime 沙箱熔断器 Half-Open 探测策略具备版本、灰度和回滚路径
- [ ] 租户分层、预算消耗与重试上限可观测可审计
- [ ] 超时事件、恢复链路与失败回放可按租户追踪
- [ ] 指标全部标注 `synthetic_assumed`、分母与单位；生产机制认证保持 `not_measured`
