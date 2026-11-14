# Agent ACA Dynamic Session Quota Fairshare Selection FAQ (Azure AI Agent Infra)

## 1) 3-minute conclusions
- **ACA Dynamic Sessions needs fair-share quota under multi-tenant bursts, or contention and tail skew escalate.**
- **Use hard base quota + elastic credit layer + starvation guard.**
- **Targets: `tenant_starvation=0`, `p95_latency_skew <12%`, `quota_overrun <0.5%`.**

## 2) Q1 / Q2 / Q3
- **Why unfairness appears?** Burst tenants continuously consume elastic headroom.
- **Why not fixed equal quotas only?** Under-utilization causes waste.
- **Minimum loop?** Base allocation, credit lending, recovery and protection.

### Q1: When to trigger protection?
When starvation waiting crosses threshold.

### Q2: When to reclaim credits?
When tenant idle windows remain stable.

### Q3: How to measure gain?
Compare latency skew, starvation events, and utilization.

## 3) Mermaid diagrams
### 3.1 Decision tree
```mermaid
flowchart TD
  A[Session request] --> B{base quota available?}
  B -- Yes --> C[Allocate base quota]
  B -- No --> D[Check elastic credit]
  D --> E{credit pool healthy?}
  E -- Yes --> F[Lend credit]
  E -- No --> G[Queue with starvation guard]
  F --> H[Track repayment window]
  G --> H
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed equal quota] --> B1[Simple policy]
  B1 --> C1[Low peak utilization]

  A2[Base+credit fairshare] --> B2[Balanced utilization]
  B2 --> C2[Needs repayment controls]
```

### 3.3 Sequence
```mermaid
sequenceDiagram
  participant Tenant
  participant QuotaMgr
  participant SessionPool
  participant Guard
  Tenant->>QuotaMgr: request sessions
  QuotaMgr->>SessionPool: allocate base/credit
  SessionPool-->>Guard: utilization events
  Guard-->>QuotaMgr: starvation/repay signals
  QuotaMgr-->>Tenant: grant/queue result
```

## 4) Decision matrix
| Dimension | Fixed equal quota | Base+credit fairshare (Recommended) |
|---|---:|---:|
| Fairness | Medium | High |
| Utilization | Medium | High |
| Ops complexity (1-10) | 4 | 8 |
| Starvation risk | Medium | Low |
| Peak elasticity | Medium | High |

## 5) Quant model + 7-card insights
- Skew: `Skew = (TopTenantP95 - MedianP95) / MedianP95`
- Gain: `SkewGain = BaselineSkew - FairshareSkew`
- Example (`synthetic_assumed`):
  - `BaselineSkew=21%, FairshareSkew=9%`
  - `SkewGain=12%`
  - `QuotaOverrun=0.42%`
- Evidence:
  - `workshops/azure-agent-infra/evidence/cycle-1486-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1486-sources.json`
- Labels: `official/synthetic_assumed/not_measured`.

## 6) Production verification checklist
- [ ] Base quota and credit ledger accounting is consistent
- [ ] Starvation guard alerts and actions are linked
- [ ] Credit reclaim windows and anti-flap controls are auditable
- [ ] Skew/overrun metrics are visible on dashboards
- [ ] FAQ/7-card source labels are complete
