# Cycle #2481 核心工程专著：Fleet 多集群 Agent 编排（zh-CN）

- Round/Cycle: `1076 / 2481`
- Topic: `fleet-manager-multicluster-agent-orchestration-faq-r1076`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 工程目标

在多区域多集群场景下，同时控制容量利用率、切换时延和回滚影响面。

## 2) 关键公式

```text
weighted_capacity_score = gpu_free*gpu_w + sandbox_free*sandbox_w - latency_ms*penalty
failover_rto_seconds = detect + switch + warmup
wave_rollback_impact = affected_sessions / total_active_sessions
```

阈值：
- `rto_p95 < 90s`
- `rollback_impact < 0.2`

## 3) Runnable snippets（Bicep / YAML / KQL）

### Bicep

```bicep
resource fleet 'Microsoft.ContainerService/fleets@2023-10-15' = {
  name: 'fleet-agent-global'
}
```

### YAML

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
spec:
  policy:
    placementType: PickN
    numberOfClusters: 3
```

### KQL

```kql
FleetOrchestrationMetrics
| where TimeGenerated > ago(30m)
| summarize rto_p95=percentile(FailoverRtoSeconds,95), rollback_impact_p95=percentile(RollbackImpactRatio,95) by RegionPair, bin(TimeGenerated, 5m)
| where rto_p95 > 90 or rollback_impact_p95 > 0.2
```

## 4) 处置流程

1. 低容量集群降权，提升可用区权重。  
2. 切换超时时优先回切健康区域。  
3. 波次异常即停止发布并回滚当前波次。

## 5) 结论

多集群编排的稳定性来自“容量加权调度 + 分波次发布 + 快速回滚”组合，而非单一调度规则。
