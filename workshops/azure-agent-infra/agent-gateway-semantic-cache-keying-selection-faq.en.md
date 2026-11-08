# Agent Gateway Semantic Cache Keying Selection FAQ (Raw Prompt Hash vs Normalized Semantic Keys)

## 1) Core conclusions
- **Production multi-tenant gateways should default to normalized semantic keys with policy versioning**, not raw prompt hash only.
- **Raw hash keys destabilize hit rate under prompt variants**, amplifying fallback calls and tail latency.
- **Cache keying must be coupled with tenant namespaces, collision controls, and TTL/quota policy loops** for durable gains.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Raw prompt hash**: hash input text directly; simple but highly sensitive to minor textual variance.
- **Normalized semantic keys**: canonicalize inputs (template + slots + policy version) before key generation.

### Q1: Why are raw hash keys unstable in production?
First principle: semantically equivalent but textually different requests map to different keys, creating false misses and fallback amplification.

### Q2: When is raw hash still acceptable?
Short-lived single-tenant flows with rigid prompt templates, lower hit-rate expectations, and tolerance for occasional fallback spikes.

### Q3: What is the minimum safe control loop?
Input normalization -> semantic key generation -> tenant namespace isolation -> hit/miss ledger -> TTL/quota tuning -> collision audit.

## 3) Mermaid (semantic cache governance loop)
```mermaid
flowchart LR
  I[Prompt/Input] --> N[Normalizer]
  N --> K[Semantic Key Builder]
  K --> T[Tenant Namespace Fence]
  T --> C[Cache Lookup]
  C --> M[Hit/Miss Ledger]
  M --> P[TTL + Quota Policy Loop]
```

## 4) Decision matrix
| Dimension | Raw prompt hash | Normalized semantic keys |
|---|---|---|
| Implementation complexity | Low | Medium-High |
| Hit-rate stability | Low-Medium | High |
| Fallback amplification control | Low | High |
| Multi-tenant isolation governance | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-426-benchmark.json` -> `percentage_contract`.

- Metric A (cache miss rate, raw hash keying)  
  - Formula: `n_miss_raw_hash / n_sessions_observed`  
  - Value: `256/2000 = 12.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.raw_hash_cache_miss_rate`
- Metric B (cache miss rate, normalized semantic keying)  
  - Formula: `n_miss_normalized / n_sessions_observed`  
  - Value: `62/2000 = 3.1%` (`synthetic_assumed`)  
  - Path: `percentage_contract.normalized_key_cache_miss_rate`
- Metric C (cache-hit gain, percentage points)  
  - Formula: `(n_hit_normalized - n_hit_raw_hash) / n_sessions_observed`  
  - Value: `(1704-1480)/2000 = 11.2 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.cache_hit_gain_pts`

## 6) Production checklist
- [ ] Semantic-key strategy is versioned with rollout and rollback controls
- [ ] Tenant namespace isolation and quota gates are enforced at gateway level
- [ ] Collision detection and hit/miss ledgers are auditable and replay-safe
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
