# Agent MCP Session Lease Heartbeat Selection FAQ (Static Lease TTL vs Adaptive Heartbeat Renewal)

## 1) Core conclusions
- **Production multi-tenant deployments should default to adaptive heartbeat renewal with lease-extension budgets**, not long-term static lease TTL.
- **Static lease TTL is more prone to false session expiry under jittery networks or slow tools**, increasing rebuild cost and tail latency.
- **Lease-heartbeat governance must be coupled with tenant entitlements, gateway policy, and replay audit loops** for both stability and compliance boundaries.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Static lease TTL**: fixed session lifetime; simple but less elastic.
- **Adaptive heartbeat renewal**: dynamically extends leases based on session activity and risk profile.

### Q1: Why is static lease TTL risky in production?
First principle: tool/runtime/network latency fluctuates; fixed expiry thresholds can misclassify active sessions as idle and expire them too early.

### Q2: When is static lease TTL acceptable?
Short-lived single-tenant workloads with stable networks and tolerance for occasional session rebuilds.

### Q3: What is the minimum safe lease-heartbeat control loop?
Tenant lease entitlement -> base TTL policy -> heartbeat sampling + renewal decision -> extension budget gate -> session lifecycle audit ledger.

## 3) Mermaid (MCP session lease-heartbeat governance loop)
```mermaid
flowchart LR
  A[Session Request] --> B[Lease Entitlement Gate]
  B --> C[Base TTL Policy]
  C --> D[Heartbeat Sampler]
  D --> E[Lease Extension Budget Controller]
  E --> F[Session Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) Decision matrix
| Dimension | Static lease TTL | Adaptive heartbeat renewal |
|---|---|---|
| Implementation complexity | Low | Medium |
| Jitter resilience | Low | High |
| False-expiry control | Low-Medium | High |
| Multi-tenant governance depth | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-432-benchmark.json` -> `percentage_contract`.

- Metric A (session-expiry rate, static lease TTL)  
  - Formula: `n_expiry_static_ttl / n_sessions_observed`  
  - Value: `288/2400 = 12.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.static_lease_expiry_rate`
- Metric B (session-expiry rate, adaptive heartbeat renewal)  
  - Formula: `n_expiry_adaptive_heartbeat / n_sessions_observed`  
  - Value: `86/2400 = 3.6%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_heartbeat_expiry_rate`
- Metric C (lease-recovery success gain, percentage points)  
  - Formula: `(n_recovery_success_adaptive - n_recovery_success_static) / n_sessions_observed`  
  - Value: `(2140-1938)/2400 = 8.4 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.lease_recovery_gain_pts`

## 6) Production checklist
- [ ] Base TTL and heartbeat-renewal policies are versioned with rollout and rollback controls
- [ ] Tenant lease entitlement and extension-budget gates are enforced at gateway level
- [ ] Session expiry, renewal success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
