# Agent Memory Tiering Selection FAQ (Hot-Only Store vs Hot/Cold Tiered Store)

## 1) Core conclusions
- **Production multi-tenant deployments should default to hot/cold tiered memory with retrieval-budget gates**, not long-term hot-only memory.
- **Hot-only memory is more likely to trigger recall gaps under long sessions and high-concurrency tool execution**, increasing retries and tail-latency cost.
- **Memory-tiering governance must be coupled with tenant entitlements, gateway policy, and replay audit loops** to satisfy both reliability and compliance boundaries.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Hot-only store**: all session memory remains in the high-performance tier; fast but expensive and capacity-sensitive.
- **Hot/cold tiered store**: recent critical memory stays hot, long-tail memory sinks to cold tier with on-demand recall.

### Q1: Why is hot-only memory risky in production?
First principle: memory-access locality and semantic value are uneven; forcing everything into hot tier causes eviction churn and recall blind spots.

### Q2: When is hot-only memory acceptable?
As a short transitional strategy for short sessions, low concurrency, and strongly templated workflows with manual fallback.

### Q3: What is the minimum safe memory-tiering governance loop?
Tenant runtime entitlement -> memory baseline policy -> value sampling + tiering decision -> retrieval-budget gate -> recall-failure replay and audit trace.

## 3) Mermaid (MCP memory-tiering governance loop)
```mermaid
flowchart LR
  A[Session Memory Stream] --> B[Runtime Entitlement Gate]
  B --> C[Memory Baseline Policy]
  C --> D[Semantic Value Sampler]
  D --> E[Retrieval Budget Controller]
  E --> F[Memory Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) Decision matrix
| Dimension | Hot-only store | Hot/cold tiered store |
|---|---|---|
| Implementation complexity | Low | Medium |
| Long-session recall stability | Low-Medium | High |
| Recall-loss control | Low-Medium | High |
| Multi-tenant governance depth | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-437-benchmark.json` -> `percentage_contract`.

- Metric A (recall-loss rate, hot-only store)
  - Formula: `n_recall_loss_hot_only / n_runtime_requests_observed`
  - Value: `312/2400 = 13.0%` (`synthetic_assumed`)
  - Path: `percentage_contract.fixed_hot_only_recall_loss_rate`
- Metric B (recall-loss rate, hot/cold tiered store)
  - Formula: `n_recall_loss_tiered_hot_cold / n_runtime_requests_observed`
  - Value: `92/2400 = 3.8%` (`synthetic_assumed`)
  - Path: `percentage_contract.tiered_hot_cold_recall_loss_rate`
- Metric C (recovery success gain, percentage points)
  - Formula: `(n_recovery_success_tiered - n_recovery_success_hot_only) / n_runtime_requests_observed`
  - Value: `(2186-1874)/2400 = 13.0 percentage points` (`synthetic_assumed`)
  - Path: `percentage_contract.memory_recall_gain_pts`

## 6) Production checklist
- [ ] Memory-tiering and retrieval-budget policies are versioned with rollout and rollback controls
- [ ] Tenant runtime entitlement and retrieval-budget gates are enforced at gateway level
- [ ] Recall-loss rate, recovery success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
