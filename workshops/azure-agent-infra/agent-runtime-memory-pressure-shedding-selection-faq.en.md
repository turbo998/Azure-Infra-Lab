# Agent Runtime Memory Pressure Shedding Selection FAQ (Fixed Hard-Memory Cap vs Adaptive Memory-Pressure Shedding + Quota Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive runtime memory pressure shedding + quota fence**, not fixed hard-memory cap as the baseline.
- **Fixed hard-memory cap propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **runtime memory-pressure shedding control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed hard-memory cap**: use fixed cache retention and fixed pressure windows; easy to reason about but more brittle under uneven load.
- **Adaptive runtime memory pressure shedding + quota fence**: dynamically allocate shedding budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed hard-memory cap increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed hard-memory cap acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> shedding budget assignment -> admission gate -> replay audit -> pressure-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox runtime memory-pressure shedding governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive runtime memory pressure shedding + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed hard-memory cap on low-priority lanes]
  D -- No --> F[Use adaptive pressure-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed hard-memory cap] --> B1[Fixed cache TTL + fixed pressure window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive runtime memory pressure shedding + quota fence] --> B2[Adaptive pressure window by tenant/session]
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
  G->>F: execute adaptive batch runtime memory-pressure shedding step(s)
  F-->>G: batch runtime memory-pressure shedding result + cost usage
  G->>L: write batch runtime memory-pressure shedding chain + pressure-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed hard-memory cap | Adaptive runtime memory pressure shedding + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-477-benchmark.json` -> `percentage_contract`.

- Metric A (fixed hard-memory cap timeout rate)  
  - Formula: `n_fixed_hard_cap_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_hard_cap_timeout_rate`
- Metric B (adaptive runtime memory pressure shedding timeout rate)  
  - Formula: `n_adaptive_shedding_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_shedding_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_shedding - n_recovered_fixed_hard_cap) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_shedding_recovery_gain_pts`

## 6) Production checklist
- [ ] runtime memory-pressure shedding policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, pressure-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
