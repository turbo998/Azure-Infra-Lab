# Agent 跨区域会话重放选型 FAQ（Cycle 1795）

## 1) 3 分钟结论
- **跨区高可用的难点不是“有没有副本”，而是“副本恢复后能否可验证地重放会话状态”。**
- **推荐：** 主区顺序日志 + 次区增量快照 + 版本化重放策略与幂等校验。
- **目标：** 在区域故障时快速恢复对话连续性，并避免重复执行副作用。

## 2) 关键问题（Q1/Q2/Q3）
### Q1：为什么仅做异步复制还不够？
1) 复制延迟导致状态断层；
2) 工具调用副作用可能被重复触发；
3) 缺少重放语义会让结果不可解释。

### Q2：生产可落地方案？
- 主区记录有序事件日志（含幂等键）；
- 次区维护时间点快照与增量日志；
- 恢复时先定位快照，再按版本规则重放；
- 外部副作用操作走“重放白名单+幂等确认”。

### Q3：如何验证有效？
- RTO/RPO 满足既定目标；
- 重放后业务状态一致率提升；
- 重放期间重复副作用率可控。

## 3) 架构图
```mermaid
flowchart LR
  P[Primary Region Runtime] --> L[Ordered Session Log]
  L --> S[Cross-Region Replication]
  S --> R[Replica Snapshot + Delta]
  R --> E[Replay Engine]
  E --> C[Idempotent Side-effect Controller]
  C --> A[Audit Ledger]
```

## 4) 选型矩阵
| 维度 | 仅异步复制 | 快照+增量重放（推荐） |
|---|---:|---:|
| 恢复确定性 | 低 | 高 |
| 副作用可控性 | 低 | 高 |
| RTO/RPO 表现 | 中 | 高 |
| 实施复杂度 | 低 | 中 |
| 审计可解释性 | 中 | 高 |

## 5) 证据与复算口径
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-1795-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1795-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1795-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1795-policy.csv`
- 标签：`measured / synthetic / anonymized_reported`。
- validation7：双语结构、CSP 自包含、证据轮次一致、回放链路校验通过。

## 6) 生产检查清单
- [ ] 主区会话日志有全局顺序与版本号。
- [ ] 次区快照与增量日志保留窗口清晰。
- [ ] 重放白名单覆盖副作用类工具调用。
- [ ] 幂等键冲突与回滚路径可观测。
- [ ] FAQ/H5/SVG/7-card 与 evidence 轮次一致。
