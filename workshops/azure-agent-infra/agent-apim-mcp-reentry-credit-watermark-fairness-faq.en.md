# APIM MCP Reentry Credit Watermark Fairness Selection FAQ (Cycle 1958)

## 1) Three-minute decision
- **Core issue:** reentry bursts deplete shared quotas quickly and make tenant recovery order unstable.
- **Recommendation:** use a closed loop of credit-watermark allocation, overdraft-lease reclaim, and overload downgrade gates.
- **Goal:** preserve tenant fairness while stabilizing recovery throughput for critical watermark sessions.

## 2) Q1 / Q2 / Q3
### Q1: Why credit watermark instead of fixed credit buckets?
1) fixed credit lacks time semantics for lease expiration and renewal priority,
2) pure credit watermark still causes boundary-time contention spikes,
3) credit watermark let capacity and validity window co-drive scheduling.

### Q2: What is the production layering model?
- **Allocation layer:** issue credit watermark and renewal budgets per tenant/priority,
- **Reclaim layer:** apply windowed overdraft reclaim with anti-oscillation limits,
- **Downgrade layer:** trigger overload gates to protect critical sessions,
- **Audit layer:** persist grant, renew, reclaim, and downgrade events.

### Q3: What is the go-live bar?
- credit-watermark drift rate keeps declining,
- high-priority lease success remains stable,
- reclaim and downgrade transitions are tenant-replayable.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Credit Watermark Controller]
  B --> C[Credit Watermark Reclaimer]
  C --> D[Watermark-Aware Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Primary Recovery Lane]
  C --> G[Audit Replay Timeline]
  F --> H[Gateway Response]
  H --> D
```

## 4) Decision matrix
| Dimension | Fixed credit bucket | Credit Watermark Fairness (Recommended) |
|---|---:|---:|
| Lease-recovery order stability | Medium | High |
| Boundary contention suppression | Medium | High |
| Capacity+validity coupling | Low | High |
| Replay explainability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-1958-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1958-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1958-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1958-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_credit_watermark_drift_rate`
  - `percentage_contract.reentry_credit_watermark_variance_rate`
  - `percentage_contract.reentry_credit_watermark_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Lease grant/renew/reclaim transitions are window-replayable.
- [ ] Overdraft reclaim avoids starvation for critical tenants.
- [ ] Downgrade gates converge monotonically at 10x load.
- [ ] Audit trails bind tenant, watermark class, and policy version deterministically.
- [ ] FAQ/H5/SVG/7-card/evidence remain cycle-topic consistent.
