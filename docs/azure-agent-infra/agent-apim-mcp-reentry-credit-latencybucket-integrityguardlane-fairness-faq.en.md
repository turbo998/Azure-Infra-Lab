# APIM MCP Reentry Integrity Guard Lane Latency Bucket FAQ (Cycle 2166)

## 1) Three-minute decision
- **Core issue:** with reentry peaks and policy oscillation, recovery paths show integrity drift and fairness decay.
- **Recommendation:** implement a closed loop of integrity guard lanes, latency-bucket allocation, fallback downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while shrinking integrity-drift windows and rollback amplification.

## 2) Q1 / Q2 / Q3
### Q1: Why add an integrity guard lane?
1) unified throttling cannot separate integrity volatility risk classes,
2) integrity lanes block spread from high-risk policy changes and protect critical recovery paths,
3) with latency buckets, credit, validity, ordering, and integrity boundaries are jointly bounded.

### Q2: How should production layering work?
- **Integrity guard layer:** map tenant class + integrity state into recovery lanes,
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
  A[MCP Reentry Ingress] --> B[Integrity Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Integrity-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Integrity Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Integrity Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Integrity drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2166-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2166-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2166-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2166-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_integrityguardlane_drift_rate`
  - `percentage_contract.reentry_integrityguardlane_variance_rate`
  - `percentage_contract.reentry_integrityguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Integrity-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is integrity-lane consistent.
- [ ] Integrity-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, integrity class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
