# APIM MCP Reentry Eviction Guard Lane Latency Bucket FAQ (Cycle 2149)

## 1) Three-minute decision
- **Core issue:** under reentry peaks with session eviction, latency-bucket recovery order can drift across tenants.
- **Recommendation:** deploy a closed loop of eviction guard lanes, latency-bucket allocation, tiered downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while bounding jitter and rollback blast radius during eviction windows.

## 2) Q1 / Q2 / Q3
### Q1: Why add an eviction guard lane?
1) unified throttling cannot constrain eviction-driven skew,
2) eviction lanes isolate high-risk recovery paths and cap spread,
3) with latency buckets, capacity, validity, order, and eviction boundary are jointly governed.

### Q2: How should production layering work?
- **Eviction guard layer:** map tenant class + eviction risk into recovery lanes,
- **Allocation layer:** issue lane-scoped bucket credit and renewal windows,
- **Reclaim layer:** reclaim overdraft leases with anti-oscillation windows,
- **Downgrade layer:** trigger tiered downgrade and human replay queue during peaks.

### Q3: What is the go-live bar?
- unfenced drift rate keeps declining,
- eviction-lane variance remains stable and traceable,
- recovery gain (percentage points) stays reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Eviction Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Eviction-aware Recovery Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Eviction Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Eviction Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Eviction-time propagation control | Medium | High |
| Cross-tenant jitter suppression | Medium | High |
| Eviction replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2149-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2149-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2149-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2149-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_evictionguardlane_drift_rate`
  - `percentage_contract.reentry_evictionguardlane_variance_rate`
  - `percentage_contract.reentry_evictionguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Eviction-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is eviction-lane consistent.
- [ ] Eviction-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, eviction class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
