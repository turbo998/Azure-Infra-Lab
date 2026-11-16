# Agent APIM/MCP Reentry Credit and Latency Bucket Durability-Proof Guardlane FAQ (Cycle 2289)

## 1) Context and constraints
This cycle focuses on durabilityproof guardlane design. APIM AI Gateway, MCP orchestration, reentry-credit ledgers, and latency-bucket scheduling must keep durability verifiable under burst and retry pressure.

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Durabilityproof Guardlane]
    F --> G{Durability proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1: How is durability-proof guardlane different from continuity-proof guardlane?
A1: Continuity targets uninterrupted cross-window flows; durability-proof targets state persistence and replay integrity.

Q2: Why must durability-proof checks include reentry-credit ledgers?
A2: Reentry credit is the retry and quota source of truth; missing durability proof causes post-recovery mismatch.

Q3: How can durability-proof checks stay efficient?
A3: Hot path checks durability_hash and fallback_token, while cold path runs full persistence replay verification offline.

## 3) Recommendation (Good fit / Not for)
Good fit: multi-tenant SaaS Agent Gateway, Browser/CUA clusters, and high-compliance zero-trust execution.
Not for: one-off scripts, temporary experiments without durability-proof requirements, and single-node flows without tenant fairness constraints.

## 4) Reproducible benchmark scope
Evidence is in `evidence/cycle-2289-benchmark.json`, including cold/warm latency, throughput, policy interception, and per-session cost with measured/synthetic/anonymized_reported labels.

## 5) Percentage contract bindings (N/D)
- `percentage_contract.unfenced_reentry_durabilityproofguardlane_drift_rate`
- `percentage_contract.reentry_durabilityproofguardlane_variance_rate`
- `percentage_contract.reentry_durabilityproofguardlane_recovery_gain_pts`

These keys bind this FAQ to cycle-2289 evidence with `production_validation=not_measured`.

## 6) Production checklist
1. APIM and MCP emit durability_hash and fallback_reason.
2. Reentry-credit writes include fallback_token and trace_id.
3. Latency-bucket decisions carry durability-vote hash.
4. Budget-exhausted requests route to fallback and replay queues.
5. Replay tooling reconstructs durability sequences by trace_id.
6. Reports preserve measured/synthetic/anonymized_reported labels.
