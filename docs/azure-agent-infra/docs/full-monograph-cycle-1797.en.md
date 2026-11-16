# Cycle 1797 Topic: HSM Signing Latency

## Summary
This cycle designs HSM batch-signing plus cache coordination for lower peak signing latency.

## Key conclusion
Batch-plus-cache strategy outperforms per-request direct HSM for SLO stability under concurrency.
