# Agent APIM/MCP 重入信用与延迟桶终态证明护栏选型 FAQ（Cycle 2295）

## 1) 场景与约束
本轮聚焦 terminalityproof guardlane（终态证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持终态可验证。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Terminalityproof Guardlane]
    F --> G{Terminality proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：终态证明护栏与状态收敛证明护栏差异？
A1：收敛证明关注过程收敛，终态证明强调最终状态满足合规终态条件且可核验。

Q2：为何终态证明必须绑定重入信用账本？
A2：重入信用控制最终执行资源配额，缺失终态证明会导致终态账本与执行快照不一致。

Q3：如何控制终态证明校验开销？
A3：热路径仅校验 terminality_hash 与 fallback_token，冷路径离线重放终态判定。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需终态证明的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2295-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_terminalityproofguardlane_drift_rate`
- `percentage_contract.reentry_terminalityproofguardlane_variance_rate`
- `percentage_contract.reentry_terminalityproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2295 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 terminality_hash 与 fallback_reason。
2. 重入信用写入记录 fallback_token 与 trace_id。
3. 延迟桶调度结果附加终态投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建终态判定序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
