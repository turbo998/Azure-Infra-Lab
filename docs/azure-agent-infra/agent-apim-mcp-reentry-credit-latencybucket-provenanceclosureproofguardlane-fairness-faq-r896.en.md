# Agent APIM/MCP Reentry Credit and Latency Bucket Provenance-Closure-Proof Guardlane FAQ (Cycle 2301)

## 1) Context and constraints
This cycle focuses on provenanceclosureproof guardlane design. APIM AI Gateway, MCP orchestration, reentry-credit ledgers, and latency-bucket scheduling must keep provenance closure verifiable under burst and retry pressure.

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Provenanceclosureproof Guardlane]
    F --> G{Provenance closure proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1: How is provenance-closure-proof guardlane different from forensic-lineage-proof guardlane?
A1: Forensic lineage targets investigation admissibility; provenance closure validates source-to-process-to-output closure integrity.

Q2: Why must this guardlane include reentry-credit ledgers?
A2: Reentry credit is the decision backbone; missing provenance closure causes non-traceable critical decisions.

Q3: How can provenance-closure-proof checks stay efficient?
A3: Hot path checks provenance_closure_hash and fallback_token, while cold path rebuilds provenance chains offline.

## 3) Recommendation (Good fit / Not for)
Good fit: multi-tenant SaaS Agent Gateway, Browser/CUA clusters, and high-compliance zero-trust execution.
Not for: one-off scripts, temporary experiments without provenance-closure-proof requirements, and single-node flows without tenant fairness constraints.

## 4) Reproducible benchmark scope
Evidence is in `evidence/cycle-2301-benchmark.json`, including cold/warm latency, throughput, policy interception, and per-session cost with measured/synthetic/anonymized_reported labels.

## 5) Percentage contract bindings (N/D)
- `percentage_contract.unfenced_reentry_provenanceclosureproofguardlane_drift_rate`
- `percentage_contract.reentry_provenanceclosureproofguardlane_variance_rate`
- `percentage_contract.reentry_provenanceclosureproofguardlane_recovery_gain_pts`

These keys bind this FAQ to cycle-2301 evidence with `production_validation=not_measured`.

## 6) Production checklist
1. APIM and MCP emit provenance_closure_hash and fallback_reason.
2. Reentry-credit writes include fallback_token and trace_id.
3. Latency-bucket decisions carry provenance-closure vote hash.
4. Budget-exhausted requests route to fallback and replay queues.
5. Replay tooling reconstructs provenance adjudication by trace_id.
6. Reports preserve measured/synthetic/anonymized_reported labels.
