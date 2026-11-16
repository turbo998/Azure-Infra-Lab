# Agent Runtime Syscall Filter Profile Selection FAQ (Unfenced Syscall-Profile Rollout vs Syscall-Profile Fence + Staged Syscall-Profile Gate)

## 1) Core conclusions (for decision-makers first)
- **When runtime syscall-filter violation risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to Syscall-Profile Fence + Staged Syscall-Profile Gate**.
- **When unfenced syscall-profile violation overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced Syscall-Profile Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind syscall-profile coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced Syscall-Profile Rollout**: push new syscall-filter policy to all runtime syscall filter profile nodes directly; fast but risky.
- **Syscall-Profile Fence + Staged Syscall-Profile Gate**: constrain accepted syscall profile token versions first, then shift traffic in batches.

### Q1: Why does runtime syscall-profile coherency affect agent stability?
First principles: runtime syscall filter profile lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to syscall-profile-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: runtime-syscall-filter-profile rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use syscall-profile fence + staged syscall-profile gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + syscall-profile contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced runtime-syscall-profile rollout] --> B1[Push syscall-filter policy to all runtime syscall filter profile lanes]
  B1 --> C1[Higher syscall-filter violation amplification]

  A2[Syscall-profile fence + staged syscall-profile gate] --> B2[Fence accepted syscall profile token versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as Syscall-Profile Fence
  participant S as Tool Runtime
  participant P as Syscall-Profile Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate runtime syscall-profile token version
  F-->>G: version admission
  G->>S: execute with admitted syscall-filter policy
  S->>P: fetch syscall-profile record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced Syscall-Profile Rollout | Syscall-Profile Fence + Staged Syscall-Profile Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| Syscall-filter violation risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-554-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced syscall-filter violation rate)  
  - Formula: `n_unfenced_syscall_filter_violation / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_syscall_filter_violation_rate`
- Metric B (syscall-profile fence overrun rate)  
  - Formula: `n_syscall_profile_fence_violation / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.syscall_profile_fence_violation_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_syscall_profile_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.syscall_profile_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has runtime syscall filter profile token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
