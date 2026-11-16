# Cycle #2483 Core Engineering Monograph: Chaos + Load Multi-Region Agent Resilience Gate (en)

- Round/Cycle: `1078 / 2483`
- Topic: `chaos-loadtest-multiregion-gameday-faq-r1078`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Objective

Use combined Chaos Studio and Load Testing drills to validate end-to-end recovery under coupled AOAI/Cosmos/Sandbox failures.

## 2) Core formulas

```text
required_vu = target_concurrent_streams * safety_factor
failover_rto_seconds = detect + switch + warmup
burn_rate = observed_error_ratio / allowed_error_ratio
```

Thresholds:
- `burn_rate_5m <= 2.0`
- `failover_rto_p95 < 90s`
- `stream_latency_p95 < 1200ms`

## 3) Runnable snippets (Bicep / YAML / Policy / KQL)

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

## 4) Triage flow

1. 429 brownout rise: degrade model and shift traffic cross-region.  
2. Cosmos failover timeout: freeze rollout and enter read-only degrade mode.  
3. Burn-rate breach: rollback current wave and pause release.

## 5) Conclusion

Multi-region agent releases require chaos/load outputs as hard gates; otherwise partial recovery can mask full-chain instability.
