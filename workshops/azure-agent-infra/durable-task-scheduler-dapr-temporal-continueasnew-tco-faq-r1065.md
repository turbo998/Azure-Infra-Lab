# Round 1065 / Cycle 2470 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure Durable Task Scheduler (DTS) vs Dapr Workflow vs Temporal（AKS）：多天 HITL 编排、事件回放压缩、ContinueAsNew 与 TCO 拐点**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2470-benchmark.json`

## 1) Executive Summary

本轮面向多天人机协同 Agent 编排：历史事件膨胀、回放变慢、长期实例成本失控。  
核心结论：**事件回放压缩 + `ContinueAsNew` 阈值 + 编排引擎分层选型** 是稳定运行关键。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2470-sources.json`）

## 3) 核心公式（回放 / 压缩 / 成本）

### Q1: 事件回放时间预算

```text
replay_ms = event_count * avg_deserialize_ms + state_rehydrate_ms
```

目标：`replay_p95_ms <= 800`（超出则必须压缩历史）。

### Q2: ContinueAsNew 触发阈值

```text
continue_as_new_when = event_count >= event_threshold or replay_ms >= replay_threshold
```

建议：`event_threshold=20k`, `replay_threshold=600ms`。

### Q3: TCO 拐点

```text
tco_per_1k = compute_cost + storage_history_cost + ops_cost
crossover = min(tco_dts, tco_dapr, tco_temporal) under p95 and durability SLO
```

## 4) Runnable snippets（Bicep / YAML / Python / KQL）

### 4.1 Bicep（调度器与存储）

```bicep
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stworkflowhist'
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
}
```

### 4.2 YAML（Dapr/Temporal worker 参数）

```yaml
workflow:
  maxReplayEvents: 20000
  continueAsNewReplayMs: 600
  checkpointInterval: 300
```

### 4.3 Python（Durable `continue_as_new` 伪代码）

```python
def orchestrator(ctx):
    state = ctx.get_input() or {"events": 0}
    state["events"] += 1
    if state["events"] >= 20000 or ctx.current_replay_ms() >= 600:
        ctx.continue_as_new({"events": 0})
    return state
```

### 4.4 KQL（回放与成本排障）

```kql
WorkflowOrchestrationLogs
| where TimeGenerated > ago(30m)
| summarize replay_p95=percentile(ReplayMs,95),
            hist_p95=percentile(EventHistoryCount,95),
            tco_per_1k=avg(TcoPer1kUsd)
            by Engine, WorkflowClass
| where replay_p95 > 800 or hist_p95 > 20000
| order by replay_p95 desc, hist_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2470-benchmark.json -> percentage_contract`）：

- `unfenced_workflow_replay_compaction_tco_guard_drift_rate = 534 / 4410 = 12.1%`
- `workflow_replay_compaction_tco_guard_variance_rate = 216 / 4410 = 4.9%`
- `workflow_replay_compaction_tco_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（多天编排引擎）

| 引擎 | 回放效率 | 运维复杂度 | 生态集成 | 成本可控 | 推荐 |
|---|---:|---:|---:|---:|---|
| DTS | 高 | 中 | 高（Azure） | 中高 | Azure 原生优先 |
| Dapr Workflow | 中高 | 中 | 高（云原生） | 中 | 轻量多环境 |
| Temporal on AKS | 高 | 高 | 高（复杂编排） | 中高 | 大规模复杂流 |

## 7) Production failure-triage checklist

1. `replay_p95_ms > 800`：优先执行历史压缩/分段。  
2. `hist_p95 > 20k`：强制 `ContinueAsNew`。  
3. 成本异常：拆分编排类别，按 SLA 分层引擎。  
4. 长等待人审超时：事件外存并缩短热状态驻留。  
5. 重放抖动：检查序列化版本兼容与 schema 演进。
