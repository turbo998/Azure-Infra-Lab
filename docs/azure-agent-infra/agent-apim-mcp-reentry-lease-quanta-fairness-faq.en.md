# APIM MCP Reentry Lease Quanta Fairness Selection FAQ (Cycle 1946)

## 1) Three-minute decision
- **Core issue:** reentry bursts deplete shared quotas quickly and make tenant recovery order unstable.
- **Recommendation:** use a closed loop of lease-quanta allocation, overdraft-lease reclaim, and overload downgrade gates.
- **Goal:** preserve tenant fairness while stabilizing recovery throughput for critical lease sessions.

## 2) Q1 / Q2 / Q3
### Q1: Why lease quanta instead of fixed credit buckets?
1) fixed credit lacks time semantics for lease expiration and renewal priority,
2) pure credit decay still causes boundary-time contention spikes,
3) lease quanta let capacity and validity window co-drive scheduling.

### Q2: What is the production layering model?
- **Allocation layer:** issue lease quanta and renewal budgets per tenant/priority,
- **Reclaim layer:** apply windowed overdraft reclaim with anti-oscillation limits,
- **Downgrade layer:** trigger overload gates to protect critical sessions,
- **Audit layer:** persist grant, renew, reclaim, and downgrade events.

### Q3: What is the go-live bar?
- lease-quanta drift rate keeps declining,
- high-priority lease success remains stable,
- reclaim and downgrade transitions are tenant-replayable.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Lease Quanta Distributor]
  B --> C[Overdraft Lease Reclaimer]
  C --> D[Lease-Aware Scheduler]
  D --> E[Overload Downgrade Gate]
  E --> F[Primary Recovery Lane]
  C --> G[Audit Replay Timeline]
  F --> H[Gateway Response]
  H --> D
```

## 4) Decision matrix
| Dimension | Fixed credit bucket | Lease Quanta Fairness (Recommended) |
|---|---:|---:|
| Lease-recovery order stability | Medium | High |
| Boundary contention suppression | Medium | High |
| Capacity+validity coupling | Low | High |
| Replay explainability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-1946-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1946-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1946-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1946-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_lease_quanta_drift_rate`
  - `percentage_contract.reentry_lease_quanta_variance_rate`
  - `percentage_contract.reentry_lease_quanta_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Lease grant/renew/reclaim transitions are window-replayable.
- [ ] Overdraft reclaim avoids starvation for critical tenants.
- [ ] Downgrade gates converge monotonically at 10x load.
- [ ] Audit trails bind tenant, lease class, and policy version deterministically.
- [ ] FAQ/H5/SVG/7-card/evidence remain cycle-topic consistent.
