# Agent Rule Evaluation Short-Circuit Selection FAQ (Cycle 1784)

## 1) Three-minute decision
- **In multi-rule pipelines, the main bottleneck is unordered full-rule evaluation, not single-rule complexity.**
- **Recommendation:** risk-first short-circuiting + cost-aware rule ordering + reusable decision cache.
- **Goal:** reduce evaluation latency and compute cost while preserving security hit quality.

## 2) Core questions (Q1/Q2/Q3)
### Q1: Why does full evaluation hurt stability?
1) low-value rules consume disproportionate budget,
2) rule dependencies amplify tail latency,
3) repeated evaluations create waste under concurrency.

### Q2: How to design robust short-circuiting?
- risk-first deny rules execute earliest,
- expensive rules are conditionally triggered,
- cached decisions are reused within bounded windows.

### Q3: How to validate effectiveness?
- deny-hit quality remains stable,
- P95 evaluation latency drops,
- executed rule count per request decreases.

## 3) Reference architecture
```mermaid
flowchart LR
  I[Incoming Request] --> E[Rule Evaluation Orchestrator]
  E --> R1[High-Risk Rules First]
  R1 -->|pass| R2[Cost-Aware Ordered Rules]
  R2 -->|pass| R3[Conditional Expensive Rules]
  E --> C[Decision Cache Window]
  R3 --> L[Evaluation Decision Ledger]
```

## 4) Decision matrix
| Dimension | Full sequential evaluation | Short-circuit + ordering + cache (Recommended) |
|---|---:|---:|
| Security hit quality | Medium | High |
| Evaluation latency | Low | High |
| Resource efficiency | Low | High |
| Implementation complexity | Low | Medium |
| Explainability | Medium | High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-1784-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1784-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1784-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1784-policy.csv`
- Labels: `measured / synthetic / anonymized_reported`.
- validation7 requires bilingual structure, CSP self-contained cards, evidence consistency, and replayability trace.

## 6) Production checklist
- [ ] High-risk rule priority is configurable and auditable.
- [ ] Cost-aware ordering has canary controls.
- [ ] Decision-cache windows/invalidation are explicit.
- [ ] Short-circuit path and final decision are ledgered.
- [ ] FAQ/H5/SVG/7-card references are cycle-aligned.
