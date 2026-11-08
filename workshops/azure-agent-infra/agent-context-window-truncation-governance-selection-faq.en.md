# Agent Context Window Truncation Governance Selection FAQ (Fixed Truncation Threshold vs Adaptive Context Packing)

## 1) Core conclusions
- **Production multi-tenant deployments should default to adaptive context packing plus truncation-budget gates**, not long-term fixed truncation thresholds only.
- **Fixed truncation thresholds are more likely to drop critical context under long tool chains and multi-step reasoning**, increasing retries and tail-latency cost.
- **Truncation governance must be coupled with tenant entitlements, gateway policy, and replay audit loops** to satisfy both reliability and compliance boundaries.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Fixed truncation threshold**: hard token cap cuts context once the limit is hit; simple but less robust.
- **Adaptive context packing**: reprioritizes context by task risk and evidence value to reduce critical semantic loss.

### Q1: Why is a fixed truncation threshold risky in production?
First principle: context value density is uneven; static truncation can sever key causal chains and destabilize model decisions.

### Q2: When is a fixed truncation threshold acceptable?
Short-lived single-tenant sessions with highly stable prompts and strict human-review fallback can use it as a short transitional strategy.

### Q3: What is the minimum safe truncation-governance loop?
Tenant runtime entitlement -> context baseline policy -> value sampling + reordering decision -> truncation-budget gate -> failure replay and audit trace.

## 3) Mermaid (MCP context truncation governance loop)
```mermaid
flowchart LR
  A[Tool / Prompt Context Stream] --> B[Runtime Entitlement Gate]
  B --> C[Context Baseline Policy]
  C --> D[Semantic Value Sampler]
  D --> E[Truncation Budget Controller]
  E --> F[Context Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) Decision matrix
| Dimension | Fixed truncation threshold | Adaptive context packing |
|---|---|---|
| Implementation complexity | Low | Medium |
| Critical-semantic retention | Low-Medium | High |
| Truncation-loss control | Low-Medium | High |
| Multi-tenant governance depth | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-436-benchmark.json` -> `percentage_contract`.

- Metric A (truncation-loss rate, fixed threshold)
  - Formula: `n_loss_fixed_truncation / n_runtime_requests_observed`
  - Value: `312/2400 = 13.0%` (`synthetic_assumed`)
  - Path: `percentage_contract.fixed_truncation_loss_rate`
- Metric B (truncation-loss rate, adaptive context packing)
  - Formula: `n_loss_adaptive_context_packing / n_runtime_requests_observed`
  - Value: `92/2400 = 3.8%` (`synthetic_assumed`)
  - Path: `percentage_contract.adaptive_context_packing_loss_rate`
- Metric C (recovery success gain, percentage points)
  - Formula: `(n_recovery_success_adaptive - n_recovery_success_fixed) / n_runtime_requests_observed`
  - Value: `(2186-1874)/2400 = 13.0 percentage points` (`synthetic_assumed`)
  - Path: `percentage_contract.context_recovery_gain_pts`

## 6) Production checklist
- [ ] Context-packing and truncation-budget policies are versioned with rollout and rollback controls
- [ ] Tenant runtime entitlement and truncation-budget gates are enforced at gateway level
- [ ] Truncation-loss rate, recovery success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
