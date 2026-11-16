# Cycle #2454 Public Benefits Monograph: Eligibility Fraud Agent × Audit Control Gateway (en)

- Round/Cycle: `1049 / 2454`
- Date: `2026-11-16 (BJT)`
- Topic: `public-sector-benefits-eligibility-fraud-audit-agent-gateway-faq-r1049`
- Labels: `measured / synthetic / anonymized_reported`

## Chapter 460 · Daily breakthroughs and public-sector impact

Evidence stack for this cycle:
1. APIM AI Gateway + changelog (`measured`)
2. ACA Dynamic Sessions (`measured`)
3. Firecracker/Kata/Wasmtime/E2B release streams (`measured`)

For public-benefits operations, platform success depends on explainable and appeal-ready decision traces, not raw speed alone.

## Chapter 461 · Production layered architecture

### 1) Scoring layer

Agent correlates eligibility evidence, prior claims behavior, and anomaly signals to produce risk score.

### 2) Control layer

Policy gateway applies `governance-policy-version` and routes each case to:
- auto-approve
- auto-deny
- manual review

### 3) Execution layer

Final action is committed to benefits core with complete audit lineage.

## Chapter 462 · Quantified outcomes

From `evidence/cycle-2454-*`:

- Cold start/restore: E2B P50 `118ms`, P95 `211ms`; ACA warm P50 `257ms`, P95 `398ms` (`anonymized_reported`)
- Throughput: APIM routing P50 `1372 rps`, P95 `1178 rps` (`synthetic`)
- Interception: `audit-gate-policy-violation` `172/184=93.48%`; `eligibility-control-zone-fence` `161/168=95.83%` (`measured`)
- Cost: E2B `$0.00552/session`, AKS Kata `$0.01044/session`, ACA `$0.01100/session` (`synthetic`)

## Chapter 463 · Failure modes and mitigations

### A. Policy-version skew

Different nodes evaluate different policy versions and produce inconsistent outcomes.
Mitigation: dual-read checks during rollout plus automatic rollback thresholds.

### B. Peak-load false approvals

Boundary cases are fast-tracked incorrectly during demand spikes.
Mitigation: risk-bucket thresholds and mandatory review path for borderline claims.

### C. Incomplete appeal evidence

Appeal officers cannot reconstruct decision path.
Mitigation: one trace_id across scoring, policy, and execution logs in ADX.

## Chapter 464 · Comparator and landing conclusion

| Lane | Compliance/audit | Performance | Cost | Ops complexity |
|---|---:|---:|---:|---:|
| Azure APIM + Agent + ADX | High | High | Medium | Medium-high |
| AWS AgentCore composition | Mid-high | High | Medium | Medium-high |
| GCP Agent Engine composition | Medium | Mid-high | Medium | Medium |
| Custom sandbox + rules platform | Variable | High | Low-mid | High |

Conclusion: public-benefits systems should adopt audit-first agent control planes and avoid opaque auto-approval paths.

## Chapter 465 · Five-step rollout

1. Model eligibility and anti-fraud thresholds.
2. Govern `governance-policy-version` lifecycle.
3. Implement manual-review lane for boundary cases.
4. Build ADX appeal replay evidence chain.
5. Weekly review of wrongful payout rate, intercept rate, SLA, and unit cost.

**Good fit**: high-volume benefits adjudication with strict accountability requirements.  
**Not for**: teams without audit and review operating capacity.
