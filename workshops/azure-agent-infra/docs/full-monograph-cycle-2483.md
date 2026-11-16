# Cycle #2483 核心工程专著：Chaos + Load 多区域 Agent 韧性门禁（zh-CN）

- Round/Cycle: `1078 / 2483`
- Topic: `chaos-loadtest-multiregion-gameday-faq-r1078`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 目标

通过 Chaos Studio 与 Load Testing 联合演练，验证 AOAI/Cosmos/Sandbox 联合故障下的端到端恢复能力。

## 2) 关键公式

```text
required_vu = target_concurrent_streams * safety_factor
failover_rto_seconds = detect + switch + warmup
burn_rate = observed_error_ratio / allowed_error_ratio
```

阈值：
- `burn_rate_5m <= 2.0`
- `failover_rto_p95 < 90s`
- `stream_latency_p95 < 1200ms`

## 3) Runnable snippets（Bicep / YAML / Policy / KQL）

### Bicep

```bicep
resource loadTest 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: 'lt-agent-gameday'
}
```

### YAML

```yaml
gameday:
  waves: [0.1, 0.3, 0.6]
  faults: { aoai429Brownout: true, cosmosRegionalFailover: true, sandboxPodKill: true }
```

### Policy

```yaml
policy:
  if: { burnRate5mExceeded: true }
  then: { effect: rollback }
```

### KQL

```kql
GameDayResilienceMetrics
| where TimeGenerated > ago(30m)
| summarize burn5m=percentile(BurnRate5m,95), rto_p95=percentile(FailoverRtoSeconds,95) by Region, bin(TimeGenerated, 5m)
| where burn5m > 2 or rto_p95 > 90
```

## 4) 处置流程

1. 429 棕断升高：模型降级 + 跨区域分流。  
2. Cosmos failover 超时：冻结放量并进入只读降级。  
3. burn-rate 破线：回滚当前波次并暂停发布。

## 5) 结论

多区域 Agent 发布必须把 Chaos/Load 结果作为硬门禁输入，否则真实故障下会出现“局部恢复、全链路失效”的错觉。
