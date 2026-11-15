# APIM MCP Reentry Credit Latency Bucket Lineage Guard Lane FAQ (Cycle 2210)

## 1) Three-minute conclusion
- **Core problem:** Without lineage guard lanes, fairness actions may execute but source consistency remains unverifiable.
- **Recommended pattern:** Use a **lineage guard lane + credit latency bucket + replay lineage ledger**.
- **Expected outcome:** Better recovery stability, explainability, and audit confidence under multi-tenant load.

## 2) Q1 / Q2 / Q3
### Q1: Why must lineage guard lanes be inline?
1) Offline logging cannot constrain real-time reclaim decisions;
2) Lane-level lineage IDs bind policy version, tenant watermark, and fallback action;
3) Incident replay can be recomputed path-by-path with no narrative drift.

### Q2: How should production layering be implemented?
- **Ingress:** APIM Gateway maps tenant tier + policy version into lineage lanes;
- **Control:** latency bucket grant/renew/reclaim writes lineage IDs;
- **Suppression:** burst windows apply graded degradation and spread containment;
- **Verification:** replay ledger reconstructs scheduler path by lineage ID.

### Q3: What are go-live gates?
- Unfenced drift rate trends downward;
- Guard-lane variance converges inside target bands;
- Recovery gain (percentage points) is reproducible from evidence.

## 3) Architecture
```mermaid
flowchart LR
  A[MCP Reentry Burst] --> B[APIM Lineage Guard Lane]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Recovery Scheduler]
  D --> E[Fallback / Downgrade Gate]
  E --> F[Priority Fairness Lane]
  E --> G[Standard Tenant Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay Ledger + Lineage Timeline]
```

## 4) Selection matrix
| Dimension | Latency bucket only | Lineage guard lane + latency bucket (Recommended) |
|---|---:|---:|
| Fairness jitter convergence | Medium | High |
| Policy lineage traceability | Low | High |
| Cross-tenant containment | Medium | High |
| Fallback explainability | Medium | High |
| Implementation complexity | Low | Medium-high |

## 5) Evidence and reproducible arithmetic (with n denominators)
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2210-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2210-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2210-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2210-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_lineageguardlane_drift_rate`
  - `percentage_contract.reentry_lineageguardlane_variance_rate`
  - `percentage_contract.reentry_lineageguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Lane assignment and policy lineage are replayable.
- [ ] Grant/renew/reclaim events align with lineage IDs.
- [ ] Priority lane avoids starvation during downgrade windows.
- [ ] Ledger links tenant, policy, and execution path.
- [ ] FAQ/H5/SVG/7-card/evidence cycle+topic stay consistent.
