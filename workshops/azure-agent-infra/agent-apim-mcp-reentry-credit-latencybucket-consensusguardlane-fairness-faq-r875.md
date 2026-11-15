# Agent APIM/MCP 重入信用与延迟桶一致性护栏选型 FAQ（Cycle 2280）

## 1) 场景与约束
本轮聚焦 consensus guardlane（一致性护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持多路径决策一致性。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Consensus Guardlane]
    F --> G{Consensus vote stable?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：一致性护栏与证明护栏差异？
A1：证明护栏强调证据可验，一致性护栏强调多路径决策在重放与恢复中的稳定一致。

Q2：为什么一致性护栏必须覆盖重入信用账本？
A2：重入信用影响优先级与预算分配，不对齐一致性会导致租户间调度结果漂移。

Q3：如何控制一致性校验热路径成本？
A3：热路径仅校验 consensus_hash 与 vote_quorum，冷路径离线回放全链路投票轨迹。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需跨路径一致性的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2280-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_consensusguardlane_drift_rate`
- `percentage_contract.reentry_consensusguardlane_variance_rate`
- `percentage_contract.reentry_consensusguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2280 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 consensus_hash 与 fallback_reason。
2. 重入信用写入记录 vote_quorum 与 trace_id。
3. 延迟桶调度结果附加一致性投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建投票序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
