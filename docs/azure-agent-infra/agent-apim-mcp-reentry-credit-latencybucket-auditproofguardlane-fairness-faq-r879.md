# Agent APIM/MCP 重入信用与延迟桶审计证明护栏选型 FAQ（Cycle 2284）

## 1) 场景与约束
本轮聚焦 auditproof guardlane（审计证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持审计证据完整可验。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Auditproof Guardlane]
    F --> G{Audit proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：审计证明护栏与完整性证明护栏差异？
A1：完整性证明关注数据未篡改，审计证明进一步关注证据链在审计场景下可追责与可复核。

Q2：为什么审计证明护栏必须覆盖重入信用账本？
A2：重入信用影响预算与优先级，若账本审计证明不足，将导致跨租户纠纷难以定责。

Q3：如何控制审计证明校验热路径成本？
A3：热路径仅校验 audit_hash 与 proof_anchor，冷路径离线执行全链路审计回放。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需审计证明的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2284-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_auditproofguardlane_drift_rate`
- `percentage_contract.reentry_auditproofguardlane_variance_rate`
- `percentage_contract.reentry_auditproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2284 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 audit_hash 与 fallback_reason。
2. 重入信用写入记录 proof_anchor 与 trace_id。
3. 延迟桶调度结果附加审计投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建审计序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
