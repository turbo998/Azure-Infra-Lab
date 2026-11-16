# Agent Gateway Semantic Cache TTL Governance Selection FAQ (Fixed Global TTL vs Adaptive Tiered TTL)

## 1) Core conclusions
- **Production multi-tenant gateways should default to adaptive tiered TTL with policy versioning**, not raw prompt hash only.
- **Fixed global TTL destabilizes hit rate under mixed workload lifecycles**, amplifying fallback calls and tail latency.
- **TTL governance must be coupled with tenant namespaces, expiry controls, and TTL/quota policy loops** for durable gains.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Fixed global TTL**: hash input text directly; simple but highly sensitive to minor textual variance.
- **Adaptive tiered TTL**: canonicalize inputs (template + slots + policy version) before key generation.

### Q1: Why are raw hash keys unstable in production?
First principle: different workload heat curves require different expiry windows; one global TTL creates avoidable misses or stale occupancy.

### Q2: When is fixed global TTL still acceptable?
Short-lived single-tenant flows with rigid prompt templates, lower hit-rate expectations, and tolerance for occasional fallback spikes.

### Q3: What is the minimum safe TTL control loop?
Workload classification -> TTL policy planning -> tenant namespace isolation -> hit/miss+expiry ledger -> TTL/quota tuning -> expiry audit.

## 3) Mermaid (semantic cache TTL governance loop)
```mermaid
flowchart LR
  I[Prompt/Input] --> N[Workload Classifier]
  N --> K[TTL Policy Planner]
  K --> T[Tenant Namespace Fence]
  T --> C[Cache Lookup]
  C --> M[Hit/Miss + Expiry Ledger]
  M --> P[TTL + Quota Policy Loop]
```

## 4) Decision matrix
| Dimension | Fixed global TTL | Adaptive tiered TTL |
|---|---|---|
| Implementation complexity | Low | Medium-High |
| Hit-rate stability | Low-Medium | High |
| Fallback amplification control | Low | High |
| Multi-tenant isolation governance | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-427-benchmark.json` -> `percentage_contract`.

- Metric A (cache miss rate, fixed global TTL)  
  - Formula: `n_miss_fixed_ttl / n_sessions_observed`  
  - Value: `256/2000 = 12.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_ttl_cache_miss_rate`
- Metric B (cache miss rate, adaptive tiered TTL)  
  - Formula: `n_miss_adaptive_ttl / n_sessions_observed`  
  - Value: `62/2000 = 3.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.adaptive_ttl_cache_miss_rate`
- Metric C (cache-hit gain, percentage points)  
  - Formula: `(n_hit_adaptive_ttl - n_hit_fixed_ttl) / n_sessions_observed`  
  - Value: `(1704-1480)/2000 = 11.2 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.cache_hit_gain_pts`

## 6) Production checklist
- [ ] TTL strategy is versioned with rollout and rollback controls
- [ ] Tenant namespace isolation and quota gates are enforced at gateway level
- [ ] Expiry controls and hit/miss ledgers are auditable and replay-safe
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
