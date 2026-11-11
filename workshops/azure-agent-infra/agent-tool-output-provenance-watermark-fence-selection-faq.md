# Agent Tool Output Provenance Watermark Fence 选型 FAQ（Unfenced Provenance Rollout vs Watermark Fence + Staged Provenance Gate）

## 1) 核心结论（先给负责人）
- **当工具输出溯源失配比例 >24% 且验证等待 P95 >195ms 时，生产默认应启用 Watermark Fence + Staged Provenance Gate**。
- **当未围栏溯源发布失配率 >13% 且回退重试 P95 >265ms 时，Unfenced Provenance Rollout 会进入 13.0% 失配放大区间**。
- **多租户工具编排必须绑定“水印围栏、灰度批次、回滚阈值”**，否则证据链与策略拦截会同时失稳。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **Unfenced Provenance Rollout**：直接把新溯源规则推到全部网关节点，快但风险高。
- **Watermark Fence + Staged Provenance Gate**：先限制可接受的溯源水印版本，再分批切流。

### Q1：为什么溯源水印版本会影响 Agent 可靠性？
第一性原理：工具输出要经过策略与审计双重校验。水印版本失配会让同请求在不同节点出现不同鉴定结果，放大重试与尾时延。

### Q2：什么时候可以短时用 Unfenced 方案？
仅限单租户低流量维护窗；多租户生产场景应默认使用水印围栏。

### Q3：最小闭环是什么？
版本采样 -> 围栏比对 -> 分批放量 -> 失配告警 -> 自动回滚。

## 3) Mermaid（决策树 / 路径对比 / 时序）
### 3.1 选型决策树
```mermaid
flowchart TD
  A[Start: provenance rollout strategy?] --> B{Mismatch ratio >24% OR verify wait P95 >195ms?}
  B -- Yes --> C[Use watermark fence + staged provenance gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced provenance rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback watermark + evidence contract]
```

### 3.2 路径对比图
```mermaid
flowchart LR
  A1[Unfenced provenance rollout] --> B1[Push provenance policy to all nodes]
  B1 --> C1[Higher provenance-mismatch amplification]

  A2[Watermark fence + staged gate] --> B2[Fence accepted watermark versions then canary rollout]
  B2 --> C2[Lower mismatch risk with deterministic rollback]
```

### 3.3 运行时序图
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Watermark Fence
  participant T as Tool Runtime
  participant P as Provenance Stream
  participant L as Audit Ledger
  C->>G: tool request
  G->>F: validate provenance watermark version
  F-->>G: version admission
  G->>T: execute tool with admitted watermark policy
  T->>P: emit output provenance record
  P-->>G: provenance verdict
  G->>L: log mismatch/retry latency
  G-->>C: guarded response
```

## 4) 选型决策矩阵
| 维度 | Unfenced Provenance Rollout | Watermark Fence + Staged Provenance Gate |
|---|---|---|
| 实现复杂度 | 低 | 中 |
| 溯源失配风险 | 高 | 低 |
| 多租户可控性 | 低 | 高 |
| 回滚确定性 | 中 | 高 |
| 生产默认建议 | 仅维护窗 | 长期默认 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证保持 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-545-benchmark.json` 的 `percentage_contract`。

- 指标 A（未围栏溯源失配率）  
  - 定义：`n_unfenced_provenance_mismatch / n_gateway_requests_observed`  
  - 值：`573/4410 = 13.0%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.unfenced_provenance_mismatch_rate`
- 指标 B（水印围栏失配率）  
  - 定义：`n_watermark_fence_mismatch / n_gateway_requests_observed`  
  - 值：`229/4410 = 5.2%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.watermark_fence_mismatch_rate`
- 指标 C（恢复增益，百分点）  
  - 定义：`(n_recovered_watermark_fence - n_recovered_unfenced) / n_gateway_requests_observed`  
  - 值：`(4098-3765)/4410 = 7.6` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.watermark_fence_recovery_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 每租户都有溯源水印版本白名单与切流批次
- [ ] 失配率、重试时延、回滚成功率可观测可审计
- [ ] 支持灰度、快速回退与分层放量
- [ ] 指标全部标注 `synthetic_assumed`，生产机制认证保持 `not_measured`
