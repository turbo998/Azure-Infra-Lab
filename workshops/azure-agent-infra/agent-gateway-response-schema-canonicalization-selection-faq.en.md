# Agent Gateway Response Schema Canonicalization Selection FAQ (Fixed Schema Passthrough vs Adaptive Response Canonicalization + Contract Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive response schema canonicalization + quota fence**, not fixed schema passthrough as the baseline.
- **Fixed schema passthrough propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **response-schema canonicalization control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed schema passthrough**: use fixed cache retention and fixed normalization windows; easy to reason about but more brittle under uneven load.
- **Adaptive response schema canonicalization + quota fence**: dynamically allocate canonicalization budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed schema passthrough increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed schema passthrough acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> canonicalization budget assignment -> admission gate -> replay audit -> normalization-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox response-schema canonicalization governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive response schema canonicalization + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed schema passthrough on low-priority lanes]
  D -- No --> F[Use adaptive normalization-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed schema passthrough] --> B1[Fixed cache TTL + fixed normalization window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive response schema canonicalization + quota fence] --> B2[Adaptive normalization window by tenant/session]
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
  G->>F: execute adaptive batch response-schema canonicalization step(s)
  F-->>G: batch response-schema canonicalization result + cost usage
  G->>L: write batch response-schema canonicalization chain + normalization-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed schema passthrough | Adaptive response schema canonicalization + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-478-benchmark.json` -> `percentage_contract`.

- Metric A (fixed schema passthrough timeout rate)  
  - Formula: `n_fixed_passthrough_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_passthrough_timeout_rate`
- Metric B (adaptive response schema canonicalization timeout rate)  
  - Formula: `n_adaptive_canonicalization_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_canonicalization_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_canonicalization - n_recovered_fixed_passthrough) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_canonicalization_recovery_gain_pts`

## 6) Production checklist
- [ ] response-schema canonicalization policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, normalization-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
