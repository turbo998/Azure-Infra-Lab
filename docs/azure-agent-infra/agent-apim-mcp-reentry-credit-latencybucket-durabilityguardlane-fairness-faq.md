# APIM MCP 重入耐久性护栏延迟桶公平选型 FAQ（Cycle 2161）

## 1) 3 分钟结论
- **核心问题：** 重入峰值与策略抖动叠加时，恢复链路出现耐久性漂移与公平退化。
- **推荐方案：** “耐久性护栏车道 + 延迟桶配给 + 退化旁路 + 回放审计”闭环治理。
- **目标：** 在租户公平前提下，压缩耐久性漂移窗口并降低回退放大风险。

## 2) Q1 / Q2 / Q3
### Q1：为什么需要 durability guard lane？
1) 统一限流无法隔离耐久性风险等级；
2) 耐久性护栏可阻断高风险策略扩散并优先保障关键恢复路径；
3) 与延迟桶联动可同时控制额度、时效、顺序与耐久性边界。

### Q2：生产分层如何落地？
- **耐久性护栏层：** 按租户等级与耐久性状态映射恢复车道；
- **配给层：** 车道内分配延迟桶额度与续租窗口；
- **回收层：** 对超额租约执行窗口化回收并抑制扩散；
- **降档层：** 峰值触发旁路降档并进入人工复盘。

### Q3：上线判据是什么？
- 无护栏漂移率持续下降；
- 护栏车道方差率稳定且可追溯；
- 恢复收益（percentage points）跨窗口可复现。

## 3) 架构图
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Durability Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Durability-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Durability Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) 选型矩阵
| 维度 | 统一延迟桶 | Durability Guard Lane + Latency Bucket（推荐） |
|---|---:|---:|
| 耐久性漂移控制 | 中 | 高 |
| 跨租户扩散抑制 | 中 | 高 |
| 回放可解释性 | 中 | 高 |
| 峰值降档稳定性 | 中 | 高 |
| 实施复杂度 | 中 | 中高 |

## 5) 数据证据与可复算算例（含 n 分母来源）
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-2161-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2161-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2161-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2161-cost.csv`
- 合同键：
  - `percentage_contract.unfenced_reentry_durabilityguardlane_drift_rate`
  - `percentage_contract.reentry_durabilityguardlane_variance_rate`
  - `percentage_contract.reentry_durabilityguardlane_recovery_gain_pts`
- 标签：`measured / synthetic / anonymized_reported`。

## 6) 生产检查清单
- [ ] durability 护栏映射可按租户等级重放。
- [ ] 延迟桶授予/续租/回收与耐久性护栏一致。
- [ ] 峰值降档时耐久性优先车道无饥饿。
- [ ] 审计链路可关联策略版本、耐久性等级与恢复轨迹。
- [ ] FAQ/H5/SVG/7-card/evidence 的 cycle/topic 一致。
