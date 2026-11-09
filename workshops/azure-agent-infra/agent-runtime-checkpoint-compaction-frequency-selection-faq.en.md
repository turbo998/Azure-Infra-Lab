# Agent Runtime Checkpoint Compaction Frequency Selection FAQ (Fixed Full Compaction Window vs Adaptive Incremental Compaction + Checkpoint Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime sandbox production, default to adaptive incremental compaction + checkpoint fence**, not fixed full compaction window as the baseline.
- **Fixed full compaction window propagates restore burst pressure into user-visible failures/timeouts** during peak recovery windows.
- **Incremental checkpoint compactions must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the recovery path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed full compaction window**: each recovery runs full compaction windows, minimizing logic complexity but increasing restore latency and I/O spikes.
- **Adaptive incremental compaction + checkpoint fence**: restore from bounded incremental compaction segments with checkpoint fences for consistency and auditable replay.

### Q1: Why does fixed full compaction window increase timeout propagation at scale?
First principles: runtime recovery is bursty. If every resume path reloads full snapshots, one slow session can stall adjacent recovery lanes and amplify tail latency.

### Q2: When is fixed full compaction window acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> journal budget assignment -> admission gate -> replay audit -> compaction-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox checkpoint compaction governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive incremental compaction + checkpoint fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed full compaction window on low-priority lanes]
  D -- No --> F[Use adaptive compaction-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Strict snapshot reload] --> B1[Full snapshot reload each recovery]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Incremental checkpoint compaction + checkpoint fence] --> B2[Bounded replay window by tenant/session]
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
  G->>F: execute adaptive batch checkpoint compaction step(s)
  F-->>G: batch checkpoint compaction result + cost usage
  G->>L: write batch checkpoint compaction chain + compaction-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Strict snapshot reload | Incremental checkpoint compaction + checkpoint fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-468-benchmark.json` -> `percentage_contract`.

- Metric A (primary-only timeout rate)  
  - Formula: `n_primary_only_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_full_compaction_timeout_rate`
- Metric B (adaptive incremental compaction timeout rate)  
  - Formula: `n_adaptive_incremental_compaction_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_incremental_compaction_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_incremental_compaction - n_recovered_fixed_full_compaction) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.incremental_compaction_recovery_gain_pts`

## 6) Production checklist
- [ ] Incremental checkpoint compaction policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, compaction-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
