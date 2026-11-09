# Agent Gateway Replay-Idempotency Window Selection FAQ (Fixed Short Replay Window vs Replay-Idempotency Window Fence + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to replay-idempotency-window fence + drift budget guard**, not fixed short replay-window policy as the baseline.
- **Fixed short replay-window policy propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Ephemeral replay-idempotency-window lane control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed short replay-window policy**: use fixed in-band injection and fixed replay-idempotency-window lane windows; easy to reason about but more brittle under uneven load.
- **Attested short-lived token broker + session binding**: dynamically allocate replay-idempotency-window lane budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed short replay-window policy increase timeout propagation at scale?
First principles: retries and network jitter are inevitable. Without monotonic-clock fences, duplicate write calls are executed as new operations, amplifying timeout and side-effect risk.

### Q2: When is fixed short replay-window policy acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> replay-idempotency-window lane budget assignment -> admission gate -> replay audit -> handoff-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox replay-idempotency-window fence governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use replay-idempotency-window fence + drift budget guard]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed short replay-window policy on low-priority lanes]
  D -- No --> F[Use adaptive replay-idempotency-window lane window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed short replay-window policy] --> B1[Fixed in-band secret injection + fixed replay-idempotency-window lane window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Attested short-lived token broker + session binding] --> B2[Adaptive replay-idempotency-window lane window by tenant/session]
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
  G->>F: execute attested short-lived replay-idempotency-window lane step(s)
  F-->>G: attested replay-idempotency-window lane result + cost usage
  G->>L: write attested replay-idempotency-window lane chain + clock drift window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed short replay-window policy | Attested short-lived token broker + session binding |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-497-benchmark.json` -> `percentage_contract`.

- Metric A (fixed short replay-window policy timeout rate)  
  - Formula: `n_fixed_short_replay_window_timeout / n_gateway_requests_observed`  
  - Value: `412/3400 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_short_replay_window_timeout_rate`
- Metric B (attested short-lived token broker timeout rate)  
  - Formula: `n_replay_idempotency_window_timeout / n_gateway_requests_observed`  
  - Value: `194/3400 = 5.7%` (`synthetic_assumed`)  
  - Path: `percentage_contract.bounded_replay_idempotency_window_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_replay_idempotency_window - n_recovered_fixed_short_replay_window) / n_gateway_requests_observed`  
  - Value: `(3206-2988)/3400 = 6.4 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.bounded_replay_idempotency_window_recovery_gain_pts`

## 6) Production checklist
- [ ] Credential handoff policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, clock drift window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
