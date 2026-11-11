# Agent Session State Compaction Watermark Lag Selection FAQ (Unfenced Compaction Rollout vs Watermark-Lag Fence + Staged Compaction Gate)

## 1) Core conclusions (for decision-makers first)
- **When session-state compaction watermark lag risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Watermark-Lag Fence + Staged Compaction Gate**.
- **When unfenced compaction rollout overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Compaction Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind watermark-coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Compaction Rollout**: push new compaction policy to all session-state compaction watermark nodes directly; fast but risky.
- **Watermark-Lag Fence + Staged Compaction Gate**: constrain accepted watermark versions first, then shift traffic in batches.

### Q1: Why does session-state compaction watermark cache coherency affect agent stability?
First principles: session-state compaction watermark lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to watermark-lag-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: session-state-compaction-watermark-cache rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use watermark-lag fence + staged compaction gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback watermark + watermark contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced session-state-compaction-watermark-cache rollout] --> B1[Push compaction policy to all session-state compaction watermark lanes]
  B1 --> C1[Higher session-state-compaction-watermark-cache-drift amplification]

  A2[Watermark-lag fence + staged compaction gate] --> B2[Fence accepted watermark versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Watermark-Lag Fence
  participant S as Runtime Session State
  participant P as Compaction Watermark Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate session-state compaction watermark cache version
  F-->>G: version admission
  G->>S: execute with admitted compaction policy
  S->>P: fetch watermark entry
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Compaction Rollout | Watermark-Lag Fence + Staged Compaction Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| Watermark-lag overrun risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-549-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced session-state-compaction-watermark-cache drift rate)  
  - Formula: `n_unfenced_compaction_lag_overrun / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_compaction_lag_overrun_rate`
- Metric B (watermark-lag fence overrun rate)  
  - Formula: `n_watermark_lag_fence_overrun / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.watermark_lag_fence_overrun_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_watermark_lag_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.watermark_lag_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has session-state compaction watermark cache-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
