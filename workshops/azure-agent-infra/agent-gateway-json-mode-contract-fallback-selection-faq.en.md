# Agent Gateway JSON-Mode Contract Fallback Selection FAQ (Fixed Strict JSON-Mode No-Fallback vs Adaptive Contract Fallback Ladder + Schema Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive JSON-mode contract fallback + quota fence**, not fixed strict JSON-mode no-fallback as the baseline.
- **Fixed strict JSON-mode no-fallback propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **JSON-mode contract-fallback control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed strict JSON-mode no-fallback**: use fixed cache retention and fixed fallback windows; easy to reason about but more brittle under uneven load.
- **Adaptive JSON-mode contract fallback + quota fence**: dynamically allocate fallback budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed strict JSON-mode no-fallback increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed strict JSON-mode no-fallback acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> fallback budget assignment -> admission gate -> replay audit -> fallback-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox JSON-mode contract-fallback governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive JSON-mode contract fallback + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed strict JSON-mode no-fallback on low-priority lanes]
  D -- No --> F[Use adaptive fallback-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed strict JSON-mode no-fallback] --> B1[Fixed cache TTL + fixed fallback window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive JSON-mode contract fallback + quota fence] --> B2[Adaptive fallback window by tenant/session]
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
  G->>F: execute adaptive batch JSON-mode contract-fallback step(s)
  F-->>G: batch JSON-mode contract-fallback result + cost usage
  G->>L: write batch JSON-mode contract-fallback chain + fallback-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed strict JSON-mode no-fallback | Adaptive JSON-mode contract fallback + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-479-benchmark.json` -> `percentage_contract`.

- Metric A (fixed strict JSON-mode no-fallback timeout rate)  
  - Formula: `n_strict_json_no_fallback_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.strict_json_no_fallback_timeout_rate`
- Metric B (adaptive JSON-mode contract fallback timeout rate)  
  - Formula: `n_adaptive_contract_fallback_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_contract_fallback_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_contract_fallback - n_recovered_strict_json_no_fallback) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_contract_fallback_recovery_gain_pts`

## 6) Production checklist
- [ ] JSON-mode contract-fallback policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, fallback-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
