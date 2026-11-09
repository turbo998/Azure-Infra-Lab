# Agent Gateway Fallback Budget Selection FAQ (Strict Fail-Fast Budget vs Adaptive Multi-Step Fallback Budget)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to adaptive multi-step fallback budgets**, not strict fail-fast budgets as the baseline.
- **Strict fail-fast budgets propagate transient upstream instability into user-visible timeouts** during burst periods.
- **Fallback budgets must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the fallback path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Strict fail-fast budget**: minimal retry/fallback allowance; requests fail quickly after primary timeout.
- **Adaptive multi-step fallback budget**: dynamic fallback steps and budget by tenant tier and request class.

### Q1: Why does strict fail-fast increase timeout propagation at scale?
First principles: transient upstream errors are common. If fallback budget is too tight, recoverable requests fail early; failure traffic then amplifies queue pressure and tail latency.

### Q2: When is strict fail-fast acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> fallback budget assignment -> admission gate -> failure replay audit -> budget retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Gateway fallback governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive multi-step fallback budget]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use strict fail-fast budget on low-priority lanes]
  D -- No --> F[Use adaptive budget with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Strict fail-fast] --> B1[Small static retry budget]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive fallback budget] --> B2[Dynamic step budget by tenant/request]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Fallback Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive fallback step(s)
  F-->>G: fallback result + cost usage
  G->>L: write fallback chain + budget consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Strict fail-fast budget | Adaptive multi-step fallback budget |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-461-benchmark.json` -> `percentage_contract`.

- Metric A (primary-only timeout rate)  
  - Formula: `n_primary_only_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.primary_only_timeout_rate`
- Metric B (adaptive-fallback timeout rate)  
  - Formula: `n_adaptive_fallback_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_fallback_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_fallback - n_recovered_primary_only) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.fallback_recovery_gain_pts`

## 6) Production checklist
- [ ] Fallback budget policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, budget usage, and retry ceilings are observable and auditable
- [ ] Timeout events, fallback chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
