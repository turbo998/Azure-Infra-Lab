# Agent Private Link SNAT Port Budget Fence Selection FAQ (Unfenced SNAT Rollout vs SNAT Port Fence + Staged SNAT Gate)

## 1) Core conclusions (for decision-makers first)
- **When Private Link outbound SNAT exhaustion risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to SNAT Port Fence + Staged SNAT Gate**.
- **When unfenced SNAT exhaustion overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced SNAT Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind SNAT token coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced SNAT Rollout**: push new SNAT budget policy to all Private Link outbound SNAT port budget fence nodes directly; fast but risky.
- **SNAT Port Fence + Staged SNAT Gate**: constrain accepted SNAT token versions first, then shift traffic in batches.

### Q1: Why does runtime SNAT token coherency affect agent stability?
First principles: Private Link outbound SNAT port budget fence lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to SNAT-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: private-link-snat-port-budget-fence rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use SNAT token fence + staged SNAT gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + SNAT token contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced runtime SNAT rollout] --> B1[Push SNAT budget policy to all Private Link outbound SNAT port budget fence lanes]
  B1 --> C1[Higher SNAT token cache staleness amplification]

  A2[SNAT token fence + staged SNAT gate] --> B2[Fence accepted SNAT token versions then canary rollout]
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
  G->>F: validate runtime SNAT token version
  F-->>G: version admission
  G->>S: execute with admitted SNAT budget policy
  S->>P: fetch SNAT token record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced SNAT Rollout | SNAT Port Fence + Staged SNAT Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| SNAT token cache staleness risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-561-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced SNAT token cache staleness rate)  
  - Formula: `n_unfenced_snat_exhaustion / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_snat_exhaustion_rate`
- Metric B (SNAT token fence overrun rate)  
  - Formula: `n_snat_fence_exhaustion / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.snat_fence_exhaustion_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_snat_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.snat_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has Private Link outbound SNAT port budget fence token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
