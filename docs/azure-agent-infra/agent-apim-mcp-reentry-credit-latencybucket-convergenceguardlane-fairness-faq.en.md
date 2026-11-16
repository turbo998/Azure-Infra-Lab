# APIM MCP Reentry Convergence Guard Lane Latency Bucket FAQ (Cycle 2172)

## 1) Three-minute decision
- **Core issue:** during reentry peaks, concurrent policy paths cause convergence drift, amplifying fairness deviation and rollback spread.
- **Recommendation:** run a closed loop of convergence guard lanes, latency-bucket allocation, fallback downgrade gates, and replay accountability.
- **Goal:** under multi-tenant fairness constraints, shrink convergence-drift windows and rollback amplification cost.

## 2) Q1 / Q2 / Q3
### Q1: Why add a convergence guard lane?
1) unified throttling cannot separate convergence risk classes,
2) convergence lanes isolate high-risk reentry flows during policy transitions,
3) with latency buckets, credit, ordering, and convergence boundaries are jointly bounded.

### Q2: How should production layering work?
- **Convergence guard layer:** map tenant tier + convergence signature into recovery lanes,
- **Allocation layer:** manage lane-scoped bucket credit, renewal, and reclaim windows,
- **Reclaim layer:** reclaim overdraft leases while suppressing spread,
- **Downgrade layer:** trigger fallback downgrade at peak with accountable replay evidence.

### Q3: What is the go-live bar?
- unfenced convergence drift keeps shrinking,
- lane variance remains stable and explainable,
- recovery gain (percentage points) is reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Convergence Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Convergence-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Convergence Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay + Accountability Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Convergence Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Convergence drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay accountability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2172-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2172-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2172-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2172-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_convergenceguardlane_drift_rate`
  - `percentage_contract.reentry_convergenceguardlane_variance_rate`
  - `percentage_contract.reentry_convergenceguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Convergence-lane mapping is tenant-tier replayable.
- [ ] Bucket grant/renew/reclaim is convergence-lane consistent.
- [ ] Convergence-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, convergence signature, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
