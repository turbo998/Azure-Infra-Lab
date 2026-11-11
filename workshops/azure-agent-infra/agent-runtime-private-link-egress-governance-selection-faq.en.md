# Agent Runtime Private-Link Egress Governance Selection FAQ (Fixed Public Egress vs Private-Link Egress + Drift Budget Guard)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant production, default to Private-Link Egress + Drift Budget Guard**, not long-term fixed public egress.
- **Fixed public egress amplifies timeout propagation and exposure risk under burst load**, increasing both retries and compliance pressure.
- **Private egress controls must be coupled with quota tiers, retry ceilings, audit lineage, and alerts**, or emergency bypasses will erode zero-trust boundaries.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed Public Egress**: shared NAT/public egress lane. Fast to enable, but coarse boundary and weaker tenant isolation.
- **Private-Link Egress + Drift Budget Guard**: tenant-bound private route with per-session budget gates and deterministic fallback policy.

### Q1: Why is fixed public egress riskier at high concurrency?
First principles: shared egress is a contention hotspot. Congestion and retries reinforce each other, while broad egress policy exceptions expand blast radius.

### Q2: When is fixed public egress still acceptable?
Only as a temporary lane for low-value traffic with explicit migration deadline to private-link controls.

### Q3: What is the minimum safe control loop?
Request classification -> private egress binding -> session budget gate -> timeout/failure audit -> recurrent chaos drills.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime egress governance strategy?] --> B{Need strict zero-trust and private network boundary?}
  B -- Yes --> C[Use Private-Link Egress + Drift Budget Guard]
  B -- No --> D{Only short-term low-risk lane?}
  D -- Yes --> E[Temporary fixed public egress lane]
  D -- No --> F[Use private-link baseline]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed public egress] --> B1[Shared NAT bottleneck + coarse policy boundary]
  B1 --> C1[Higher timeout/failure propagation and larger compliance exposure]

  A2[Private-link egress] --> B2[Tenant-bound private path + session policy]
  B2 --> C2[Lower timeout propagation and tighter compliance boundary]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant N as Private Link/NAT Policy
  participant R as Runtime Session
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>N: resolve tenant egress policy
  N-->>G: private-link route + budget gate
  G->>R: invoke tool/model call over private path
  R-->>G: result + timeout/usage signal
  G->>L: write egress route chain + drift budget consumption
  G-->>C: response or policy failure reason
```

## 4) Decision matrix
| Dimension | Fixed Public Egress | Private-Link Egress + Drift Budget Guard |
|---|---|---|
| Implementation complexity | Low | Medium |
| Egress exposure surface | High | Low |
| Timeout risk control | Medium-Low | High |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Temporary low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-505-benchmark.json` -> `percentage_contract`.

- Metric A (fixed public egress timeout rate)  
  - Formula: `n_fixed_public_egress_timeout / n_gateway_requests_observed`  
  - Value: `463/3900 = 11.9%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_public_egress_timeout_rate`
- Metric B (private-link egress timeout rate)  
  - Formula: `n_private_link_egress_timeout / n_gateway_requests_observed`  
  - Value: `226/3900 = 5.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.private_link_egress_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_private_link - n_recovered_public_egress) / n_gateway_requests_observed`  
  - Value: `(3621-3404)/3900 = 5.6 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.private_link_recovery_gain_pts`

## 6) Production checklist
- [ ] Private-link egress policy has versioning, staged rollout, and rollback controls
- [ ] Route binding, tenant quotas, retry ceilings, and drift budgets are observable and auditable
- [ ] Egress bypasses, timeout chains, and replay paths are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
