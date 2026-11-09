# Agent Gateway Circuit Breaker Half-Open Probe Selection FAQ (Static Open-Loop Retry vs Circuit Breaker Half-Open Probe + Failure Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to circuit breaker half-open probe + failure fence**, not static open-loop retry as the baseline.
- **Static open-loop retry propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Half-open probe control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the gateway path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Static open-loop retry**: use fixed retry pacing and fixed burst windows; easy to reason about but more brittle under uneven load.
- **Circuit breaker half-open probe + failure fence**: dynamically probe and reopen traffic per tenant/session while preserving auditable policy boundaries.

### Q1: Why does static open-loop retry increase timeout propagation at scale?
First principles: request bursts are uneven. Static open-loop retries oversubscribe hot tenants and starve cold tenants, which amplifies tail latency.

### Q2: When is static open-loop retry acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> probe budget assignment -> admission gate -> replay audit -> half-open-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox circuit breaker half-open probe governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use circuit breaker half-open probe + failure fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use static open-loop retry on low-priority lanes]
  D -- No --> F[Use adaptive half-open-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Static open-loop retry] --> B1[Fixed retry quota + fixed burst window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Circuit breaker half-open probe + failure fence] --> B2[Adaptive half-open window by tenant/session]
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
  G->>F: execute adaptive batch circuit breaker half-open probe step(s)
  F-->>G: batch circuit breaker half-open probe result + cost usage
  G->>L: write batch circuit breaker half-open probe chain + half-open-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Static open-loop retry | Circuit breaker half-open probe + failure fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-470-benchmark.json` -> `percentage_contract`.

- Metric A (static open-loop timeout rate)  
  - Formula: `n_static_open_loop_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.static_open_loop_timeout_rate`
- Metric B (half-open probe timeout rate)  
  - Formula: `n_half_open_probe_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.half_open_probe_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_half_open_probe - n_recovered_static_open_loop) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.half_open_probe_recovery_gain_pts`

## 6) Production checklist
- [ ] Half-open probe policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, half-open-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
