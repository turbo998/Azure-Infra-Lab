# APIM MCP Reentry Divergence Guard Lane Latency Bucket FAQ (Cycle 2151)

## 1) Three-minute decision
- **Core issue:** under reentry peaks with tenant-state divergence, latency-bucket recovery ordering drifts across tenants.
- **Recommendation:** deploy a closed loop of divergence guard lanes, latency-bucket allocation, tiered downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while bounding jitter and rollback blast radius during divergence windows.

## 2) Q1 / Q2 / Q3
### Q1: Why add a divergence guard lane?
1) unified throttling cannot constrain state-divergence skew,
2) divergence lanes isolate high-risk sessions and align recovery order first,
3) with latency buckets, capacity, validity, ordering, and divergence boundaries are jointly governed.

### Q2: How should production layering work?
- **Divergence guard layer:** map tenant class + state divergence into recovery lanes,
- **Allocation layer:** issue lane-scoped bucket credit and renewal windows,
- **Reclaim layer:** reclaim overdraft leases with anti-oscillation windows,
- **Downgrade layer:** trigger tiered downgrade and human replay queue during peaks.

### Q3: What is the go-live bar?
- unfenced drift rate keeps declining,
- divergence-lane variance remains stable and traceable,
- recovery gain (percentage points) stays reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Divergence Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Divergence-aware Recovery Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Divergence Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Divergence Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Divergence drift control | Medium | High |
| Cross-tenant jitter suppression | Medium | High |
| Divergence replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2151-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2151-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2151-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2151-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_divergenceguardlane_drift_rate`
  - `percentage_contract.reentry_divergenceguardlane_variance_rate`
  - `percentage_contract.reentry_divergenceguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Divergence-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is divergence-lane consistent.
- [ ] Divergence-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, divergence class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
