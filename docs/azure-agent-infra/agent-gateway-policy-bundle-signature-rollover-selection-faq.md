# Agent Gateway Policy Bundle Signature Rollover 选型 FAQ（Unfenced Policy-Signature Rollout vs Rollover Fence + Staged Signature Gate）

## 1) 核心结论（先给负责人）
- **当策略包签名失配风险 >23% 且网关校验等待 P95 >188ms 时，生产默认应启用 Rollover Fence + Staged Signature Gate**。
- **当未围栏策略签名发布失配率 >12% 且回退重试 P95 >258ms 时，Unfenced Policy-Signature Rollout 会进入 12.8% 失配放大区间**。
- **多租户网关策略升级必须绑定“签名轮转围栏、灰度批次、回滚阈值”**，否则路由一致性与审计可信度会同步退化。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Unfenced Policy-Signature Rollout**：直接把新签名策略包推到全部网关节点，快但风险高。
- **Rollover Fence + Staged Signature Gate**：先限制可接受签名版本，再按批次放量切换。

### Q1：为什么签名轮转会影响 Agent 稳定性？
第一性原理：每个路由决策都依赖策略签名验证。签名版本失配会导致节点间策略执行分叉，放大重试与尾时延。

### Q2：什么时候可以短时用 Unfenced 方案？
仅限单租户低流量维护窗；多租户生产应默认启用签名围栏轮转。

### Q3：最小闭环是什么？
版本采样 -> 围栏比对 -> 分批放量 -> 失配告警 -> 自动回滚。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: policy-signature rollout strategy?] --> B{Mismatch risk >23% OR verify wait P95 >188ms?}
  B -- Yes --> C[Use rollover fence + staged signature gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback watermark + policy contract]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Unfenced policy-signature rollout] --> B1[Push policy bundle to all gateways]
  B1 --> C1[Higher policy-signature mismatch amplification]

  A2[Rollover fence + staged gate] --> B2[Fence accepted signature versions then canary rollout]
  B2 --> C2[Lower mismatch risk with deterministic rollback]
```

### 3.3 运行时序图
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Rollover Fence
  participant P as Policy Verifier
  participant S as Signature Stream
  participant L as Audit Ledger
  C->>G: model/tool request
  G->>F: validate policy signature version
  F-->>G: version admission
  G->>P: evaluate policy bundle with admitted version
  P->>S: verify signature chain
  S-->>P: signature verdict
  G->>L: log mismatch/retry latency
  G-->>C: guarded response
```

## 4) 选型决策矩阵
| 维度 | Unfenced Policy-Signature Rollout | Rollover Fence + Staged Signature Gate |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 签名失配风险 | 高 | 低 |
| 多租户可控性 | 低 | 高 |
| 回滚确定性 | 中 | 高 |
| 生产默认建议 | 仅维护窗 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-547-benchmark.json` 的 `percentage_contract`。

- 指标 A（未围栏策略签名失配率）  
  - 定义：`n_unfenced_policy_signature_mismatch / n_gateway_requests_observed`  
  - 值：`565/4410 = 12.8%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.unfenced_policy_signature_mismatch_rate`
- 指标 B（轮转围栏失配率）  
  - 定义：`n_rollover_fence_mismatch / n_gateway_requests_observed`  
  - 值：`218/4410 = 4.9%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.rollover_fence_mismatch_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_rollover_fence - n_recovered_unfenced) / n_gateway_requests_observed`  
  - 值：`(4120-3779)/4410 = 7.7` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.rollover_fence_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 每租户都有策略签名版本白名单与切流批次
- [ ] 失配率、重试时延、回滚成功率可观测可审计
- [ ] 支持灰度、快速回退与分层放量
- [ ] 指标全部标注 `synthetic_assumed`，生产机制认证保持 `not_measured`
