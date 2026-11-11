# Agent APIM MCP Response Size Watermark Selection FAQ (Unfenced Size-Watermark Rollout vs Size-Watermark Fence + Staged Quota Gate)

## 1) Core conclusions (for decision-makers first)
- **When Foundry model router context-drift risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Size-Watermark Fence + Staged Quota Gate**.
- **When unfenced context-drift overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Size-Watermark Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind size token coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Size-Watermark Rollout**: push new size token retention policy to all Foundry model router ACA dynamic sessions pool TTL ladder threshold nodes directly; fast but risky.
- **Size-Watermark Fence + Staged Quota Gate**: constrain accepted size token versions first, then shift traffic in batches.

### Q1: Why does runtime size token coherency affect agent stability?
First principles: Foundry model router ACA dynamic sessions pool TTL ladder threshold lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to size-watermark-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: aks-kata-pod-density-safety-margin rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use size token fence + staged quota gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + size token contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced runtime capability rollout] --> B1[Push size token retention policy to all Foundry model router ACA dynamic sessions pool TTL ladder threshold lanes]
  B1 --> C1[Higher snapshot restore tail drift amplification]

  A2[size token fence + staged quota gate] --> B2[Fence accepted size token versions then canary rollout]
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
  G->>F: validate runtime size token version
  F-->>G: version admission
  G->>S: execute with admitted size token retention policy
  S->>P: fetch size token record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Size-Watermark Rollout | Size-Watermark Fence + Staged Quota Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| context-drift risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-621-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced snapshot restore tail drift rate)  
  - Formula: `n_unfenced_quota_starvation / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_size_watermark_drift_rate`
- Metric B (size token fence overrun rate)  
  - Formula: `n_quota_decay_fence_starvation / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.size_watermark_fence_variance_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_quota_decay_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.size_watermark_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has Foundry model router ACA dynamic sessions pool TTL ladder threshold token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
