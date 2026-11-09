# Agent Gateway Hedged Quorum Dispatch Selection FAQ (Strict Single-Path Dispatch vs Adaptive Hedged Quorum Dispatch)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to adaptive hedged quorum dispatch**, not strict single-path dispatch as the baseline.
- **Strict single-path dispatch propagates transient upstream instability into user-visible timeouts** during burst periods.
- **Hedged budgets must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the hedged path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Strict single-path dispatch**: minimal retry/hedging allowance; requests fail quickly after primary timeout.
- **Adaptive hedged quorum dispatch**: dynamic hedged steps and budget by tenant tier and request class.

### Q1: Why does strict single-path dispatch increase timeout propagation at scale?
First principles: transient upstream errors are common. If hedged quorum budget is too tight, recoverable requests fail early; failure traffic then amplifies queue pressure and tail latency.

### Q2: When is strict single-path dispatch acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> hedged quorum budget assignment -> admission gate -> failure replay audit -> budget retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Gateway hedged governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive hedged quorum dispatch]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use strict single-path dispatch on low-priority lanes]
  D -- No --> F[Use adaptive budget with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Strict single-path dispatch] --> B1[Small static retry budget]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive hedged quorum budget] --> B2[Dynamic step budget by tenant/request]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Hedged Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive hedged step(s)
  F-->>G: hedged result + cost usage
  G->>L: write hedged chain + budget consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Strict single-path dispatch | Adaptive hedged quorum dispatch |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-462-benchmark.json` -> `percentage_contract`.

- Metric A (primary-only timeout rate)  
  - Formula: `n_primary_only_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.primary_only_timeout_rate`
- Metric B (adaptive-hedged timeout rate)  
  - Formula: `n_adaptive_hedged_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_hedged_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_hedged - n_recovered_primary_only) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.hedged_recovery_gain_pts`

## 6) Production checklist
- [ ] Hedged budget policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, budget usage, and retry ceilings are observable and auditable
- [ ] Timeout events, hedged chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
