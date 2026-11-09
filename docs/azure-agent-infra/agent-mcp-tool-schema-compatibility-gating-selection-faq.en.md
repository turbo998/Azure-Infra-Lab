# Agent MCP Tool Schema Compatibility Gating Selection FAQ (Strict Version Pinning vs Progressive Compatibility Window)

## 1) Core conclusions (for decision-makers first)
- **For multi-tenant Agent Gateway production, default to progressive compatibility window**, not strict version pinning as the baseline.
- **Strict version pinning propagates schema-transition friction into user-visible failures/timeouts** during burst periods.
- **Compatibility schema-windows must be coupled with tenant quota tiers, retry ceilings, and replay audit**, or the compatibility path becomes an uncontrolled cost amplifier.

## 2) Q1 / Q2 / Q3 (plain-language definitions first)
- **Strict version pinning**: only a fixed tool schema version is accepted; any mismatch is rejected.
- **Progressive compatibility window**: allow a bounded compatibility version window by tenant tier/request class with audit.

### Q1: Why does strict version pinning increase timeout propagation at scale?
First principles: schema evolution has unavoidable transition windows. If compatibility windows are too tight, recoverable requests fail early; failure traffic then amplifies queue pressure and tail latency.

### Q2: When is strict version pinning acceptable?
Low-value traffic lanes with hard cost caps and lower availability requirements.

### Q3: What is the minimum safe control loop?
Request classification -> compatibility window assignment -> admission gate -> failure replay audit -> window retuning.

## 3) Mermaid (decision tree / path comparison / sequence)
### 3.1 Selection decision tree
```mermaid
flowchart TD
  A[Start: Gateway compatibility governance?] --> B{Need predictable low timeout under burst?}
  B -- Yes --> C[Use progressive compatibility window]
  B -- No --> D{Cost cap must be hard and strict?}
  D -- Yes --> E[Use strict version pinning on low-priority lanes]
  D -- No --> F[Use adaptive schema-window with tenant tiers]
  F --> G[Bind quota + retry ceiling + audit]
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Strict version pinning] --> B1[Narrow fixed schema window]
  B1 --> C1[Higher timeout/failure propagation]

  A2[Progressive compatibility window] --> B2[Dynamic schema window by tenant/request]
  B2 --> C2[Lower timeout propagation]
```

### 3.3 Runtime sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant G as AI Gateway
  participant P as Primary Model
  participant F as Compatibility Pool
  participant L as Audit Ledger
  C->>G: request + tenant tier
  G->>P: invoke primary
  P-->>G: timeout/error signal
  G->>F: execute adaptive compatibility step(s)
  F-->>G: compatibility result + cost usage
  G->>L: write compatibility chain + schema-window consumption
  G-->>C: response or fail with policy reason
```

## 4) Decision matrix
| Dimension | Strict version pinning | Progressive compatibility window |
|---|---|---|
| Implementation complexity | Low | Medium |
| Timeout risk control | Medium-Low | High |
| Cost predictability | High (static) | Medium-High (dynamic) |
| Multi-tenant sustainability | Medium | High |
| Default production fit | Low-priority lane only | Long-term default |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-463-benchmark.json` -> `percentage_contract`.

- Metric A (primary-only timeout rate)  
  - Formula: `n_primary_only_timeout / n_runtime_requests_observed`  
  - Value: `286/2600 = 11.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.primary_only_timeout_rate`
- Metric B (adaptive-compatibility timeout rate)  
  - Formula: `n_adaptive_compatibility_timeout / n_runtime_requests_observed`  
  - Value: `146/2600 = 5.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_compatibility_timeout_rate`
- Metric C (recovery gain, percentage points)  
  - Formula: `(n_recovered_adaptive_compatibility - n_recovered_primary_only) / n_runtime_requests_observed`  
  - Value: `(2435-2314)/2600 = 4.7 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.compatibility_recovery_gain_pts`

## 6) Production checklist
- [ ] Compatibility schema-window policy has versioning, rollout, and rollback controls
- [ ] Tenant tiers, schema-window usage, and retry ceilings are observable and auditable
- [ ] Timeout events, compatibility chains, and replay audits are tenant-traceable
- [ ] All metrics are tagged `synthetic_assumed` with denominator/unit; production validation remains `not_measured`
