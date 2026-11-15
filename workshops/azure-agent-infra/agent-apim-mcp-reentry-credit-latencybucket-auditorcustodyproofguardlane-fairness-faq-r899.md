# Agent APIM/MCP 重入信用与延迟桶审计员托管闭环证明护栏选型 FAQ（Cycle 2304）

## 1) 场景与约束
本轮聚焦 auditorcustodyproof guardlane（审计员托管闭环证明护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持审计员托管闭环可验证。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Auditorcustodyproof Guardlane]
    F --> G{Auditor custody proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：审计员托管闭环证明护栏与操作者托管闭环证明护栏差异？
A1：操作者托管强调执行主体链，审计员托管强调复核主体、审计签核边界与责任交接可核验。

Q2：为何审计员托管闭环必须绑定重入信用账本？
A2：信用扣减与回放复核需要审计责任锚点，缺失闭环会导致重入账本审计不可判定。

Q3：如何控制审计员托管闭环校验开销？
A3：热路径仅校验 auditor_custody_hash 与 fallback_token，冷路径离线重建审计员托管序列。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需审计员托管闭环的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2304-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_auditorcustodyproofguardlane_drift_rate`
- `percentage_contract.reentry_auditorcustodyproofguardlane_variance_rate`
- `percentage_contract.reentry_auditorcustodyproofguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2304 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 auditor_custody_hash 与 fallback_reason。
2. 重入信用写入记录 fallback_token 与 trace_id。
3. 延迟桶调度结果附加审计员托管投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建审计员托管判定序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
