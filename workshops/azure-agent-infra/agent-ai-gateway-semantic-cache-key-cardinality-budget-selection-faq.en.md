# Agent AI Gateway Semantic Cache Key Cardinality Budget Selection FAQ (Unfenced Key-Cardinality Rollout vs Key-Cardinality Fence + Staged Keycard Gate)

## 1) Core conclusions (for decision-makers first)
- **When AI Gateway semantic cache key explosion jitter risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Key-Cardinality Fence + Staged Keycard Gate**.
- **When unfenced semantic cache key explosion overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Key-Cardinality Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind cache-key token coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Key-Cardinality Rollout**: push new semantic cache key policy to all AI Gateway semantic cache key cardinality budget threshold nodes directly; fast but risky.
- **Key-Cardinality Fence + Staged Keycard Gate**: constrain accepted cache-key token versions first, then shift traffic in batches.

### Q1: Why does runtime cache-key token coherency affect agent stability?
First principles: AI Gateway semantic cache key cardinality budget threshold lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to key-cardinality-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: ai-gateway-semantic-cache-key-cardinality-budget rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use cache-key token fence + staged keycard gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + cache-key token contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced runtime capability rollout] --> B1[Push semantic cache key policy to all AI Gateway semantic cache key cardinality budget threshold lanes]
  B1 --> C1[Higher semantic cache key explosion amplification]

  A2[cache-key token fence + staged keycard gate] --> B2[Fence accepted cache-key token versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as DNS-Cache Fence
  participant S as Tool Runtime
  participant P as DNS-Cache Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate runtime cache-key token version
  F-->>G: version admission
  G->>S: execute with admitted semantic cache key policy
  S->>P: fetch cache-key token record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Key-Cardinality Rollout | Key-Cardinality Fence + Staged Keycard Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| semantic cache key explosion risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-574-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced semantic cache key explosion rate)  
  - Formula: `n_unfenced_semantic_cache_key_explosion / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_semantic_cache_key_explosion_rate`
- Metric B (cache-key token fence overrun rate)  
  - Formula: `n_key_cardinality_fence_explosion / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.key_cardinality_fence_explosion_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_key_cardinality_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.key_cardinality_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has AI Gateway semantic cache key cardinality budget threshold token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
