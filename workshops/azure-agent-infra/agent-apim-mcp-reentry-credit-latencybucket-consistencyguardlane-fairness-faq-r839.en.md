# APIM MCP Reentry Credit Latency Bucket Consistency Guard Lane FAQ (Cycle 2244)

## 1) Three-minute conclusion
- **Core problem:** Without consistency guard lanes, fairness actions may execute correctly but cross-window decision consistency is unprovable.
- **Recommended pattern:** Use a **consistency guard lane + credit latency bucket + replay consistency ledger**.
- **Expected outcome:** Better recovery stability, consistency, and audit consistency under multi-tenant load.

## 2) Q1 / Q2 / Q3
### Q1: Why must consistency guard lanes be inline?
1) Offline logs cannot constrain real-time reclaim and fallback actions;
2) Lane-level consistency IDs bind policy version, tenant watermark, and downgrade path;
3) Replay can be recomputed segment-by-segment without cross-shift drift.

### Q2: How should production layering be implemented?
- **Ingress:** APIM Gateway maps tenant tier + policy version into consistency lanes;
- **Control:** latency bucket grant/renew/reclaim writes consistency IDs;
- **Suppression:** burst windows apply graded degradation and spread containment;
- **Verification:** replay ledger reconstructs path by consistency ID and validates fairness metrics.

### Q3: What are go-live gates?
- Unfenced drift rate trends downward;
- Guard-lane variance converges inside target bands;
- Recovery gain (percentage points) is reproducible from evidence.

## 3) Architecture
```mermaid
flowchart LR
  A[MCP Reentry Burst] --> B[APIM Consistency Guard Lane]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Recovery Scheduler]
  D --> E[Fallback / Downgrade Gate]
  E --> F[Priority Fairness Lane]
  E --> G[Standard Tenant Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay Ledger + Consistency Timeline]
```

## 4) Selection matrix
| Dimension | Latency bucket only | Consistency guard lane + latency bucket (Recommended) |
|---|---:|---:|
| Fairness jitter convergence | Medium | High |
| Decision consistency | Low | High |
| Cross-tenant containment | Medium | High |
| Fallback explainability | Medium | High |
| Implementation complexity | Low | Medium-high |

## 5) Evidence and reproducible arithmetic (with n denominators)
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2244-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2244-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2244-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2244-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_consistencyguardlane_drift_rate`
  - `percentage_contract.reentry_consistencyguardlane_variance_rate`
  - `percentage_contract.reentry_consistencyguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Lane assignment and policy consistency are replayable.
- [ ] Grant/renew/reclaim events align with consistency IDs.
- [ ] Priority lane avoids starvation during downgrade windows.
- [ ] Ledger links tenant, policy, and execution path.
- [ ] FAQ/H5/SVG/7-card/evidence cycle+topic stay consistent.
