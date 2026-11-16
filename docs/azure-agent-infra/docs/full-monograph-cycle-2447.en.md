# Cycle #2447 Monograph Addendum (SBOM Attestation Supply-Chain Gate)

- Cycle: 2447  
- Window (BJT): 2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic: Runtime admission gating for enterprise agent supply-chain trust (SBOM + signed attestation)  
- Exclusion: no semiconductor/ALD content

## Chapter 463 · From “scan report” to runtime admission control

Build-time scanning alone is insufficient:
- Runtime dependencies can drift after image publication.  
- Plugins/connectors may be loaded dynamically.  
- Tenant-specific policy can alter acceptable risk thresholds for the same artifact.

So SBOM/attestation verification must happen on the request admission path, not only in release pipelines.

## Chapter 464 · Admission policy and threshold design

### Recommended block expression

```text
block_if =
  (critical_vuln_count > 0)
  OR (attestation_missing = true)
  OR (sbom_drift_ratio > drift_threshold)
```

Where:
- `sbom_drift_ratio = changed_packages / total_packages`
- `drift_threshold` should be tiered by tenant risk class (for example 0.5%, 1.0%, 2.0%)

## Chapter 465 · Failure modes and mitigations

| Failure mode | Symptom | Primary action | Mitigation |
|---|---|---|---|
| Unproven artifact admitted | Provenance gap discovered at runtime | Hard APIM block | emergency rollback |
| False-block spike | large 4xx surge in release window | temporary read-only fallback + manual review | retune drift threshold |
| Broken attestation chain | digest-signature mismatch | stop release batch | re-sign and rebuild index |

## Chapter 466 · Joint security + business metrics

Track security and delivery together:
- `unauthorized_artifact_block_rate`
- `false_positive_block_rate`
- `mttr_for_vuln_patch`
- `p95_admission_latency`

This avoids both extremes: secure-but-unusable and fast-but-untrusted.

## Summary 925

Round 1042 converts supply-chain governance from static policy text into executable runtime admission controls.  
For enterprise agent infrastructure, SBOM and attestation are hard production prerequisites, not optional audit artifacts.
