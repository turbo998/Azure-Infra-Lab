# Agent Sandbox Clock-Source Attestation Fence Selection FAQ (Fixed Host Wall-Clock Trust vs Clock-Source Attestation Fence + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to clock-source attestation fence + drift budget guard**, not fixed host wall-clock trust as the baseline.
- **Fixed in-band env secret injection propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Ephemeral clock-source attestation fence lane control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed in-band env secret injection**: use fixed in-band injection and fixed clock-source attestation fence lane windows; easy to reason about but more brittle under uneven load.
- **Attested short-lived token broker + session binding**: dynamically allocate clock-source attestation fence lane budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed host wall-clock trust increase timeout propagation at scale?
First principles: retries and network jitter are inevitable. Without monotonic-clock fences, duplicate write calls are executed as new operations, amplifying timeout and side-effect risk.

### Q2: When is fixed host wall-clock trust acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> clock-source attestation fence lane budget assignment -> admission gate -> replay audit -> handoff-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox clock-source attestation fence governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use clock-source attestation fence + drift budget guard]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed host wall-clock trust on low-priority lanes]
  D -- No --> F[Use adaptive clock-source attestation fence lane window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed in-band env secret injection] --> B1[Fixed in-band secret injection + fixed clock-source attestation fence lane window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Attested short-lived token broker + session binding] --> B2[Adaptive clock-source attestation fence lane window by tenant/session]
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
  G->>F: execute attested short-lived clock-source attestation fence lane step(s)
  F-->>G: attested clock-source attestation fence lane result + cost usage
  G->>L: write attested clock-source attestation fence lane chain + clock drift window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed in-band env secret injection | Attested short-lived token broker + session binding |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-487-benchmark.json` -> `percentage_contract`.

- Metric A (fixed host wall-clock trust timeout rate)  
  - Formula: `n_fixed_wall_clock_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_wall_clock_timeout_rate`
- Metric B (attested short-lived token broker timeout rate)  
  - Formula: `n_clock_attestation_fence_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.clock_attestation_fence_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_clock_attestation_fence - n_recovered_fixed_wall_clock) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.clock_attestation_recovery_gain_pts`

## 6) Production checklist
- [ ] Credential handoff policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, clock drift window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
