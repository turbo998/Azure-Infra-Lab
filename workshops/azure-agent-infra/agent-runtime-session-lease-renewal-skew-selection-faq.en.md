# Agent Runtime Session Lease-Renewal Skew Selection FAQ (Fixed Tight Lease-Renewal Skew vs Adaptive Lease-Renewal Skew Fence + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive lease-renewal-skew fence + drift budget guard**, not fixed tight lease-renewal-skew policy as the baseline.
- **Fixed tight lease-renewal-skew policy propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Ephemeral lease-renewal-skew lane control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed tight lease-renewal-skew policy**: use fixed in-band injection and fixed lease-renewal-skew lane windows; easy to reason about but more brittle under uneven load.
- **Attested short-lived token broker + session binding**: dynamically allocate lease-renewal-skew lane budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed tight lease-renewal-skew policy increase timeout propagation at scale?
First principles: retries and network jitter are inevitable. Without monotonic-clock fences, duplicate write calls are executed as new operations, amplifying timeout and side-effect risk.

### Q2: When is fixed tight lease-renewal-skew policy acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> lease-renewal-skew lane budget assignment -> admission gate -> replay audit -> handoff-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox adaptive lease-renewal-skew fence governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive lease-renewal-skew fence + drift budget guard]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed tight lease-renewal-skew policy on low-priority lanes]
  D -- No --> F[Use adaptive lease-renewal-skew lane window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed tight lease-renewal-skew policy] --> B1[Fixed in-band secret injection + fixed lease-renewal-skew lane window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Attested short-lived token broker + session binding] --> B2[Adaptive lease-renewal-skew lane window by tenant/session]
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
  G->>F: execute attested short-lived lease-renewal-skew lane step(s)
  F-->>G: attested lease-renewal-skew lane result + cost usage
  G->>L: write attested lease-renewal-skew lane chain + clock drift window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed tight lease-renewal-skew policy | Attested short-lived token broker + session binding |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-498-benchmark.json` -> `percentage_contract`.

- Metric A (fixed tight lease-renewal-skew policy timeout rate)  
  - Formula: `n_fixed_tight_lease_renewal_timeout / n_gateway_requests_observed`  
  - Value: `389/3300 = 11.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_tight_lease_renewal_timeout_rate`
- Metric B (attested short-lived token broker timeout rate)  
  - Formula: `n_adaptive_lease_renewal_skew_timeout / n_gateway_requests_observed`  
  - Value: `181/3300 = 5.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_lease_renewal_skew_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_lease_renewal_skew - n_recovered_fixed_tight_lease_renewal) / n_gateway_requests_observed`  
  - Value: `(3109-2911)/3300 = 6.0 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_lease_renewal_skew_recovery_gain_pts`

## 6) Production checklist
- [ ] Credential handoff policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, clock drift window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
