# Agent Gateway Speculative Decoding Budget Selection FAQ (Strict Single-Path Decoding vs Adaptive Speculative Decoding Budget)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to adaptive speculative decoding budget**, not strict single-path decoding as the baseline.
- **Strict single-path decoding propagates out-of-order burst pressure into user-visible failures/timeouts** during burst periods.
- **Speculative decoding fences must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the ordering path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Strict single-path decoding**: all requests are serialized through one queue with no partition-aware reordering.
- **Speculative decoding fence + idempotent replay**: partition requests by tenant/session causality and recover safely with idempotent replay.

### Q1: Why does strict single-path decoding increase timeout propagation at scale?
First principles: distributed Gateway systems naturally receive out-of-order events. A single global queue lets one slow partition block unrelated traffic, amplifying queue pressure and tail latency.

### Q2: When is strict single-path decoding acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> causality partition assignment -> admission gate -> idempotent replay audit -> decode-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Gateway speculative decoding governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive speculative decoding budget]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use strict single-path decoding on low-priority lanes]
  D -- No --> F[Use adaptive decode-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Strict single-path decoding] --> B1[Single global queue]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Speculative decoding fence + idempotent replay] --> B2[Partitioned ordering window by tenant/session]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Speculative Decode Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive speculative decoding step(s)
  F-->>G: speculative decoding result + cost usage
  G->>L: write speculative decoding chain + decode-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Strict FIFO queue | Speculative decoding fence + idempotent replay |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-465-benchmark.json` -> `percentage_contract`.

- Metric A (primary-only timeout rate)  
  - Formula: `n_primary_only_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.primary_only_timeout_rate`
- Metric B (speculative-decoding fence timeout rate)  
  - Formula: `n_adaptive_speculative-decoding_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_speculative-decoding_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_speculative-decoding - n_recovered_primary_only) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.speculative-decoding_recovery_gain_pts`

## 6) Production checklist
- [ ] Speculative decoding fence policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, decode-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, ordering chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
