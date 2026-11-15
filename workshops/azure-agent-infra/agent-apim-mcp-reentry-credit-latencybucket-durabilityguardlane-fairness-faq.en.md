# APIM MCP Reentry Durability Guard Lane Latency Bucket FAQ (Cycle 2161)

## 1) Three-minute decision
- **Core issue:** with reentry peaks and policy oscillation, recovery paths show durability drift and fairness decay.
- **Recommendation:** implement a closed loop of durability guard lanes, latency-bucket allocation, fallback downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while shrinking durability-drift windows and rollback amplification.

## 2) Q1 / Q2 / Q3
### Q1: Why add a durability guard lane?
1) unified throttling cannot separate durability volatility risk classes,
2) durability lanes block spread from high-risk policy changes and protect critical recovery paths,
3) with latency buckets, credit, validity, ordering, and durability boundaries are jointly bounded.

### Q2: How should production layering work?
- **Durability guard layer:** map tenant class + durability state into recovery lanes,
- **Allocation layer:** issue lane-scoped bucket credit and renewal windows,
- **Reclaim layer:** reclaim overdraft leases with anti-propagation windows,
- **Downgrade layer:** trigger fallback downgrade and human replay at peak.

### Q3: What is the go-live bar?
- unfenced drift keeps declining,
- guard-lane variance remains stable and traceable,
- recovery gain (percentage points) stays reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Durability Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Durability-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Durability Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Durability Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Durability drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2161-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2161-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2161-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2161-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_durabilityguardlane_drift_rate`
  - `percentage_contract.reentry_durabilityguardlane_variance_rate`
  - `percentage_contract.reentry_durabilityguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Durability-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is durability-lane consistent.
- [ ] Durability-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, durability class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
