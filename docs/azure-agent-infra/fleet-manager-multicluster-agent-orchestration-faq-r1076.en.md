# Round 1076 / Cycle 2481 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Kubernetes Fleet Manager multi-cluster/multi-region agent orchestration**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2481-benchmark.json`

## 1) Scenario objective

Core multi-region pains are uneven GPU/sandbox capacity, slow cross-region failover, and broad rollback blast radius during staged updates.  
Goal: use Fleet Manager ClusterResourcePlacement + MultiClusterService for capacity-weighted scheduling and staged rollback control.

## 2) Core formulas (scheduling / failover / rollback)

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

Recommended thresholds: `failover_rto_p95 < 90s`, `wave_rollback_impact < 0.2`.

## 3) Policy design (capacity-weighted + staged waves)

1. ClusterResourcePlacement ranks clusters by weighted capacity score.  
2. MultiClusterService handles active-standby regional endpoint switch.  
3. Rollout in 10%→30%→60% waves; rollback immediately on wave breach.

## 4) Runnable snippets (Bicep / YAML / KQL)

### 4.1 Bicep: Fleet Manager resource

```bicep
resource fleet 'Microsoft.ContainerService/fleets@2023-10-15' = {
  name: 'fleet-agent-global'
  location: resourceGroup().location
}
```

### 4.2 YAML: ClusterResourcePlacement policy

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

### 4.3 KQL: cross-region RTO and rollback impact

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

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2481-benchmark.json`):

- `unfenced_fleet_orchestration_guard_drift_rate = 534 / 4410 = 12.1%`
- `fleet_orchestration_guard_variance_rate = 216 / 4410 = 4.9%`
- `fleet_orchestration_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Multi-region, multi-cluster, multi-tenant agent platforms.  
- Need capacity-weighted scheduling with staged rollback governance.

**Not for**
- Single-cluster, single-region, small deployments.  
- Internal labs without cross-region DR requirements.
