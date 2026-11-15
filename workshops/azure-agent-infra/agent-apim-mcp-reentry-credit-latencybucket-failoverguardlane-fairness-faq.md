# APIM MCP 重入故障切换护栏延迟桶公平选型 FAQ（Cycle 2148）

## 1) 3 分钟结论
- **核心问题：** 重入高峰遇到多区域切换时，延迟桶恢复顺序容易失衡。
- **推荐方案：** “故障切换护栏车道 + 延迟桶配给 + 分级降档 + 审计回放”闭环治理。
- **目标：** 在租户公平前提下，保障故障切换窗口内的恢复吞吐与可解释性。

## 2) Q1 / Q2 / Q3
### Q1：为什么要引入 failover guard lane？
1) 常规限流无法覆盖跨区域切换造成的恢复偏斜；
2) 故障切换护栏可优先保护关键租户恢复车道；
3) 与延迟桶联动可同时约束额度、时效、顺序与切换边界。

### Q2：生产分层怎么设计？
- **故障切换护栏层：** 按租户等级与区域状态映射恢复车道；
- **配给层：** 车道内发放延迟桶额度与续租窗口；
- **回收层：** 对超额租约执行窗口化回收并抑制抖振；
- **降档层：** 峰值触发分级降档并进入人工复盘队列。

### Q3：上线判据是什么？
- 无护栏漂移率持续下降；
- 切换车道方差率稳定且可追踪；
- 恢复收益（percentage points）跨窗口可复现。

## 3) 架构图
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Failover Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Failover-aware Recovery Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Failover Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) 选型矩阵
| 维度 | 统一延迟桶 | Failover Guard Lane + Latency Bucket（推荐） |
|---|---:|---:|
| 切换期扩散控制 | 中 | 高 |
| 跨租户抖振抑制 | 中 | 高 |
| 切换回放可解释性 | 中 | 高 |
| 峰值降档稳定性 | 中 | 高 |
| 实施复杂度 | 中 | 中高 |

## 5) 数据证据与可复算算例（含 n 分母来源）
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-2148-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2148-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2148-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2148-cost.csv`
- 合同键：
  - `percentage_contract.unfenced_reentry_failoverguardlane_drift_rate`
  - `percentage_contract.reentry_failoverguardlane_variance_rate`
  - `percentage_contract.reentry_failoverguardlane_recovery_gain_pts`
- 标签：`measured / synthetic / anonymized_reported`。

## 6) 生产检查清单
- [ ] failover 护栏映射规则可按租户等级重放。
- [ ] 延迟桶授予/续租/回收与切换护栏一致。
- [ ] 峰值降档时切换优先车道无饥饿。
- [ ] 审计链路可关联策略版本、切换等级与恢复轨迹。
- [ ] FAQ/H5/SVG/7-card/evidence 的 cycle/topic 一致。
