# Agent Memory Checkpoint Restore Consistency Fence Selection FAQ (Unfenced Restore Rollout vs Restore-Consistency Fence + Staged Restore Gate)

## 1) Core conclusions (for decision-makers first)
- **When memory-checkpoint restore divergence risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Restore-Consistency Fence + Staged Restore Gate**.
- **When unfenced restore divergence overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Restore Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind restore-consistency coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Restore Rollout**: push new checkpoint-restore policy to all memory-checkpoint restore consistency fence nodes directly; fast but risky.
- **Restore-Consistency Fence + Staged Restore Gate**: constrain accepted checkpoint token versions first, then shift traffic in batches.

### Q1: Why does memory-checkpoint restore-consistency coherency affect agent stability?
First principles: memory-checkpoint restore consistency fence lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to restore-consistency-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: memory-checkpoint-restore-consistency-fence rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use restore-consistency fence + staged restore gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + checkpoint-consistency contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced memory-checkpoint-restore rollout] --> B1[Push checkpoint-restore policy to all memory-checkpoint restore consistency fence lanes]
  B1 --> C1[Higher checkpoint-restore divergence amplification]

  A2[Restore-consistency fence + staged restore gate] --> B2[Fence accepted checkpoint token versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Restore-Consistency Fence
  participant S as Tool Runtime
  participant P as Checkpoint Restore Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate memory-checkpoint restore token version
  F-->>G: version admission
  G->>S: execute with admitted checkpoint-restore policy
  S->>P: fetch checkpoint-restore record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Restore Rollout | Restore-Consistency Fence + Staged Restore Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| Checkpoint-restore divergence risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-551-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced checkpoint-restore divergence rate)  
  - Formula: `n_unfenced_checkpoint_restore_divergence / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_checkpoint_restore_divergence_rate`
- Metric B (restore-consistency fence overrun rate)  
  - Formula: `n_restore_consistency_fence_divergence / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.restore_consistency_fence_divergence_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_restore_consistency_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.restore_consistency_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has memory-checkpoint restore consistency fence token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
