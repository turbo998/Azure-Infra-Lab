# Agent MCP Tool Version Skew Firebreak Selection FAQ (Fixed Global-Upgrade Window vs Adaptive Version-Skew Firebreak + Compatibility Fence)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Runtime production, default to adaptive MCP tool version skew firebreak + quota fence**, not fixed global-upgrade window as the baseline.
- **Fixed global-upgrade window propagates burst pressure into user-visible failures/timeouts** during peak traffic windows.
- **MCP tool version-skew firebreak control loops must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the runtime path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Fixed global-upgrade window**: use fixed cache retention and fixed skew windows; easy to reason about but more brittle under uneven load.
- **Adaptive MCP tool version skew firebreak + quota fence**: dynamically allocate compatibility budgets per tenant/session while preserving auditable policy boundaries.

### Q1: Why does fixed global-upgrade window increase timeout propagation at scale?
First principles: cache heat is uneven. Fixed TTL windows over-retain cold keys while evicting hot keys too late, which amplifies tail latency.

### Q2: When is fixed global-upgrade window acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> compatibility budget assignment -> admission gate -> replay audit -> skew-window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Runtime sandbox MCP tool version-skew firebreak governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use adaptive MCP tool version skew firebreak + quota fence]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use fixed global-upgrade window on low-priority lanes]
  D -- No --> F[Use adaptive skew-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Fixed global-upgrade window] --> B1[Fixed cache TTL + fixed skew window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Adaptive MCP tool version skew firebreak + quota fence] --> B2[Adaptive skew window by tenant/session]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Runtime Session Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive batch MCP tool version-skew firebreak step(s)
  F-->>G: batch MCP tool version-skew firebreak result + cost usage
  G->>L: write batch MCP tool version-skew firebreak chain + skew-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Fixed global-upgrade window | Adaptive MCP tool version skew firebreak + quota fence |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-476-benchmark.json` -> `percentage_contract`.

- Metric A (fixed global-upgrade window timeout rate)  
  - Formula: `n_fixed_global_upgrade_timeout / n_gateway_requests_observed`  
  - Value: `294/2800 = 10.5%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_global_upgrade_timeout_rate`
- Metric B (adaptive MCP tool version skew firebreak timeout rate)  
  - Formula: `n_adaptive_version_skew_timeout / n_gateway_requests_observed`  
  - Value: `151/2800 = 5.4%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_version_skew_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_version_skew - n_recovered_fixed_global_upgrade) / n_gateway_requests_observed`  
  - Value: `(2649-2506)/2800 = 5.1 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_version_skew_recovery_gain_pts`

## 6) Production checklist
- [ ] MCP tool version-skew firebreak policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, skew-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, recovery chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
