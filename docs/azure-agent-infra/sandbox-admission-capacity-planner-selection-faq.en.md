# Sandbox Admission Capacity Planner Selection FAQ (Cycle 1769)

## 1) Three-minute decision
- **Sandbox instability usually comes from delayed admission control, not just underprovisioned compute.**
- **Recommendation:** couple admission budgets (slots + cold-start budget) with dynamic capacity planning by tenant priority.
- **Goal:** preserve critical SLA under peak traffic and avoid queue collapse.

## 2) Core questions (Q1/Q2/Q3)
### Q1: Why CPU/memory-only sizing is misleading?
1) cold-start and image-pull latency are ignored,
2) burst waves amplify scheduling delay,
3) long-tail sessions hold slots and starve critical paths.

### Q2: What is the minimum planner input set?
- per-tenant request rate and burst profile,
- sandbox runtime duration and cold-start cost,
- reserved slots for critical tasks.

### Q3: How to validate policy effectiveness?
- critical success rate under peak replay meets target,
- standard workloads degrade gracefully,
- over-quota denials are auditable and explainable.

## 3) Reference architecture
```mermaid
flowchart LR
  R[Incoming Requests] --> A[Admission Controller]
  A --> Q[Priority Queue]
  Q --> P[Capacity Planner]
  P --> S[Sandbox Pools]
  P --> L[Capacity Decision Ledger]
  S --> O[Runtime Observability]
```

## 4) Decision matrix
| Dimension | Static quota | Dynamic admission + planner (Recommended) |
|---|---:|---:|
| Peak stability | Low | High |
| Critical-path assurance | Medium | High |
| Utilization efficiency | Medium | High |
| Ops complexity | Low | Medium |
| Audit explainability | Medium | High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-1769-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1769-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1769-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1769-cost.csv`
- Labels: `measured / synthetic / anonymized_reported`.
- validation7 requires bilingual structure, CSP self-contained cards, evidence consistency, and replayability trace.

## 6) Production checklist
- [ ] Admission policy reserves slots for critical tenants.
- [ ] Cold-start budget is included in planner calculations.
- [ ] Over-quota denials include reason codes and audit trails.
- [ ] Critical/standard degradation paths are replayable.
- [ ] FAQ/H5/SVG/7-card references are cycle-aligned.
