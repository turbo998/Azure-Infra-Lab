# APIM MCP 重入信用延迟桶血缘护栏公平选型 FAQ（Cycle 2210）

## 1) 3 分钟结论
- **核心问题：** 重入治理若缺少血缘护栏，公平决策虽可执行但难以证明来源一致性。
- **推荐方案：** 采用“血缘护栏车道 + 延迟桶信用控制 + 回放血缘账本”三段式闭环。
- **预期收益：** 在多租户高并发下同步提升恢复稳定性、可解释性与审计可信度。

## 2) Q1 / Q2 / Q3
### Q1：为什么 lineage guard lane 必须在线？
1) 仅离线日志无法约束实时回收策略；
2) 车道级血缘标识可把策略版本、租户水位和回退动作绑定；
3) 事故复盘可按血缘链逐段复算，避免口径漂移。

### Q2：生产分层如何落地？
- **入口层：** APIM Gateway 依据租户等级与策略版本分配血缘护栏车道；
- **控制层：** 延迟桶执行授予/续租/回收并记录 lineage id；
- **抑制层：** 风暴窗口执行分级降档与扩散阻断；
- **核验层：** 回放账本按 lineage id 还原调度路径。

### Q3：上线门槛是什么？
- 未加护栏失配率持续下降；
- 护栏方差率收敛到目标带宽；
- 恢复收益（percentage points）可从 evidence 文件复算。

## 3) 架构图
```mermaid
flowchart LR
  A[MCP Reentry Burst] --> B[APIM Lineage Guard Lane]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Recovery Scheduler]
  D --> E[Fallback / Downgrade Gate]
  E --> F[Priority Fairness Lane]
  E --> G[Standard Tenant Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay Ledger + Lineage Timeline]
```

## 4) 选型矩阵
| 维度 | 仅延迟桶 | Lineage Guard Lane + Latency Bucket（推荐） |
|---|---:|---:|
| 公平抖动收敛 | 中 | 高 |
| 策略血缘可追踪 | 低 | 高 |
| 租户扩散抑制 | 中 | 高 |
| 回退可解释性 | 中 | 高 |
| 实施复杂度 | 低 | 中高 |

## 5) 数据证据与可复算算例（含 n 分母来源）
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-2210-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2210-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2210-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2210-cost.csv`
- 合同键：
  - `percentage_contract.unfenced_reentry_lineageguardlane_drift_rate`
  - `percentage_contract.reentry_lineageguardlane_variance_rate`
  - `percentage_contract.reentry_lineageguardlane_recovery_gain_pts`
- 标签：`measured / synthetic / anonymized_reported`。

## 6) 生产检查清单
- [ ] 车道分配与策略版本血缘可回放。
- [ ] 授予/续租/回收事件与 lineage id 对齐。
- [ ] 降级窗口内优先车道无饥饿。
- [ ] 账本可关联租户、策略与执行路径。
- [ ] FAQ / H5 / SVG / 7-card / evidence 的 cycle 与 topic 严格一致。
