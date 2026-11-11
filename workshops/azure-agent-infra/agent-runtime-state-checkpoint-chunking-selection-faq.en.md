# Agent Runtime State Checkpoint Chunking Selection FAQ (Fixed Monolithic Checkpoint vs Adaptive Chunked Checkpoint + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant production, default to Adaptive Chunked Checkpoint + Drift Budget Guard**, not fixed monolithic checkpoints.
- **Fixed quota slices amplify queue congestion under tenant skew**, driving timeout cascades and retry storms.
- **Admission controls must couple tenant identity, queue depth, retry ceilings, and audit lineage**, or apparent quota sufficiency still collapses under hotspots.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed Monolithic Checkpoint**: static per-tenant partitioning. Predictable rules, poor utilization under skew.
- **Adaptive Chunked Checkpoint + Drift Budget Guard**: dynamic quota repartition by heat signal, bounded by drift budget gates.

### Q1: Why are fixed slices fragile at high concurrency?
First principles: traffic is not evenly distributed. Static partitions starve hot tenants while cold partitions sit idle, reducing total throughput.

### Q2: When are fixed slices still acceptable?
Only for temporary environments with stable traffic shape, small peak-to-valley gaps, and low rollback complexity.

### Q3: What is the minimum safe control loop?
Request classification -> shard heat monitoring -> dynamic quota migration -> timeout/failure audit -> periodic recalibration.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: checkpoint admission strategy?] --> B{Need stable latency under tenant skew?}
  B -- Yes --> C[Use Adaptive Chunked Checkpoint + Drift Budget Guard]
  B -- No --> D{Only temporary low-risk lane?}
  D -- Yes --> E[Temporary fixed quota slice]
  D -- No --> F[Use adaptive shard baseline]
  F --> G[Bind identity + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed monolithic checkpoint] --> B1[Static tenant partition]
  B1 --> C1[Higher hotspot starvation and timeout propagation]

  A2[Adaptive state checkpoint chunking] --> B2[Heat-aware dynamic partition]
  B2 --> C2[Lower starvation and steadier tail latency]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant Q as Quota Controller
  participant R as Runtime Session Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>Q: query shard admission policy
  Q-->>G: shard target + drift budget gate
  G->>R: schedule request with state checkpoint chunking
  R-->>G: result + timeout/usage signal
  G->>L: write shard decision chain + budget consumption
  G-->>C: response or policy failure reason
```

## 4) Decision matrix
| Dimension | Fixed Monolithic Checkpoint | Adaptive Chunked Checkpoint + Drift Budget Guard |
|---|---|---|
| Implementation complexity | Low | Medium |
| Hotspot resilience | Medium-Low | High |
| Timeout risk control | Medium-Low | High |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Temporary low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-512-benchmark.json` -> `percentage_contract`.

- Metric A (fixed monolithic-checkpoint timeout rate)  
  - Formula: `n_fixed_monolithic_checkpoint_timeout / n_gateway_requests_observed`  
  - Value: `478/4010 = 11.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_monolithic_checkpoint_timeout_rate`
- Metric B (adaptive state-checkpoint-chunking timeout rate)  
  - Formula: `n_adaptive_chunked_checkpoint_timeout / n_gateway_requests_observed`  
  - Value: `223/4010 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_chunked_checkpoint_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_chunked - n_recovered_fixed_monolithic) / n_gateway_requests_observed`  
  - Value: `(3728-3504)/4010 = 5.6 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_chunked_checkpoint_recovery_gain_pts`

## 6) Production checklist
- [ ] Chunked-checkpoint admission policy has versioning, staged rollout, and rollback controls
- [ ] Tenant heat, queue depth, retry ceilings, and drift budgets are observable and auditable
- [ ] Starvation events, timeout chains, and replay paths are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
