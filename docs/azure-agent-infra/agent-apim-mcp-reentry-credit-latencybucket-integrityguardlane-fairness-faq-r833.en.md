# APIM MCP Reentry Credit Latency Bucket Integrity Guard Lane FAQ (Cycle 2238)

## 1) Three-minute conclusion
- **Core problem:** Without integrity guard lanes, fairness actions may execute correctly but cross-window decision integrity is unprovable.
- **Recommended pattern:** Use a **integrity guard lane + credit latency bucket + replay integrity ledger**.
- **Expected outcome:** Better recovery stability, integrity, and audit integrity under multi-tenant load.

## 2) Q1 / Q2 / Q3
### Q1: Why must integrity guard lanes be inline?
1) Offline logs cannot constrain real-time reclaim and fallback actions;
2) Lane-level integrity IDs bind policy version, tenant watermark, and downgrade path;
3) Replay can be recomputed segment-by-segment without cross-shift drift.

### Q2: How should production layering be implemented?
- **Ingress:** APIM Gateway maps tenant tier + policy version into integrity lanes;
- **Control:** latency bucket grant/renew/reclaim writes integrity IDs;
- **Suppression:** burst windows apply graded degradation and spread containment;
- **Verification:** replay ledger reconstructs path by integrity ID and validates fairness metrics.

### Q3: What are go-live gates?
- Unfenced drift rate trends downward;
- Guard-lane variance converges inside target bands;
- Recovery gain (percentage points) is reproducible from evidence.

## 3) Architecture
```mermaid
flowchart LR
  A[MCP Reentry Burst] --> B[APIM Integrity Guard Lane]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Recovery Scheduler]
  D --> E[Fallback / Downgrade Gate]
  E --> F[Priority Fairness Lane]
  E --> G[Standard Tenant Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay Ledger + Integrity Timeline]
```

## 4) Selection matrix
| Dimension | Latency bucket only | Integrity guard lane + latency bucket (Recommended) |
|---|---:|---:|
| Fairness jitter convergence | Medium | High |
| Decision integrity | Low | High |
| Cross-tenant containment | Medium | High |
| Fallback explainability | Medium | High |
| Implementation complexity | Low | Medium-high |

## 5) Evidence and reproducible arithmetic (with n denominators)
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2238-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2238-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2238-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2238-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_integrityguardlane_drift_rate`
  - `percentage_contract.reentry_integrityguardlane_variance_rate`
  - `percentage_contract.reentry_integrityguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Lane assignment and policy integrity are replayable.
- [ ] Grant/renew/reclaim events align with integrity IDs.
- [ ] Priority lane avoids starvation during downgrade windows.
- [ ] Ledger links tenant, policy, and execution path.
- [ ] FAQ/H5/SVG/7-card/evidence cycle+topic stay consistent.
