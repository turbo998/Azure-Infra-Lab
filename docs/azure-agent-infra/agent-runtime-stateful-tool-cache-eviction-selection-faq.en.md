# Agent Runtime Stateful Tool Cache Eviction Selection FAQ (Fixed TTL Eviction vs Adaptive Stateful Cache Eviction + Quota Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive stateful cache eviction + quota fence**, not fixed TTL eviction as the baseline.
- **Fixed TTL eviction propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Stateful cache-eviction control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed TTL eviction**: use fixed cache retention and fixed eviction windows; easy to reason about but more brittle under uneven load.
- **Adaptive stateful cache eviction + quota fence**: dynamically allocate eviction budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed TTL eviction increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed TTL eviction acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> eviction budget assignment -> admission gate -> replay audit -> eviction-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox stateful tool cache eviction governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive stateful cache eviction + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed TTL eviction on low-priority lanes]
  D -- No --> F[Use adaptive eviction-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed TTL eviction] --> B1[Fixed cache TTL + fixed eviction window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive stateful cache eviction + quota fence] --> B2[Adaptive eviction window by tenant/session]
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
  G->>F: execute adaptive batch stateful tool cache eviction step(s)
  F-->>G: batch stateful tool cache eviction result + cost usage
  G->>L: write batch stateful tool cache eviction chain + eviction-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed TTL eviction | Adaptive stateful cache eviction + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-472-benchmark.json` -> `percentage_contract`.

- Metric A (fixed TTL eviction timeout rate)  
  - Formula: `n_fixed_ttl_eviction_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_ttl_eviction_timeout_rate`
- Metric B (adaptive eviction timeout rate)  
  - Formula: `n_adaptive_eviction_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_eviction_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_eviction - n_recovered_fixed_ttl_eviction) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_eviction_recovery_gain_pts`

## 6) Production checklist
- [ ] Stateful cache-eviction policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, eviction-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
