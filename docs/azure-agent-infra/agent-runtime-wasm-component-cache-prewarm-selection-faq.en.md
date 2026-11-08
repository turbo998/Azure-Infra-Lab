# Agent Runtime Wasm Component Cache Prewarm Selection FAQ (Fixed Prewarm Pool vs Adaptive Prewarm Pool)

## 1) Core conclusions
- **Production multi-tenant deployments should default to adaptive prewarm pools plus burst-budget gates**, not long-term fixed prewarm pools.
- **Fixed prewarm pools are more likely to trigger avoidable prewarm misses under bursty cold starts and slow tool initialization**, increasing fallback and tail-latency cost.
- **Prewarm governance must be coupled with tenant entitlements, gateway policy, and replay audit loops** to satisfy both reliability and compliance boundaries.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Fixed prewarm pool**: fixed number of warm instances; simple to run but less elastic under bursty cold starts.
- **Adaptive prewarm pool**: dynamically adjusts warm capacity based on cold-start pressure and risk profile.

### Q1: Why is a fixed prewarm pool risky in production?
First principle: request rates and initialization latency fluctuate continuously; static warm capacity misses more requests during spikes and amplifies fallback cold starts.

### Q2: When is a fixed prewarm pool acceptable?
Short-lived single-tenant workloads with stable traffic and tolerance for occasional drop-and-retry cycles.

### Q3: What is the minimum safe prewarm control loop?
Tenant runtime entitlement -> base prewarm-pool policy -> cold-start sampling + capacity decision -> burst-budget gate -> miss/replay audit ledger.

## 3) Mermaid (MCP Wasm component cache prewarm governance loop)
```mermaid
flowchart LR
  A[Wasm Component Request] --> B[Runtime Entitlement Gate]
  B --> C[Base Prewarm-Pool Policy]
  C --> D[Cold-Start Sampler]
  D --> E[Burst Budget Controller]
  E --> F[Runtime Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) Decision matrix
| Dimension | Fixed prewarm pool | Adaptive prewarm pool |
|---|---|---|
| Implementation complexity | Low | Medium |
| Burst absorption | Low | High |
| Miss-rate control | Low-Medium | High |
| Multi-tenant governance depth | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-434-benchmark.json` -> `percentage_contract`.

- Metric A (prewarm-miss rate, fixed prewarm pool)  
  - Formula: `n_miss_fixed_prewarm / n_runtime_requests_observed`  
  - Value: `312/2400 = 13.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_prewarm_miss_rate`
- Metric B (prewarm-miss rate, adaptive prewarm pool)  
  - Formula: `n_miss_adaptive_prewarm / n_runtime_requests_observed`  
  - Value: `92/2400 = 3.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_prewarm_miss_rate`
- Metric C (recovery success gain, percentage points)  
  - Formula: `(n_recovery_success_adaptive - n_recovery_success_fixed) / n_runtime_requests_observed`  
  - Value: `(2186-1874)/2400 = 13.0 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.prewarm_recovery_gain_pts`

## 6) Production checklist
- [ ] Prewarm-pool and adaptive-scaling policies are versioned with rollout and rollback controls
- [ ] Tenant runtime entitlement and burst-budget gates are enforced at gateway level
- [ ] Prewarm miss-rate, recovery success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
