# APIM MCP 重入可恢复性护栏延迟桶公平选型 FAQ（Cycle 2176）

## 1) 3 分钟结论
- **核心问题：** 重入高峰与策略抖动叠加时，可恢复性不足会放大公平偏移与回退扩散。
- **推荐方案：** 采用“可恢复性护栏车道 + 延迟桶信用配给 + 退化旁路 + 回放审计”闭环。
- **目标：** 在多租户公平约束下缩短故障恢复窗口并降低扩散半径。

## 2) Q1 / Q2 / Q3
### Q1：为什么需要 recoverability guard lane？
1) 统一限流无法区分恢复能力分层；
2) 可恢复性护栏可将高风险重入流隔离到受控车道；
3) 与延迟桶联动后可同时约束信用消耗、恢复顺序与失败半径。

### Q2：生产分层如何部署？
- **可恢复性护栏层：** 按租户等级与恢复签名映射恢复车道；
- **信用配给层：** 车道内实施延迟桶授予、续租与回收；
- **抑制层：** 对突发超额租约执行窗口化回收并阻断传播；
- **降级层：** 峰值触发旁路降档并保留可追责回放证据。

### Q3：上线门槛是什么？
- 无护栏可恢复性漂移率持续下降；
- 可恢复性车道方差率稳定且可解释；
- 恢复收益（percentage points）跨窗口可复算。

## 3) 架构图
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Recoverability Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Recoverability-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Recoverability Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay + Accountability Timeline]
```

## 4) 选型矩阵
| 维度 | 统一延迟桶 | Recoverability Guard Lane + Latency Bucket（推荐） |
|---|---:|---:|
| 可恢复性漂移控制 | 中 | 高 |
| 跨租户扩散抑制 | 中 | 高 |
| 回放可追责性 | 中 | 高 |
| 峰值降档稳定性 | 中 | 高 |
| 实施复杂度 | 中 | 中高 |

## 5) 数据证据与可复算算例（含 n 分母来源）
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-2176-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2176-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2176-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2176-cost.csv`
- 合同键：
  - `percentage_contract.unfenced_reentry_recoverabilityguardlane_drift_rate`
  - `percentage_contract.reentry_recoverabilityguardlane_variance_rate`
  - `percentage_contract.reentry_recoverabilityguardlane_recovery_gain_pts`
- 标签：`measured / synthetic / anonymized_reported`。

## 6) 生产检查清单
- [ ] recoverability 护栏映射可按租户等级回放。
- [ ] 延迟桶授予/续租/回收与可恢复性护栏策略一致。
- [ ] 峰值降档时可恢复性优先车道无饥饿现象。
- [ ] 审计链路可关联策略版本、恢复签名与执行轨迹。
- [ ] FAQ/H5/SVG/7-card/evidence 的 cycle/topic 严格一致。
