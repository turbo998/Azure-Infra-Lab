# Agent Gateway Tenant Fairness Retry Budget Selection FAQ (Global Shared Retry Budget vs Tenant-Fair Retry Budget + Quota Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to tenant-fair retry budget + quota fence**, not global shared retry budget as the baseline.
- **Static open-loop retry propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Tenant-fair retry-budget control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the gateway path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Static open-loop retry**: use fixed retry pacing and fixed burst windows; easy to reason about but more brittle under uneven load.
- **Tenant fairness retry budget + quota fence**: dynamically allocate retry budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does global shared retry budget increase timeout propagation at scale?
First principles: request bursts are uneven. Static open-loop retries oversubscribe hot tenants and starve cold tenants, which amplifies tail latency.

### Q2: When is global shared retry budget acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> retry budget assignment -> admission gate -> replay audit -> retry-budget-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox tenant fairness retry budget governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use tenant-fair retry budget + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use global shared retry budget on low-priority lanes]
  D -- No --> F[Use adaptive retry-budget-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Static open-loop retry] --> B1[Fixed retry quota + fixed burst window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Tenant fairness retry budget + quota fence] --> B2[Adaptive retry-budget window by tenant/session]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Runtime Session Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive batch tenant fairness retry budget step(s)
  F-->>G: batch tenant fairness retry budget result + cost usage
  G->>L: write batch tenant fairness retry budget chain + retry-budget-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Static open-loop retry | Tenant fairness retry budget + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-471-benchmark.json` -> `percentage_contract`.

- Metric A (static open-loop timeout rate)  
  - Formula: `n_static_open_loop_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.global_retry_budget_timeout_rate`
- Metric B (tenant-fair retry-budget timeout rate)  
  - Formula: `n_tenant_fair_retry_budget_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.tenant_fair_retry_budget_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_tenant_fair_retry - n_recovered_static_open_loop) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.tenant_fair_retry_recovery_gain_pts`

## 6) Production checklist
- [ ] Tenant-fair retry-budget policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, retry-budget-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
