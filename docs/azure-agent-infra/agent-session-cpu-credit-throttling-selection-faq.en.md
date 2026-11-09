# Agent Session CPU-credit Throttling Selection FAQ (Unlimited Burst Policy vs Credit-throttling Policy)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant session production, default to a CPU-credit throttling policy**, not long-term unlimited burst policy.
- **Unlimited burst policy is more likely to amplify throttle jitter and resume-failure spikes** under long sessions and burst restore peaks.
- **Credit-throttling policy must couple tenant quota, gateway admission, and replay audit**, or capacity recovery and service continuity will conflict.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unlimited burst policy**: allow uncapped burst at pressure peaks; high short-term throughput, high jitter risk.
- **Credit-throttling policy**: apply tenant-scoped credit budgets with throttle guards; smoother recovery behavior.

### Q1: Why is unlimited burst more fragile at peak?
First principles: when request concurrency and restore concurrency increase together, uncapped burst causes clustered throttling and amplifies queue/rebuild pressure.

### Q2: When is unlimited burst still acceptable?
Transitional phases with single tenant, short sessions, performance-jitter tolerance, and simple restore paths.

### Q3: What is the minimum safe loop?
Tenant classification -> credit-throttling policy -> burst-budget gate -> replay audit -> throttling rollback retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Multi-tenant session runtime?] --> B{Burst restore + credit spikes present?}
  B -- No --> C[Keep unlimited burst policy]
  B -- Yes --> D{Credit telemetry and replay audit ready?}
  D -- No --> E[Build telemetry/audit first]
  D -- Yes --> F[Adopt CPU-credit throttling policy]
  F --> G[Bind quota gate + replay audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unlimited burst] --> B1[No credit cap under burst]
  B1 --> C1[Burst amplification without credit caps]

  A2[Credit-throttling policy] --> B2[Tiered credit budget + throttle guard]
  B2 --> C2[Lower throttle spikes + steadier restore]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant G as Gateway
  participant M as Credit Monitor
  participant T as Throttling Engine
  participant A as Admission Gate
  participant L as Replay Ledger
  G->>M: session pressure + tenant tags
  M-->>T: credit pressure scores
  T-->>A: credit tier placement + throttle plan
  A-->>G: admit/queue decision
  A->>L: emit restore/audit events
  L-->>T: retuning feedback
```

## 4) Decision matrix
| Dimension | Unlimited burst policy | Credit-throttling policy |
|---|---|---|
| Implementation complexity | Low | Medium |
| Peak restore stability | Medium-Low | High |
| Throttle-jitter control | Low-Medium | High |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Transitional only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-453-benchmark.json` -> `percentage_contract`.

- Metric A (unlimited-burst resume-failure rate)  
  - Formula: `n_unlimited_burst_fail / n_runtime_requests_observed`  
  - Value: `322/2400 = 13.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unlimited_burst_failure_rate`
- Metric B (credit-throttling resume-failure rate)  
  - Formula: `n_credit_throttling_fail / n_runtime_requests_observed`  
  - Value: `133/2400 = 5.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.credit_throttling_failure_rate`
- Metric C (resume success gain, percentage points)  
  - Formula: `(n_resume_success_throttled - n_resume_success_unlimited) / n_runtime_requests_observed`  
  - Value: `(2240-2047)/2400 = 8.0 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.throttling_recovery_gain_pts`

## 6) Production checklist
- [ ] Credit-throttling policy is versioned with rollout and rollback paths
- [ ] Tenant quota and burst-budget admission gates are enforced at gateway level
- [ ] Resume failures, resume success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`

