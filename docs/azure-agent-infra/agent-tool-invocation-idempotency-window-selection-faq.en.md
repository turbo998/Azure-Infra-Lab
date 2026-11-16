# Agent Tool Invocation Idempotency Window Selection FAQ (Unfenced Invocation Rollout vs Idempotency-Window Fence + Staged Invocation Gate)

## 1) Core conclusions (for decision-makers first)
- **When tool-invocation idempotency duplicate risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Idempotency-Window Fence + Staged Invocation Gate**.
- **When unfenced invocation duplicate overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Invocation Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind idempotency-window coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Invocation Rollout**: push new idempotency policy to all tool-invocation idempotency window nodes directly; fast but risky.
- **Idempotency-Window Fence + Staged Invocation Gate**: constrain accepted idempotency token versions first, then shift traffic in batches.

### Q1: Why does tool-invocation idempotency-window coherency affect agent stability?
First principles: tool-invocation idempotency window lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to idempotency-window-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: tool-invocation-idempotency-window rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use idempotency-window fence + staged invocation gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token watermark + idempotency contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced tool-invocation-idempotency-window rollout] --> B1[Push idempotency policy to all tool-invocation idempotency window lanes]
  B1 --> C1[Higher tool-invocation-idempotency-window-drift amplification]

  A2[Idempotency-window fence + staged invocation gate] --> B2[Fence accepted idempotency token versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Idempotency-Window Fence
  participant S as Tool Runtime
  participant P as Idempotency Window Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate tool-invocation idempotency-window token version
  F-->>G: version admission
  G->>S: execute with admitted idempotency policy
  S->>P: fetch idempotency record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Invocation Rollout | Idempotency-Window Fence + Staged Invocation Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| Duplicate-invocation risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-550-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced tool-invocation duplicate rate)  
  - Formula: `n_unfenced_tool_invocation_duplicate / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_tool_invocation_duplicate_rate`
- Metric B (idempotency-window fence overrun rate)  
  - Formula: `n_idempotency_window_fence_duplicate / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.idempotency_window_fence_duplicate_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_idempotency_window_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.idempotency_window_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has tool-invocation idempotency window token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
