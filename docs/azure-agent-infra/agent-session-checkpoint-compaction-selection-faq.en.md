# Agent Session Checkpoint Compaction Selection FAQ (Full Snapshot Chain vs Delta Checkpoint Chain)

## 1) Core conclusions
- **Production multi-tenant deployments should default to delta checkpoint chains with periodic full anchors**, not long-term full snapshot chains only.
- **Full snapshot chains are more likely to amplify resume failures and tail-latency cost under long sessions, frequent tool calls, and cross-zone restore paths**.
- **Checkpoint governance must be coupled with tenant entitlements, gateway policy, and replay audit loops** to satisfy both reliability and compliance boundaries.

## 2) Q1 / Q2 / Q3 (plain terms first)
- **Full snapshot chain**: stores full session state each save; simple but high write amplification and storage cost.
- **Delta checkpoint chain**: stores only state changes with periodic anchors; better recovery efficiency and cost control.

### Q1: Why is a full snapshot chain risky in production?
First principle: when session-state size and tool-result variance rise together, repeated full writes increase I/O pressure and replay window fragility.

### Q2: When is a full snapshot chain acceptable?
As a short transitional strategy for single-tenant, short-lived sessions with small state and low restore frequency.

### Q3: What is the minimum safe checkpoint governance loop?
Tenant runtime entitlement -> checkpoint baseline policy -> delta sampling + compaction decision -> burst-budget gate -> resume-failure and replay audit.

## 3) Mermaid (MCP session checkpoint governance loop)
```mermaid
flowchart LR
  A[Session State Mutation] --> B[Runtime Entitlement Gate]
  B --> C[Checkpoint Baseline Policy]
  C --> D[Delta Sampler]
  D --> E[Burst Budget Controller]
  E --> F[Checkpoint Lifecycle Manager]
  F --> G[Audit / Replay Ledger]
```

## 4) Decision matrix
| Dimension | Full snapshot chain | Delta checkpoint chain |
|---|---|---|
| Implementation complexity | Low | Medium |
| Long-session recovery resilience | Low-Medium | High |
| Resume-failure control | Low-Medium | High |
| Multi-tenant governance depth | Medium | High |
| Default production fit | Short transitional phase | Multi-tenant long-running workloads |

## 5) Evidence contract + recomputable examples (n/denominator/source)
> Percentages in this section are `synthetic_assumed` hypothetical examples for mechanism comparison; production mechanism validation remains `not_measured`.  
> Contract fields: `workshops/azure-agent-infra/evidence/cycle-435-benchmark.json` -> `percentage_contract`.

- Metric A (resume-failure rate, full snapshot chain)  
  - Formula: `n_resume_fail_fixed_snapshot / n_runtime_requests_observed`  
  - Value: `312/2400 = 13.0%` (`synthetic_assumed`)  
  - Path: `percentage_contract.fixed_snapshot_resume_failure_rate`
- Metric B (resume-failure rate, delta checkpoint chain)  
  - Formula: `n_resume_fail_delta_checkpoint / n_runtime_requests_observed`  
  - Value: `92/2400 = 3.8%` (`synthetic_assumed`)  
  - Path: `percentage_contract.delta_checkpoint_resume_failure_rate`
- Metric C (resume success gain, percentage points)  
  - Formula: `(n_resume_success_delta - n_resume_success_fixed) / n_runtime_requests_observed`  
  - Value: `(2186-1874)/2400 = 13.0 percentage points` (`synthetic_assumed`)  
  - Path: `percentage_contract.checkpoint_resume_gain_pts`

## 6) Production checklist
- [ ] Checkpoint compaction and anchor-rotation policies are versioned with rollout and rollback controls
- [ ] Tenant runtime entitlement and burst-budget gates are enforced at gateway level
- [ ] Resume-failure rate, resume success, and replay audit are traceable
- [ ] Metrics are tagged `synthetic_assumed` with denominator and units; production validation remains `not_measured`
