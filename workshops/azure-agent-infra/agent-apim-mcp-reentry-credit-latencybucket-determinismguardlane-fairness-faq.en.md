# APIM MCP Reentry Determinism Guard Lane Latency Bucket FAQ (Cycle 2171)

## 1) Three-minute decision
- **Core issue:** during reentry peaks, execution determinism drift amplifies fairness deviation and rollback spread.
- **Recommendation:** run a closed loop of determinism guard lanes, latency-bucket allocation, fallback downgrade gates, and replay accountability.
- **Goal:** under multi-tenant fairness constraints, shrink determinism-drift windows and rollback amplification cost.

## 2) Q1 / Q2 / Q3
### Q1: Why add a determinism guard lane?
1) unified throttling cannot separate determinism risk classes,
2) determinism lanes isolate high-risk reentry flows during policy transitions,
3) with latency buckets, credit, ordering, and determinism boundaries are jointly bounded.

### Q2: How should production layering work?
- **Determinism guard layer:** map tenant tier + determinism signature into recovery lanes,
- **Allocation layer:** manage lane-scoped bucket credit, renewal, and reclaim windows,
- **Reclaim layer:** reclaim overdraft leases while suppressing spread,
- **Downgrade layer:** trigger fallback downgrade at peak with accountable replay evidence.

### Q3: What is the go-live bar?
- unfenced determinism drift keeps shrinking,
- lane variance remains stable and explainable,
- recovery gain (percentage points) is reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Determinism Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Determinism-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Determinism Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay + Accountability Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Determinism Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Determinism drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay accountability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2171-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2171-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2171-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2171-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_determinismguardlane_drift_rate`
  - `percentage_contract.reentry_determinismguardlane_variance_rate`
  - `percentage_contract.reentry_determinismguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Determinism-lane mapping is tenant-tier replayable.
- [ ] Bucket grant/renew/reclaim is determinism-lane consistent.
- [ ] Determinism-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, determinism signature, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
