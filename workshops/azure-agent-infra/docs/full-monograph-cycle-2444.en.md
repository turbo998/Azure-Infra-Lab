# Cycle #2444 Monograph Addendum (AKS Kata Pod-VM & eBPF Density Guard)

- Cycle: 2444  
- Window (BJT): 2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic: High-density AKS Kata Pod-VM sandboxing with eBPF degradation signals and APIM admission coupling  
- Exclusion: no semiconductor/ALD content

## Chapter 460 · Move from “rules of thumb” to executable density math

### 1) Node-capacity equation (SKU-level)

For AKS Kata nodes, estimate safe density with:

```text
effective_mem = node_mem - kube_reserved - system_reserved - safety_headroom
per_podvm   = app_request + kata_vm_fixed + io_cache
max_density = floor(effective_mem / per_podvm)
target_density = max_density * utilization_guard
```

Example on D32ds_v5 (128 GiB):
- kube/system reserve: 14 GiB
- safety headroom: 10 GiB (fragmentation, reclaim lag, burst cache)
- effective memory: 104 GiB
- per Pod-VM: 1.30 GiB (0.75 app + 0.35 Kata fixed + 0.20 cache)
- theoretical max: 80
- production target (guard=0.72): 57

This gap (80 theoretical vs 57 safe production) is exactly where most density incidents happen.

### 2) Typical failure modes

1. **Page-cache surge** from artifact/log bursts, causing reclaim jitter amplification.  
2. **Conntrack explosion** during short-connection spikes, raising retransmissions.  
3. **Cgroup reclaim lag**, producing latency cascades despite apparent free memory.  
4. **Burst-admission mismatch** between gateway intake and node reclaim capacity.

## Chapter 461 · eBPF guardrails coupled to APIM admission

### eBPF signal triad

- `skb_drop_reason` distribution  
- `tcp_retrans` rate  
- `dns_lookup_latency` jitter

Aggregate in ADX, derive `density_guard_state`:
- `green`: normal admission
- `amber`: reduced burst quota
- `red`: priority tenants/tools only

APIM policy consumes this state for real-time admission shaping, closing the loop from network degradation to controlled intake.

## Chapter 462 · Tuning priority and expected outcomes

| Tuning action | Latency gain | Throughput impact | Cost impact | Priority |
|---|---:|---:|---:|---|
| Lower per-pod quota | High | Medium negative | Low | 1 |
| Enable eBPF adaptive throttling | High | Low negative | Low | 2 |
| Increase warm pool | Medium | Positive | Medium positive | 3 |
| Expand node pool | Medium | High positive | High positive | 4 |

Conclusion: tune admission/quota first, scale capacity second.

## Chapter 463 · Evidence binding contract

- Benchmark contract: `evidence/cycle-2444-benchmark.json`
- Latency: `evidence/cycle-2444-latency.csv`
- Throughput: `evidence/cycle-2444-throughput.csv`
- Policy intercept: `evidence/cycle-2444-policy.csv`
- Cost: `evidence/cycle-2444-cost.csv`

All metrics keep explicit `measured` / `synthetic` / `anonymized_reported` provenance.

## Summary 903

The Round 1039 correction is not a cosmetic rewrite. It converts AKS Kata density guidance into verifiable formulas, explicit failure-mode diagnostics, and executable tuning order.  
In production, **density is a governance loop problem, not only a scaling problem**: only APIM admission coupled with eBPF signals can stabilize isolation, p95 latency, and cost together.
