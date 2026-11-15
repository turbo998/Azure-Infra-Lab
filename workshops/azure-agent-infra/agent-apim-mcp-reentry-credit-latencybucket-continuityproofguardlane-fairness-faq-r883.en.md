# Agent APIM/MCP Reentry Credit and Latency Bucket Continuity-Proof Guardlane FAQ (Cycle 2288)

## 1) Context and constraints
This cycle focuses on continuityproof guardlane design. APIM AI Gateway, MCP orchestration, reentry-credit ledgers, and latency-bucket scheduling must keep continuity verifiable under burst and retry pressure.

```mermaid
flowchart LR
    A[Client Request] --> B[APIM AI Gateway]
    B --> C[MCP Planner]
    C --> D[Reentry Credit Ledger]
    D --> E[Latency Bucket Scheduler]
    E --> F[Continuityproof Guardlane]
    F --> G{Continuity proof valid?}
    G -- Yes --> H[Execute and Commit]
    G -- No --> I[Fallback and Replay Queue]
```

## 2) Q1 / Q2 / Q3
Q1: How is continuity-proof guardlane different from availability-proof guardlane?
A1: Availability targets immediate serviceability; continuity-proof targets uninterrupted cross-window state handoff.

Q2: Why must continuity-proof checks include reentry-credit ledgers?
A2: Reentry credit controls retry and recovery order; missing continuity proof amplifies queue jitter and recovery gaps.

Q3: How can continuity-proof checks stay efficient?
A3: Hot path checks continuity_hash and fallback_token, while cold path runs full continuity replay verification offline.

## 3) Recommendation (Good fit / Not for)
Good fit: multi-tenant SaaS Agent Gateway, Browser/CUA clusters, and high-compliance zero-trust execution.
Not for: one-off scripts, temporary experiments without continuity-proof requirements, and single-node flows without tenant fairness constraints.

## 4) Reproducible benchmark scope
Evidence is in `evidence/cycle-2288-benchmark.json`, including cold/warm latency, throughput, policy interception, and per-session cost with measured/synthetic/anonymized_reported labels.

## 5) Percentage contract bindings (N/D)
- `percentage_contract.unfenced_reentry_continuityproofguardlane_drift_rate`
- `percentage_contract.reentry_continuityproofguardlane_variance_rate`
- `percentage_contract.reentry_continuityproofguardlane_recovery_gain_pts`

These keys bind this FAQ to cycle-2288 evidence with `production_validation=not_measured`.

## 6) Production checklist
1. APIM and MCP emit continuity_hash and fallback_reason.
2. Reentry-credit writes include fallback_token and trace_id.
3. Latency-bucket decisions carry continuity-vote hash.
4. Budget-exhausted requests route to fallback and replay queues.
5. Replay tooling reconstructs continuity sequences by trace_id.
6. Reports preserve measured/synthetic/anonymized_reported labels.
