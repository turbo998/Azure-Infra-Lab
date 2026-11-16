# Cycle #2446 Monograph Addendum (OBO Token Vault and HSM Envelope Rotation)

- Cycle: 2446  
- Window (BJT): 2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic: OBO token governance, key rotation, and tenant audit closure for enterprise agents  
- Exclusion: no semiconductor/ALD content

## Chapter 462 · The real root cause of OBO token loss of control

In multi-agent DAGs, the risk is usually token replication, not model calls:
1. Planner forwards bearer token to Worker.  
2. Worker forwards token again to Tool adapter.  
3. Logs/retry queues accidentally persist raw token payload.

Therefore, the primary control is removing plaintext token propagation entirely, allowing only token references (`token_ref`) in runtime paths.

## Chapter 463 · Dual-version HSM envelope rotation

### Rotation state machine

1. **Prepare**: create `key_vN+1`; vault supports dual-read mode.  
2. **Shift-Write**: all new writes move to `key_vN+1`.  
3. **Reencrypt**: background re-encryption migrates old ciphertext.  
4. **Retire**: disable `key_vN` only after migration SLO is met.

### Hard constraint

`exposure_window = token_ttl + cache_ttl + retry_backoff_max`

If exposure window exceeds policy threshold, reduce token TTL and block cross-hop token caches.

## Chapter 464 · Failure modes and defenses

| Failure mode | Symptom | Defense |
|---|---|---|
| Plaintext leakage | Raw token appears in logs | token_ref-only + log redaction |
| Rotation breakage | read conflict across key versions | dual-read window + idempotent re-encrypt jobs |
| Tenant bleed-through | tenant A token accesses tenant B tool | tenant-scoped token namespace + policy gates |
| Revocation lag | token still usable after revoke | introspection cache TTL convergence |

## Chapter 465 · Evidence and audit contract

- Benchmark contract: `evidence/cycle-2446-benchmark.json`
- Latency: `evidence/cycle-2446-latency.csv`
- Throughput: `evidence/cycle-2446-throughput.csv`
- Policy: `evidence/cycle-2446-policy.csv`
- Cost: `evidence/cycle-2446-cost.csv`

Recommended audit keys: `tenant_id`, `token_ref`, `key_version`, `policy_version`, `request_id`.

## Summary 918

Round 1041 turns identity/key security from generic guidance into an executable state machine plus measurable constraints.  
For enterprise agent platforms, OBO + Vault + HSM rotation is a hard production precondition, not an after-launch enhancement.
