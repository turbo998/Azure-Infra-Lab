# Agent Runtime Tenant Burst-Credit Bucket Selection FAQ (Fixed Credit Bucket vs Adaptive Burst-Credit Bucket + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant production, default to Adaptive Burst-Credit Bucket + Drift Budget Guard**, not fixed credit buckets.
- **Fixed quota slices amplify queue congestion under tenant skew**, driving timeout cascades and retry storms.
- **Admission controls must couple tenant identity, queue depth, retry ceilings, and audit lineage**, or apparent quota sufficiency still collapses under hotspots.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed Credit Bucket**: static per-tenant partitioning. Predictable rules, poor utilization under skew.
- **Adaptive Burst-Credit Bucket + Drift Budget Guard**: dynamic quota repartition by heat signal, bounded by drift budget gates.

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
  A[Start: burst-credit admission strategy?] --> B{Need stable latency under tenant skew?}
  B -- Yes --> C[Use Adaptive Burst-Credit Bucket + Drift Budget Guard]
  B -- No --> D{Only temporary low-risk lane?}
  D -- Yes --> E[Temporary fixed quota slice]
  D -- No --> F[Use adaptive shard baseline]
  F --> G[Bind identity + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed quota slice] --> B1[Static tenant partition]
  B1 --> C1[Higher hotspot starvation and timeout propagation]

  A2[Adaptive burst-credit bucket] --> B2[Heat-aware dynamic partition]
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
  G->>R: schedule request with burst-credit bucket
  R-->>G: result + timeout/usage signal
  G->>L: write shard decision chain + budget consumption
  G-->>C: response or policy failure reason
```

## 4) Decision matrix
| Dimension | Fixed Credit Bucket | Adaptive Burst-Credit Bucket + Drift Budget Guard |
|---|---|---|
| Implementation complexity | Low | Medium |
| Hotspot resilience | Medium-Low | High |
| Timeout risk control | Medium-Low | High |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Temporary low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-511-benchmark.json` -> `percentage_contract`.

- Metric A (fixed credit-bucket timeout rate)  
  - Formula: `n_fixed_credit_bucket_timeout / n_gateway_requests_observed`  
  - Value: `451/3880 = 11.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_credit_bucket_timeout_rate`
- Metric B (adaptive burst-credit-bucket timeout rate)  
  - Formula: `n_adaptive_burst_credit_timeout / n_gateway_requests_observed`  
  - Value: `206/3880 = 5.3%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_burst_credit_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_burst - n_recovered_fixed_credit_bucket) / n_gateway_requests_observed`  
  - Value: `(3659-3429)/3880 = 5.9 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_burst_credit_recovery_gain_pts`

## 6) Production checklist
- [ ] Burst-credit admission policy has versioning, staged rollout, and rollback controls
- [ ] Tenant heat, queue depth, retry ceilings, and drift budgets are observable and auditable
- [ ] Starvation events, timeout chains, and replay paths are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
