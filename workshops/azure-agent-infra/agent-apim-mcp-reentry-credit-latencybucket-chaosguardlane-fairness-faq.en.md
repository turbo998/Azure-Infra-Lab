# APIM MCP Reentry Chaos Guard Lane Latency Bucket FAQ (Cycle 2147)

## 1) Three-minute decision
- **Core issue:** during reentry bursts with injected failures, latency-bucket recovery order drifts chaotically.
- **Recommendation:** deploy a closed loop of chaos guard lanes, latency-bucket allocation, peak downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while keeping fault-window recovery jitter replayable.

## 2) Q1 / Q2 / Q3
### Q1: Why add a chaos guard lane?
1) standard throttling cannot fully cover failure-injection skew,
2) chaos lanes isolate high-risk recovery paths and cap blast spread,
3) with latency buckets, capacity, validity, order, and fault domain are jointly controlled.

### Q2: How should production layering work?
- **Chaos guard layer:** map tenant/fault class into recovery lanes,
- **Allocation layer:** issue lane-scoped bucket credit and renewal windows,
- **Reclaim layer:** reclaim overdraft leases with anti-oscillation windows,
- **Downgrade layer:** trigger tiered downgrade and human intervention during peaks.

### Q3: What is the go-live bar?
- unfenced drift rate keeps declining,
- chaos-lane variance remains stable and traceable,
- recovery gain (percentage points) is reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Chaos Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Chaos-aware Recovery Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Chaos Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Chaos Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Fault propagation control | Medium | High |
| Cross-tenant jitter suppression | Medium | High |
| Chaos replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2147-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2147-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2147-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2147-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_chaosguardlane_drift_rate`
  - `percentage_contract.reentry_chaosguardlane_variance_rate`
  - `percentage_contract.reentry_chaosguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Chaos-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is chaos-lane consistent.
- [ ] Chaos-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, fault class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
