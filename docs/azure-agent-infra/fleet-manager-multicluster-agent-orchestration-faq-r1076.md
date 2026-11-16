# Round 1076 / Cycle 2481 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Kubernetes Fleet Manager 多集群多区域 Agent 编排**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2481-benchmark.json`

## 1) 场景目标

多区域 Agent 平台的核心痛点：GPU/沙箱资源分布不均、跨区域故障切换慢、批量更新回滚影响面过大。  
目标：通过 Fleet Manager 的 ClusterResourcePlacement + MultiClusterService 建立容量加权调度与分波次发布回滚。

## 2) 核心公式（调度/切换/回滚）

```text
weighted_capacity_score =
  (gpu_free * gpu_weight) + (sandbox_slots_free * sandbox_weight) - (latency_ms * latency_penalty)
```

```text
failover_rto_seconds =
  health_detect_seconds + service_switch_seconds + warmup_seconds
```

```text
wave_rollback_impact =
  affected_sessions_in_wave / total_active_sessions
```

建议阈值：`failover_rto_p95 < 90s`，`wave_rollback_impact < 0.2`。

## 3) 策略设计（容量加权 + 分波次）

1. ClusterResourcePlacement 按容量分值做优先级调度。  
2. MultiClusterService 做主备区域切换。  
3. 发布按 10%→30%→60% 三波推进，任一波次异常即回滚。

## 4) 可运行片段（Bicep / YAML / KQL）

### 4.1 Bicep：Fleet Manager 资源

```bicep
resource fleet 'Microsoft.ContainerService/fleets@2023-10-15' = {
  name: 'fleet-agent-global'
  location: resourceGroup().location
}
```

### 4.2 YAML：ClusterResourcePlacement 规则

```yaml
apiVersion: placement.kubernetes-fleet.io/v1beta1
kind: ClusterResourcePlacement
metadata:
  name: agent-scheduler
spec:
  policy:
    placementType: PickN
    numberOfClusters: 3
```

### 4.3 KQL：跨区域 RTO 与回滚影响监控

```kql
FleetOrchestrationMetrics
| where TimeGenerated > ago(30m)
| summarize
    rto_p95=percentile(FailoverRtoSeconds,95),
    rollback_impact_p95=percentile(RollbackImpactRatio,95)
    by RegionPair, bin(TimeGenerated, 5m)
| where rto_p95 > 90 or rollback_impact_p95 > 0.2
| order by rto_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2481-benchmark.json`）：

- `unfenced_fleet_orchestration_guard_drift_rate = 534 / 4410 = 12.1%`
- `fleet_orchestration_guard_variance_rate = 216 / 4410 = 4.9%`
- `fleet_orchestration_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 多区域、多集群、多租户 Agent 平台。  
- 需要容量加权调度与渐进发布回滚控制。

**Not for**
- 单集群、单区域、小规模部署。  
- 无跨区域容灾诉求的内部实验环境。
