# Agent APIM/MCP 重入信用与延迟桶证据闭环证明护栏选型 FAQ（Cycle 2297）

## 1) 场景与约束
本轮聚焦 evidenceclosureproof guardlane（证据闭环证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持证据闭环可验证。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Evidenceclosureproof Guardlane]
    F --> G{Evidence closure proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：证据闭环证明护栏与闭环证明护栏差异？
A1：闭环证明关注流程完备，证据闭环证明进一步要求每个环节具备可审计证据链。

Q2：为何证据闭环证明必须绑定重入信用账本？
A2：信用账本是重试与预算主线，缺证会导致账本变更无法在审计链中复原。

Q3：如何控制证据闭环证明校验开销？
A3：热路径仅校验 evidence_closure_hash 与 fallback_token，冷路径离线回放证据链。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需证据闭环证明的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2297-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_evidenceclosureproofguardlane_drift_rate`
- `percentage_contract.reentry_evidenceclosureproofguardlane_variance_rate`
- `percentage_contract.reentry_evidenceclosureproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2297 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 evidence_closure_hash 与 fallback_reason。
2. 重入信用写入记录 fallback_token 与 trace_id。
3. 延迟桶调度结果附加证据闭环投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建证据判定序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
