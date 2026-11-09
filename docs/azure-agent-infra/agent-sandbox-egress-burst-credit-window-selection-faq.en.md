# Agent Sandbox Egress Burst Credit Window Selection FAQ (Fixed Narrow Egress Burst vs Adaptive Egress Burst Credit-Window Fence + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive egress burst credit-window fence + drift budget guard**, not fixed narrow egress-burst policy as the baseline.
- **Fixed narrow egress-burst policy propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Ephemeral egress burst credit-window lane control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed narrow egress-burst policy**: use fixed in-band injection and fixed egress burst credit-window lane windows; easy to reason about but more brittle under uneven load.
- **Attested short-lived token broker + session binding**: dynamically allocate egress burst credit-window lane budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed narrow egress-burst policy increase timeout propagation at scale?
First principles: retries and network jitter are inevitable. Without monotonic-clock fences, duplicate write calls are executed as new operations, amplifying timeout and side-effect risk.

### Q2: When is fixed narrow egress-burst policy acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> egress burst credit-window lane budget assignment -> admission gate -> replay audit -> handoff-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox adaptive egress burst credit-window fence governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive egress burst credit-window fence + drift budget guard]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed narrow egress-burst policy on low-priority lanes]
  D -- No --> F[Use adaptive egress burst credit-window lane window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed narrow egress-burst policy] --> B1[Fixed in-band secret injection + fixed egress burst credit-window lane window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Attested short-lived token broker + session binding] --> B2[Adaptive egress burst credit-window lane window by tenant/session]
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
  G->>F: execute attested short-lived egress burst credit-window lane step(s)
  F-->>G: attested egress burst credit-window lane result + cost usage
  G->>L: write attested egress burst credit-window lane chain + clock drift window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed narrow egress-burst policy | Attested short-lived token broker + session binding |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-500-benchmark.json` -> `percentage_contract`.

- Metric A (fixed narrow egress-burst policy timeout rate)  
  - Formula: `n_fixed_narrow_egress_burst_timeout / n_gateway_requests_observed`  
  - Value: `447/3700 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_narrow_egress_burst_timeout_rate`
- Metric B (attested short-lived token broker timeout rate)  
  - Formula: `n_adaptive_egress_burst_credit_window_timeout / n_gateway_requests_observed`  
  - Value: `214/3700 = 5.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_egress_burst_credit_window_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_egress_burst_credit_window - n_recovered_fixed_narrow_egress_burst) / n_gateway_requests_observed`  
  - Value: `(3440-3236)/3700 = 5.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_egress_burst_credit_window_recovery_gain_pts`

## 6) Production checklist
- [ ] Credential handoff policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, clock drift window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
