# Cycle #2457 Core Infra Monograph: APIM PTU↔PAYGO Spillover and Cache Affinity (en)

- Round/Cycle: `1052 / 2457`
- Date: `2026-11-16 (BJT)`
- Topic: `apim-ai-gateway-ptu-paygo-spillover-cache-affinity-faq-r1052`
- Labels: `measured / synthetic / anonymized_reported`

## Chapter 460 · Daily breakthroughs and gateway-engineering implications

This cycle is grounded in APIM AI Gateway, ACA Sessions, and runtime release evidence.  
Core engineering challenge: controlled spillover under PTU saturation instead of unconstrained PAYGO expansion.

## Chapter 461 · Layered reference architecture

### 1) Traffic governance layer

Token-bucket + circuit breakers bound burst traffic and trigger safe degradation.

### 2) Execution routing layer

PTU lane carries baseline load; PAYGO lane handles burst spillover with hysteresis-based re-entry.

### 3) Cache affinity layer

Prompt-cache affinity clusters semantically similar traffic into hot shards to improve cache hit and reduce inference cost.

## Chapter 462 · Reproducible benchmark outcomes

From `evidence/cycle-2457-*`:
- Latency: E2B P50 `118ms`, ACA warm P50 `257ms`, Kata P50 `920ms`
- Throughput: APIM routing P50 `1372 rps`
- Interception: `ptu-paygo-spillover-policy-violation` `172/184=93.48%`; `cache-affinity-routing-fence` `161/168=95.83%`
- Cost: E2B `$0.00552/session`, Kata `$0.01044/session`, ACA `$0.01100/session`

## Chapter 463 · Failure modes

### A. Spillover storms causing cost spikes

Over-aggressive failover from PTU to PAYGO under burst.
Mitigation: spillover ratio caps and recovery hysteresis windows.

### B. Cache misses amplifying latency

Hot prompts miss affinity routes.
Mitigation: tenant/template-aware shard mapping and hot-key prewarming.

### C. Cascading degradation oscillation

Over-sensitive breaker settings create route instability.
Mitigation: layered breakers and localized fallback policies.

## Chapter 464 · Strategy comparison and conclusion

| Strategy | Stability | Cost control | Complexity |
|---|---:|---:|---:|
| PTU-only hard throttle | Medium | High | Low |
| PAYGO-first | Low | Low | Low |
| Adaptive PTU+PAYGO + cache affinity | **High** | **High** | Medium-high |

Conclusion: enterprise multi-model gateways should adopt PTU-first adaptive spillover with cache affinity for balanced SLA and cost.

## Chapter 465 · Five-step rollout

1. Establish PTU capacity baseline and PAYGO budget.
2. Deploy token-bucket and breaker thresholds.
3. Enable cache-affinity sharding and prewarm plan.
4. Implement spillover-policy-version canary and rollback.
5. Review latency, spillover rate, cost, and failure rates weekly.

**Good fit**: bursty high-concurrency enterprise gateway workloads.  
**Not for**: teams without real-time observability and rollback operations.
