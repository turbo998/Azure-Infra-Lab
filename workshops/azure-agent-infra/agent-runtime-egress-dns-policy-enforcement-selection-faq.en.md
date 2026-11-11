# Agent Runtime Egress DNS Policy Enforcement Selection FAQ (Unfenced DNS-Policy Rollout vs DNS-Enforcement Fence + Staged DNS-Policy Gate)

## 1) Core conclusions (for decision-makers first)
- **When runtime egress DNS-policy breach risk exceeds 22% and verification wait P95 exceeds 182ms, production should default to DNS-Enforcement Fence + Staged DNS-Policy Gate**.
- **When unfenced DNS-policy breach overrun exceeds 12% and rollback retry P95 exceeds 252ms, Unfenced DNS-Policy Rollout enters the 12.1% overrun amplification band**.
- **Multi-tenant runtimes must bind DNS-enforcement coherency fences, rollout batches, and rollback thresholds**, or policy execution and throughput stability degrade together.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Unfenced DNS-Policy Rollout**: push new egress DNS policy to all runtime egress DNS policy enforcement nodes directly; fast but risky.
- **DNS-Enforcement Fence + Staged DNS-Policy Gate**: constrain accepted DNS policy token versions first, then shift traffic in batches.

### Q1: Why does runtime DNS-policy coherency affect agent stability?
First principles: runtime egress DNS policy enforcement lanes enforce policy and traffic governance. Cache-version drift causes execution divergence across nodes, amplifying retries and tail latency.

### Q2: When is unfenced rollout acceptable temporarily?
Only in single-tenant low-traffic maintenance windows. Multi-tenant production should default to DNS-enforcement-fenced rollout.

### Q3: What is the minimum safe loop?
Version sampling -> fence validation -> staged rollout -> drift alerts -> automated rollback.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: runtime-egress-dns-policy-enforcement rollout strategy?] --> B{Drift risk >22% OR verify wait P95 >182ms?}
  B -- Yes --> C[Use DNS-enforcement fence + staged DNS-policy gate]
  B -- No --> D{Single-tenant maintenance window?}
  D -- Yes --> E[Allow unfenced rollout temporarily]
  D -- No --> F[Enable tenant-lane staged rollout]
  F --> G[Bind rollback token guard + DNS-enforcement contract]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unfenced runtime-DNS-policy rollout] --> B1[Push egress DNS policy to all runtime egress DNS policy enforcement lanes]
  B1 --> C1[Higher DNS-policy breach amplification]

  A2[DNS-enforcement fence + staged DNS-policy gate] --> B2[Fence accepted DNS policy token versions then canary rollout]
  B2 --> C2[Lower drift risk with deterministic rollback]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant F as DNS-Enforcement Fence
  participant S as Tool Runtime
  participant P as DNS-Policy Cache
  participant L as Audit Ledger
  C->>G: tool/model request
  G->>F: validate runtime DNS-policy token version
  F-->>G: version admission
  G->>S: execute with admitted egress DNS policy
  S->>P: fetch DNS-policy record
  P-->>S: policy verdict
  G->>L: log drift/retry latency
  G-->>C: guarded response
```

## 4) Decision matrix
| Dimension | Unfenced DNS-Policy Rollout | DNS-Enforcement Fence + Staged DNS-Policy Gate |
|---|---|---|
| Implementation complexity | Low | Medium |
| DNS-policy breach risk | High | Low |
| Multi-tenant controllability | Low | High |
| Rollback determinism | Medium | High |
| Default production fit | Maintenance windows only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-555-benchmark.json` -> `percentage_contract`.

- Metric A (unfenced DNS-policy breach rate)  
  - Formula: `n_unfenced_dns_policy_breach / n_gateway_requests_observed`  
  - Value: `534/4410 = 12.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.unfenced_dns_policy_breach_rate`
- Metric B (DNS-enforcement fence overrun rate)  
  - Formula: `n_dns_enforcement_fence_breach / n_gateway_requests_observed`  
  - Value: `216/4410 = 4.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.dns_enforcement_fence_breach_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `n_dns_enforcement_fence_recovery_gain / n_gateway_requests_observed`  
  - Value: `330/4410 = 7.5 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.dns_enforcement_fence_recovery_gain_pts`

## 6) Production checklist
- [ ] Every tenant has runtime egress DNS policy enforcement token-version allow-lists and rollout batches
- [ ] Drift rate, retry latency, and rollback success are observable and auditable
- [ ] Change flow supports canary rollout, fast rollback, and tiered promotion
- [ ] All metrics are tagged `synthetic_assumed`; production validation remains `not_measured`
