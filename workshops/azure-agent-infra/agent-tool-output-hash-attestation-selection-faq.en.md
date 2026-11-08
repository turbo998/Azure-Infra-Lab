# Agent Tool Output Hash Attestation FAQ (Log-Only Trace vs Verifiable Hash+Signature Chain)

## 1) Core conclusions
- **Cross-system and multi-tenant production should default to hash+signature+replay verification**, not log-only trace.
- **Log-only trace is acceptable only for low-risk internal workflows** with no strong non-repudiation requirements.
- **Release gates should require all three checks together**: recomputable hash, verifiable signature, and replayable evidence.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Log-only trace**: records event metadata but does not guarantee byte-level integrity of outputs.
- **Hash attestation chain**: hash the output, sign the hash, store immutable receipt, and verify later by replay.

### Q1: Why does “having logs” not equal “having proof”?
First principle: logs describe events, while cryptographic hash+signature binds exact payload integrity and origin.

### Q2: When is log-only still acceptable?
Only for low-risk internal scenarios with low dispute likelihood and no external audit burden.

### Q3: What is the minimum attestation control loop?
Output generated -> digest computed -> digest signed -> evidence stored -> replay verifier recomputes hash and validates signature.

## 3) Mermaid (attestation flow)
```mermaid
flowchart LR
  Req[Agent Request] --> Tool[Tool Runtime]
  Tool --> Hash[SHA-256 Digest]
  Hash --> Sign[Signer Identity]
  Sign --> Ledger[Immutable Evidence Ledger]
  Ledger --> Replay[Replay Verifier]
  Replay --> Verdict[Integrity Pass/Fail]
```

## 4) Decision matrix
| Dimension | Log-only trace | Hash+signature attestation chain |
|---|---|---|
| Implementation complexity | Low | Medium |
| Byte-level integrity proof | Low | High |
| Audit non-repudiation | Low | High |
| Cross-system consistency | Medium | High |
| Default recommendation | Low-risk internal workflows | Production cross-boundary workflows |

## 5) Evidence contract + recomputable example (with n/denominator/source)
> All percentages in this section are `synthetic_assumed` hypothetical examples for recomputable explanation.  
> Production live dispute validation remains `not_measured`.  
> Field contract path: `workshops/azure-agent-infra/evidence/cycle-418-benchmark.json` -> `percentage_contract`.

- Metric A (first-pass attribution with log-only trace)  
  - Formula: `n_first_pass_log_only / n_disputes`  
  - Value: `25/40 = 62.5%` (`synthetic_assumed`, hypothetical)  
  - Path: `percentage_contract.log_only_first_pass_attribution_rate`
- Metric B (first-pass attribution with attestation chain)  
  - Formula: `n_first_pass_attested / n_disputes`  
  - Value: `37/40 = 92.5%` (`synthetic_assumed`, hypothetical)  
  - Path: `percentage_contract.attested_first_pass_attribution_rate`
- Metric C (first-pass attribution gain, percentage points)  
  - Formula: `(n_first_pass_attested - n_first_pass_log_only) / n_disputes`  
  - Value: `(37-25)/40 = 30.0 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.attested_gain_vs_log_only`

## 6) Production checklist
- [ ] Hash algorithm, signer identity, and retention policy are versioned  
- [ ] Replay verifier can run independently in the audit environment  
- [ ] Failed samples preserve original payload and signature material  
- [ ] Metrics are explicitly tagged as `synthetic_assumed` hypothetical examples with denominator and units, with production state `not_measured`  
