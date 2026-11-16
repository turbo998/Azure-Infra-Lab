# Agent APIM/MCP Reentry Credit and Latency Bucket Integrity-Proof Guardlane FAQ (Cycle 2283)

## 1) Context and constraints
This cycle focuses on integrityproof guardlane design. APIM AI Gateway, MCP orchestration, reentry-credit ledgers, and latency-bucket scheduling must keep decision and evidence integrity verifiable under burst and retry pressure.

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Integrityproof Guardlane]
    F --> G{Integrity proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1: How is integrity-proof guardlane different from coherence guardlane?
A1: Coherence focuses on cross-path consistency; integrity-proof focuses on tamper-evident verifiability for each decision and artifact.

Q2: Why must integrity-proof checks include reentry-credit ledgers?
A2: Reentry credit drives budget and priority, so unverifiable ledger integrity distorts tenant audits and incident replay.

Q3: How can integrity-proof checks remain efficient?
A3: Hot path checks integrity_hash and proof_anchor, while cold path runs full chain-integrity verification offline.

## 3) Recommendation (Good fit / Not for)
Good fit: multi-tenant SaaS Agent Gateway, Browser/CUA clusters, and high-compliance zero-trust execution.
Not for: one-off scripts, temporary experiments without integrity-proof requirements, and single-node flows without tenant fairness constraints.

## 4) Reproducible benchmark scope
Evidence is in `evidence/cycle-2283-benchmark.json`, including cold/warm latency, throughput, policy interception, and per-session cost with measured/synthetic/anonymized_reported labels.

## 5) Percentage contract bindings (N/D)
- `percentage_contract.unfenced_reentry_integrityproofguardlane_drift_rate`
- `percentage_contract.reentry_integrityproofguardlane_variance_rate`
- `percentage_contract.reentry_integrityproofguardlane_recovery_gain_pts`

These keys bind this FAQ to cycle-2283 evidence with `production_validation=not_measured`.

## 6) Production checklist
1. APIM and MCP emit integrity_hash and fallback_reason.
2. Reentry-credit writes include proof_anchor and trace_id.
3. Latency-bucket decisions carry integrity-vote hash.
4. Budget-exhausted requests route to fallback and replay queues.
5. Replay tooling reconstructs integrity sequences by trace_id.
6. Reports preserve measured/synthetic/anonymized_reported labels.
