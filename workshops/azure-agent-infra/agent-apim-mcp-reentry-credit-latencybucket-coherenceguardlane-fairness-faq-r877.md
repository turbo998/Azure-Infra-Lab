# Agent APIM/MCP 重入信用与延迟桶相干护栏选型 FAQ（Cycle 2282）

## 1) 场景与约束
本轮聚焦 coherence guardlane（相干护栏）：在 APIM AI Gateway、MCP 工具编排、重入信用账本与延迟桶调度链路中，要求系统在突发、重试与回放阶段保持跨路径决策相干。

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Coherence Guardlane]
    F --> G{Coherence score stable?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1：相干护栏与仲裁证明护栏差异？
A1：仲裁证明关注投票可验，相干护栏关注多路径决策在回放中的一致相干程度。

Q2：为什么相干护栏必须覆盖重入信用账本？
A2：重入信用影响预算与优先级，不约束相干性会导致租户公平波动和回放偏差。

Q3：如何控制相干校验热路径成本？
A3：热路径仅校验 coherence_hash 与 drift_score，冷路径离线回放完整相干轨迹。

## 3) 选型建议（Good fit / Not for）
Good fit：多租户 SaaS Agent Gateway、Browser/CUA 集群、高合规零信任执行环境。
Not for：一次性脚本任务、无需跨路径相干性的临时实验、无租户公平约束的单机流程。

## 4) 可复现实验范围
实验数据见 `evidence/cycle-2282-benchmark.json`，覆盖冷启动/热恢复 P50/P95、并发吞吐、策略拦截率、单会话成本，并标注 measured/synthetic/anonymized_reported。

## 5) 百分比契约绑定（N/D）
- `percentage_contract.unfenced_reentry_coherenceguardlane_drift_rate`
- `percentage_contract.reentry_coherenceguardlane_variance_rate`
- `percentage_contract.reentry_coherenceguardlane_recovery_gain_pts`

以上键绑定本 FAQ 与 cycle-2282 证据，`production_validation=not_measured`。

## 6) 上线检查单
1. APIM 与 MCP 输出 coherence_hash 与 fallback_reason。
2. 重入信用写入记录 drift_score 与 trace_id。
3. 延迟桶调度结果附加相干投票哈希。
4. 预算耗尽请求进入降级与回放队列。
5. 回放工具支持按 trace_id 重建相干序列。
6. 日报保留 measured/synthetic/anonymized_reported 标签。
