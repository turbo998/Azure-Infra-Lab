# Agent APIM/MCP 重入信用与延迟桶对账证明护栏选型 FAQ（Cycle 2292）

## 1) 场景与约束
本轮聚焦 reconciliationproof guardlane（对账证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持账本与执行对账可验证。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Reconciliationproof Guardlane]
    F --> G{Reconciliation proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：对账证明护栏与回滚证明护栏差异？
A1：回滚证明强调逆向回退序列正确，对账证明强调信用账本与执行账本跨阶段一致。

Q2：为何对账证明必须绑定重入信用账本？
A2：重入信用是预算和优先级主账本，缺失对账证明会导致预算结余与执行记录偏差。

Q3：如何控制对账证明校验开销？
A3：热路径仅校验 reconciliation_hash 与 fallback_token，冷路径离线执行全量账本对账回放。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需对账证明的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2292-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_reconciliationproofguardlane_drift_rate`
- `percentage_contract.reentry_reconciliationproofguardlane_variance_rate`
- `percentage_contract.reentry_reconciliationproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2292 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 reconciliation_hash 与 fallback_reason。
2. 重入信用写入记录 fallback_token 与 trace_id。
3. 延迟桶调度结果附加对账投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建对账序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
