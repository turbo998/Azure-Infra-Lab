# APIM MCP Reentry Assurance Guard Lane Latency Bucket FAQ (Cycle 2163)

## 1) Three-minute decision
- **Core issue:** with reentry peaks and policy oscillation, recovery paths show assurance drift and fairness decay.
- **Recommendation:** implement a closed loop of assurance guard lanes, latency-bucket allocation, fallback downgrade gates, and replay audit.
- **Goal:** preserve tenant fairness while shrinking assurance-drift windows and rollback amplification.

## 2) Q1 / Q2 / Q3
### Q1: Why add an assurance guard lane?
1) unified throttling cannot separate assurance volatility risk classes,
2) assurance lanes block spread from high-risk policy changes and protect critical recovery paths,
3) with latency buckets, credit, validity, ordering, and assurance boundaries are jointly bounded.

### Q2: How should production layering work?
- **Assurance guard layer:** map tenant class + assurance state into recovery lanes,
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
  A[MCP Reentry Ingress] --> B[Assurance Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Assurance-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Assurance Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Audit Replay Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Assurance Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Assurance drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay explainability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2163-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2163-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2163-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2163-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_assuranceguardlane_drift_rate`
  - `percentage_contract.reentry_assuranceguardlane_variance_rate`
  - `percentage_contract.reentry_assuranceguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Assurance-lane classification is tenant-class replayable.
- [ ] Bucket grant/renew/reclaim is assurance-lane consistent.
- [ ] Assurance-priority lanes stay starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, assurance class, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
