# Agent Runtime Prompt Snapshot Delta Compression Selection FAQ (Fixed Full-Snapshot Policy vs Adaptive Delta-Snapshot Compression + Quota Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive prompt snapshot delta compression + quota fence**, not fixed full-snapshot policy as the baseline.
- **Fixed full-snapshot policy propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **Prompt snapshot delta-compression control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed full-snapshot policy**: use fixed cache retention and fixed snapshot windows; easy to reason about but more brittle under uneven load.
- **Adaptive prompt snapshot delta compression + quota fence**: dynamically allocate snapshot budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed full-snapshot policy increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed full-snapshot policy acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> snapshot budget assignment -> admission gate -> replay audit -> snapshot-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox prompt snapshot delta-compression governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive prompt snapshot delta compression + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed full-snapshot policy on low-priority lanes]
  D -- No --> F[Use adaptive snapshot-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed full-snapshot policy] --> B1[Fixed cache TTL + fixed snapshot window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive prompt snapshot delta compression + quota fence] --> B2[Adaptive snapshot window by tenant/session]
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
  G->>F: execute adaptive batch prompt snapshot delta-compression step(s)
  F-->>G: batch prompt snapshot delta-compression result + cost usage
  G->>L: write batch prompt snapshot delta-compression chain + snapshot-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed full-snapshot policy | Adaptive prompt snapshot delta compression + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-474-benchmark.json` -> `percentage_contract`.

- Metric A (fixed full-snapshot policy timeout rate)  
  - Formula: `n_fixed_full_snapshot_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_full_snapshot_timeout_rate`
- Metric B (adaptive prompt snapshot delta compression timeout rate)  
  - Formula: `n_adaptive_delta_snapshot_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_delta_snapshot_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_delta_snapshot - n_recovered_fixed_full_snapshot) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_delta_snapshot_recovery_gain_pts`

## 6) Production checklist
- [ ] Prompt snapshot delta-compression policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, snapshot-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
