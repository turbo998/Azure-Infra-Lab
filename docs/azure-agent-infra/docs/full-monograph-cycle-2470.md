# Cycle #2470 核心工程专著：多天 HITL 编排成本与回放（zh-CN）

- Round/Cycle: `1065 / 2470`
- Topic: `durable-task-scheduler-dapr-temporal-continueasnew-tco-faq-r1065`

## 1) 关键公式

```text
replay_ms = event_count * avg_deserialize_ms + state_rehydrate_ms
continue_as_new_when = event_count >= 20000 or replay_ms >= 600
tco_per_1k = compute_cost + storage_history_cost + ops_cost
```

阈值：
- `replay_p95_ms <= 800`
- `event_history_p95 <= 20000`

## 2) Runnable snippets

### Bicep（历史存储骨架）

```bicep
resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stworkflowhist'
}
```

### YAML（回放阈值）

```yaml
workflow:
  maxReplayEvents: 20000
  continueAsNewReplayMs: 600
```

### Python（ContinueAsNew 逻辑）

```python
if events >= 20000 or replay_ms >= 600:
    ctx.continue_as_new({"events": 0})
```

### KQL（回放排障）

```kql
WorkflowOrchestrationLogs
| where TimeGenerated > ago(30m)
| summarize replay_p95=percentile(ReplayMs,95), hist_p95=percentile(EventHistoryCount,95) by Engine
| where replay_p95 > 800 or hist_p95 > 20000
```

## 3) 失效模式

1. 历史膨胀导致回放时间线性恶化。  
2. ContinueAsNew 阈值过高导致实例肥大。  
3. 多天等待占用热状态导致成本抬升。  
4. 引擎混用缺乏分层导致运维复杂度上升。

## 4) 落地清单

- 回放与历史阈值纳入 SLO。  
- 按工作流类别绑定编排引擎。  
- 长等待节点事件外存化。  
- 周期性重算 DTS/Dapr/Temporal TCO 拐点。
