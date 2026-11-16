# Agent APIM/MCP 重入信用与延迟桶可追溯护栏选型 FAQ（Cycle 2277）

## 1) 场景与约束
本轮聚焦 traceability guardlane（可追溯护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持可追溯决策谱系。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Traceability Guardlane]
    F --> G{Replay lineage complete?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：可追溯护栏与确定性护栏差异？
A1：确定性强调输出可复算，可追溯强调从请求到策略到执行的链路证据完整可回放。

Q2：为什么可追溯必须覆盖重入信用账本？
A2：重入信用决定预算消耗与调度优先级，不记录谱系会导致故障归因与租户申诉无法闭环。

Q3：如何控制可追溯校验热路径成本？
A3：热路径校验 lineage_id 与 decision_hash 完整性，冷路径离线执行全链路证据拼装。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需审计追溯的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2277-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_traceabilityguardlane_drift_rate`
- `percentage_contract.reentry_traceabilityguardlane_variance_rate`
- `percentage_contract.reentry_traceabilityguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2277 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 lineage_id 与 fallback_reason。
2. 重入信用写入记录 decision_hash 与 trace_id。
3. 延迟桶调度结果附加谱系链路哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建证据序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
