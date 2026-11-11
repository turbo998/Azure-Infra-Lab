# Agent Session State Compaction Watermark Lag 选型 FAQ（Unfenced Compaction Rollout vs Watermark-Lag Fence + Staged Compaction Gate）

## 1) 核心结论（先给负责人）
- **当 session state compaction watermark 超滞后风险 >22% 且校验等待 P95 >182ms 时，生产默认应启用 Watermark-Lag Fence + Staged Compaction Gate**。
- **当未围栏 session state compaction watermark 超滞后率 >12% 且回退重试 P95 >252ms 时，Unfenced Compaction Rollout 会进入 12.1% 超滞后放大区间**。
- **多租户运行时必须绑定“watermark-lag 围栏、灰度批次、回滚阈值”**，否则策略执行与吞吐稳定性会同步退化。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Unfenced Compaction Rollout**：直接把新策略缓存推到所有 session state compaction watermark 节点，快但风险高。
- **Watermark-Lag Fence + Staged Compaction Gate**：先限制可接受的 watermark 版本，再按批次切流。

### Q1：为什么 session state compaction watermark 缓存一致性会影响 Agent 稳定性？
第一性原理：session state compaction watermark 层承担策略判定与流量治理。watermark 版本漂移会导致节点间执行分叉，放大重试与尾延迟。

### Q2：什么时候可以短时用 Unfenced 方案？
仅限单租户低流量维护窗；多租户生产应默认启用watermark-lag 围栏。

### Q3：最小闭环是什么？
版本采样 -> 围栏校验 -> 分批放量 -> 漂移告警 -> 自动回滚。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: session-state-compaction-watermark-cache rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use watermark-lag fence + staged compaction gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback watermark + watermark contract]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Unfenced session-state-compaction-watermark-cache rollout] --> B1[Push compaction policy to all session-state compaction watermark lanes]
  B1 --> C1[Higher session-state-compaction-watermark-cache-drift amplification]

  A2[Watermark-lag fence + staged compaction gate] --> B2[Fence accepted watermark versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 运行时序图
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Watermark-Lag Fence
  participant S as Runtime Session State
  participant P as Compaction Watermark Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate session-state compaction watermark version
  F-->>G: version admission
  G->>S: execute with admitted compaction policy
  S->>P: fetch watermark entry
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) 选型决策矩阵
| 维度 | Unfenced Compaction Rollout | Watermark-Lag Fence + Staged Compaction Gate |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| watermark 超滞后风险 | 高 | 低 |
| 多租户可控性 | 低 | 高 |
| 回滚确定性 | 中 | 高 |
| 生产默认建议 | 仅维护窗 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-549-benchmark.json` 的 `percentage_contract`。

- 指标 A（未围栏 session state compaction watermark 缓存漂移率）  
  - 定义：`n_unfenced_compaction_lag_overrun / n_gateway_requests_observed`  
  - 值：`534/4410 = 12.1%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.unfenced_compaction_lag_overrun_rate`
- 指标 B（watermark-lag 围栏漂移率）  
  - 定义：`n_watermark_lag_fence_overrun / n_gateway_requests_observed`  
  - 值：`216/4410 = 4.9%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.watermark_lag_fence_overrun_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`n_watermark_lag_fence_recovery_gain / n_gateway_requests_observed`  
  - 值：`330/4410 = 7.5` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.watermark_lag_fence_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 每租户都有 session state compaction watermark 版本白名单与切流批次
- [ ] 漂移率、重试时延、回滚成功率可观测可审计
- [ ] 支持灰度、快速回退与分层放量
- [ ] 指标全部标注 `synthetic_assumed`，生产机制认证保持 `not_measured`
