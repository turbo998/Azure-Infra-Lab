# Agent APIM/MCP 重入信用与延迟桶完整性证明护栏选型 FAQ（Cycle 2283）

## 1) 场景与约束
本轮聚焦 integrityproof guardlane（完整性证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持数据与决策完整性可验证。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Integrityproof Guardlane]
    F --> G{Integrity proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：完整性证明护栏与相干护栏差异？
A1：相干护栏关注跨路径一致性，完整性证明护栏关注每条证据与决策是否可验且未被篡改。

Q2：为什么完整性证明护栏必须覆盖重入信用账本？
A2：重入信用驱动预算与优先级，若账本完整性无法证明，租户审计与故障复盘将失真。

Q3：如何控制完整性证明校验热路径成本？
A3：热路径仅校验 integrity_hash 与 proof_anchor，冷路径离线执行全链路完整性校验。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需完整性证明的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2283-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_integrityproofguardlane_drift_rate`
- `percentage_contract.reentry_integrityproofguardlane_variance_rate`
- `percentage_contract.reentry_integrityproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2283 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 integrity_hash 与 fallback_reason。
2. 重入信用写入记录 proof_anchor 与 trace_id。
3. 延迟桶调度结果附加完整性投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建完整性序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
